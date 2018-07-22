import random
from functools import partial

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, QProcess, QTimer

import appstream
from models import getMeta, setMeta, getGame, setGame, DoesNotExist
from game import Game, Screenshot, Release

class Loader(QObject):
    finished = pyqtSignal()
    started = pyqtSignal()
    stateChanged = pyqtSignal()
    messageChanged = pyqtSignal()
    errorChanged = pyqtSignal()
    gameLoaded = pyqtSignal(Game)

    arch = 'x86_64'

    metaKey = 'flathub_added'

    flatHub = {'name':'flathub', 'url':'https://flathub.org/repo/flathub.flatpakrepo'}

    appsteamPath = '/var/lib/flatpak/appstream/{repo}/{arch}/active/appstream.xml.gz'
    iconsPath = '/var/lib/flatpak/appstream/{repo}/{arch}/active/icons'

    messages = [
        'Mining Mese blocks...',
        'Peeling bananas...',
        'Constructing castles...',
        'Collecting cow bells...',
        'Summoning demons...',
        'Building power plants...'
    ]

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._loading = True
        self._error = False
        self._processes = []
        self._timer = QTimer()
        self._timer.timeout.connect(self.changeMessage)
        self._message = random.choice(self.messages)

    def load(self):
        if getMeta(self.metaKey):
            self.loadAppstream()
        else:
            self.runCommands()

    def runCommands(self, proc_number=0):
        commandProcess = QProcess()
        commandProcess.errorOccurred.connect(self.handleError)
        if proc_number == 0:
            commandProcess.started.connect(self.startLoading)
            commandProcess.finished.connect(partial(self.runCommands, 1))
            commandProcess.start('flatpak', ['remote-add', '--if-not-exists', '--user', self.flatHub['name'], self.flatHub['url']])
        elif proc_number == 1:
            commandProcess.finished.connect(partial(self.runCommands, 2))
            commandProcess.start('flatpak', ['remote-ls', '--updates', '--user'])
        elif proc_number == 2:
            commandProcess.finished.connect(partial(self.runCommands, 3))
            commandProcess.start('flatpak', ['update', '--appstream', '--user'])
        elif proc_number == 3:
            commandProcess.finished.connect(partial(self.loadAppstream, commandProcess))
            commandProcess.start('flatpak', ['list'])
        self._processes.append(commandProcess)

    def loadAppstream(self, process=None):
        if process:
            installed_list = str(process.readAllStandardOutput(), 'utf-8')
        stream = appstream.Store()
        stream.from_file(self.appsteamPath.format(repo=self.flatHub['name'], arch=self.arch))

        for component in stream.get_components():
            if component.project_license:
                if not 'LicenseRef-proprietary' in component.project_license:
                    if not 'CC-BY-NC-SA' in component.project_license:
                        if 'Game' in component.categories or 'Games' in component.categories:
                            if process:
                                installed = component.bundle['value'][4:] in installed_list
                                setGame(component.id, installed)
                            else:
                                try:
                                    gr = getGame(component.id)
                                    installed = gr.installed
                                except DoesNotExist:
                                    installed = False

                            self.gameLoaded.emit(
                                Game(
                                    id=component.id,
                                    name=component.name,
                                    iconSmall=self.getIconSmall(component.icons),
                                    iconLarge=self.getIconLarge(component.icons),
                                    license=component.project_license,
                                    developer_name=component.developer_name,
                                    summary=component.summary,
                                    description=component.description,
                                    screenshots=self.getScreenshots(component.screenshots),
                                    releases=self.getReleases(component.releases),
                                    ref=component.bundle['value'],
                                    installed=installed
                                )
                            )
        self.finishLoading()

    def getIconSmall(self, icons):
        path = self.iconsPath.format(repo=self.flatHub['name'], arch=self.arch)
        if icons['cached'][0]['height'] == '64':
            return path + '/64x64/' + icons['cached'][0]['value']
        elif icons['cached'][1]['height'] == '64':
            return path + '/64x64/' + icons['cached'][0]['value']
        else:
            return path + '/128x128/' + icons['cached'][0]['height']['value']

    def getIconLarge(self, icons):
        path = self.iconsPath.format(repo=self.flatHub['name'], arch=self.arch)
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
