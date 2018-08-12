import random
from functools import partial

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, QProcess, QTimer, QStandardPaths

import appstream
from models import getMeta, setMeta, getGame, setGame
from game import Game, Screenshot, Release, Url

class Loader(QObject):
    finished = pyqtSignal()
    started = pyqtSignal()
    stateChanged = pyqtSignal()
    messageChanged = pyqtSignal()
    errorChanged = pyqtSignal()
    logChanged = pyqtSignal()
    gameLoaded = pyqtSignal(Game)

    arch = 'x86_64'

    metaKey = 'flathub_added'

    flatHub = {'name':'flathub', 'url':'https://flathub.org/repo/flathub.flatpakrepo'}

    messages = [
        'Mining Mese blocks...',
        'Peeling bananas...',
        'Constructing castles...',
        'Collecting cow bells...',
        'Summoning demons...',
        'Building power plants...',
        'Planting mines...',
        'Evolving...'
    ]

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._loading = True
        self._error = False
        self._processes = []
        self._timer = QTimer()
        self._timer.timeout.connect(self.changeMessage)
        self._message = random.choice(self.messages)
        self._appsteamPath = QStandardPaths.writableLocation(QStandardPaths.GenericDataLocation) + '/flatpak/appstream/{remote}/{arch}/active/appstream.xml.gz'
        self._iconsPath = QStandardPaths.writableLocation(QStandardPaths.GenericDataLocation) + '/flatpak/appstream/{remote}/{arch}/active/icons'
        self._log = ''

        self._installed_list = ''
        self._updates_list = ''

    def load(self):
        if getMeta(self.metaKey):
            self.loadAppstream()
        else:
            self.runUpdateCommands()

    def runUpdateCommands(self, proc_number=0):
        commandProcess = QProcess()
        commandProcess.finished.connect(partial(self._processes.remove, commandProcess))
        commandProcess.errorOccurred.connect(self.handleError)
        commandProcess.readyReadStandardOutput.connect(partial(self.appendLog, commandProcess))
        if proc_number == 0:
            commandProcess.started.connect(self.startLoading)
            commandProcess.finished.connect(partial(self.runUpdateCommands, 1))
            commandProcess.start('flatpak', ['remote-add', '--if-not-exists', '--user', self.flatHub['name'], self.flatHub['url']])
        elif proc_number == 1:
            commandProcess.finished.connect(partial(self.runUpdateCommands, 2))
            commandProcess.start('flatpak', ['update', '--appstream', '--user'])
        elif proc_number == 2:
            commandProcess.finished.connect(self.runListCommands)
            commandProcess.start('flatpak', ['update', '--user', '-y'])
        self._processes.append(commandProcess)

    def runListCommands(self, proc_number=0):
        commandProcess = QProcess()
        commandProcess.finished.connect(partial(self._processes.remove, commandProcess))
        commandProcess.errorOccurred.connect(self.handleError)
        if proc_number == 0:
            commandProcess.started.connect(self.startLoading)
            commandProcess.finished.connect(partial(self.runListCommands, 1))
            commandProcess.finished.connect(partial(self.loadListData, commandProcess, proc_number))
            commandProcess.start('flatpak', ['list', '--user'])
        if proc_number == 1:
            commandProcess.finished.connect(partial(self.loadListData, commandProcess, proc_number))
            commandProcess.start('flatpak', ['remote-ls', '--updates', '--user'])
        self._processes.append(commandProcess)

    def loadListData(self, process, proc_number):
        if proc_number == 0:
            self._installed_list = str(process.readAllStandardOutput(), 'utf-8')
        if proc_number == 1:
            self._updates_list = str(process.readAllStandardOutput(), 'utf-8')
            self.loadAppstream(process=True)

    def loadAppstream(self, process=None):
        stream = appstream.Store()
        stream.from_file(self._appsteamPath.format(remote=self.flatHub['name'], arch=self.arch))

        for component in stream.get_components():
            if component.project_license:
                if not 'LicenseRef-proprietary' in component.project_license:
                    if not 'CC-BY-NC-SA' in component.project_license:
                        if 'Game' in component.categories:
                            installed = False
                            last_played_date = None
                            if process:
                                name = component.bundle['value'][4:]
                                installed = name in self._installed_list

                            gr = getGame(component.id)
                            if gr:
                                installed = gr.installed
                                last_played_date = gr.last_played_date

                            game = Game(
                                id=component.id,
                                name=component.name,
                                iconSmall=self.getIconSmall(component.icons),
                                iconLarge=self.getIconLarge(component.icons),
                                license=component.project_license,
                                developerName=component.developer_name,
                                summary=component.summary,
                                description=component.description,
                                screenshots=self.getScreenshots(component.screenshots),
                                categories=component.categories,
                                releases=self.getReleases(component.releases),
                                urls=self.getUrls(component.urls),
                                ref=component.bundle['value'],
                                installed=installed,
                                lastPlayedDate=last_played_date
                            )

                            if process:
                                setGame(game=game)

                            self.gameLoaded.emit(game)
        self.finishLoading()

    def getIconSmall(self, icons):
        path = self._iconsPath.format(remote=self.flatHub['name'], arch=self.arch)
        if icons['cached'][0]['height'] == '64':
            return path + '/64x64/' + icons['cached'][0]['value']
        elif icons['cached'][1]['height'] == '64':
            return path + '/64x64/' + icons['cached'][0]['value']
        else:
            return path + '/128x128/' + icons['cached'][0]['height']['value']

    def getIconLarge(self, icons):
        path = self._iconsPath.format(remote=self.flatHub['name'], arch=self.arch)
        cached_icon = icons['cached'][0]
        if cached_icon['height'] == '128':
            return path + '/128x128/' + cached_icon['value']
        elif cached_icon['height'] == '64':
            return path + '/64x64/' + cached_icon['value']

    def getScreenshots(self, screenshots):
        transfer = []
        for screenshot in screenshots:
            single = {'source': None, 'thumbnail': None}
            lowest = 0
            for image in screenshot.images:
                if image.kind == 'source':
                    single['source'] = image.url
                elif image.kind == 'thumbnail':
                    if lowest:
                        if image.width < lowest:
                            lowest = image.width
                            single['thumbnail'] = image.url
                    else:
                        lowest = image.width
                        single['thumbnail'] = image.url

            transfer.append(Screenshot(thumbUrl=single['thumbnail'], sourceUrl=single['source']))
        return transfer

    def getReleases(self, releases):
        transfer = []
        for release in releases:
            transfer.append(Release(version=release.version, timestamp=release.timestamp, description=release.description))
        return transfer

    def findUrlIcon(self, type):
        if ('homepage' == type):
            return 'home.svg'
        elif ('bugtracker' == type):
            return 'bug.svg'
        elif ('help' == type):
            return 'help.svg'
        elif ('faq' == type):
            return 'question.svg'
        elif ('donation' == type):
            return 'donate.svg'
        elif ('translate' == type):
            return 'globe.svg'
        elif ('unknown' == type):
            return 'cogs.svg'

    def findUrlTitle(self, type):
        if ('homepage' == type):
            return 'Homepage'
        elif ('bugtracker' == type):
            return 'Bug Tracker'
        elif ('help' == type):
            return 'Help'
        elif ('faq' == type):
            return 'FAQ'
        elif ('donation' == type):
            return 'Donate'
        elif ('translate' == type):
            return 'Translation'
        elif ('unknown' == type):
            return 'Unknown'

    def getUrls(self, urls):
        transfer = []
        for type, url in urls.items():
            transfer.append(Url(type=type, icon=self.findUrlIcon(type), title=self.findUrlTitle(type), url=url))
        return transfer

    @pyqtProperty(bool, notify=stateChanged)
    def loading(self):
        return self._loading

    @loading.setter
    def loading(self, loading):
        if loading != self._loading:
            self._loading = loading
            self.stateChanged.emit()

    @pyqtProperty(bool, notify=errorChanged)
    def error(self):
        return self._error

    @error.setter
    def error(self, error):
        if error != self._error:
            self._error = error
            self.stateChanged.emit()

    @pyqtProperty(str, notify=logChanged)
    def log(self):
        return self._log

    @log.setter
    def log(self, log):
        if log != self._log:
            self._log = log
            self.logChanged.emit()

    @pyqtProperty(str, notify=stateChanged)
    def message(self):
        return self._message

    @message.setter
    def message(self, message):
        if message != self._message:
            self._message = message
            self.stateChanged.emit()

    def changeMessage(self):
        self.message = random.choice(self.messages)

    def startLoading(self):
        self.loading = True
        self._timer.start(3000)
        self.started.emit()

    def finishLoading(self):
        setMeta(self.metaKey, 'y')
        self.loading = False
        self.finished.emit()

    def appendLog(self, process, finished=False):
        log_data = str(process.readAllStandardOutput(), 'utf-8')
        if finished:
            pass
        else:
            if log_data[:1] == '\r':
                rs = self._log.rsplit('\r', 1)
                if len(rs) > 1:
                    self._log = rs[0] + log_data
                else:
                    self._log = self._log.rsplit('\n', 1)[0] + log_data
            else:
                self._log = self._log + log_data
        self.logChanged.emit()

    def handleError(self, error):
        self._timer.stop()
        self.error = True
        if QProcess.FailedToStart == error:
            self.message = 'Failed to start. Flatpak not installed.'
        if QProcess.Crashed == error:
            self.message = 'Flatpak crashed.'
        if QProcess.Timedout == error:
            self.message = 'Process timed out.'
        if QProcess.WriteError == error:
            self.message = 'Failed to write to process.'
        if QProcess.ReadError == error:
            self.message = 'Failed to read from process.'
        if QProcess.UnknownError == error:
            self.message = 'Unknown failure.'
