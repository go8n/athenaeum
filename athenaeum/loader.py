import random, platform
from abc import ABC, ABCMeta, abstractmethod
from datetime import datetime, timedelta
from functools import partial
import time

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, QProcess, QTimer, QStandardPaths

import appstream
from game import Game, Screenshot, Release, Url
from lists import alwaysAccept, alwaysDeny, badLicenses, badCategories, loadingMessages, nonFreeAssets

class LoaderFactory(QObject):
    def __init__(self, inFlatpak=False, db=None, metaRepository=None, gameRepository=None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._inFlatpak = inFlatpak
        self._db = db
        self._metaRepository = metaRepository
        self._gameRepository = gameRepository

    def create(self):
        if platform.system() == 'Linux':
            return GNULoader(self._inFlatpak, self._db, self._metaRepository, self._gameRepository)
        if platform.system() == 'Darwin':
            return DarwinLoader(self._db, self._metaRepository, self._gameRepository)


class LoaderMeta(type(QObject), ABCMeta):
    pass

class Loader(QObject, metaclass=LoaderMeta):
    @abstractmethod
    def load(self):
        pass

    @abstractmethod
    def reset(self):
        pass

    @abstractmethod
    def runUpdateCommands(self, proc_number=0):
        pass

    @abstractmethod
    def runListCommands(self, proc_number=0):
        pass

    @property
    @abstractmethod
    def loading(self):
        pass

    @property
    @abstractmethod
    def error(self):
        pass

    @property
    @abstractmethod
    def log(self):
        pass

    @property
    @abstractmethod
    def message(self):
        pass

    @abstractmethod
    def getRef(self, component):
        pass

    def loadAppstream(self, process=None):
        stream = appstream.Store()
        stream.from_file(self._appsteamPath)

        game_sizes = {}
        for line in self._sizes_list.splitlines():
            game_size = line.split('\t')
            game_sizes[game_size[0]] = game_size

        for component in stream.get_components():
            component.id = (component.id[:-8] if component.id.endswith('.desktop') else component.id)
            if self.acceptedGame(component):
                installed = False
                has_update = False
                download_size = None
                installed_size = None
                last_played_date = None
                created_date = None
                antiFeatures = []
                if component.id in nonFreeAssets:
                    antiFeatures.append('assets')

                if process:
                    installed = component.id in self._installed_list
                    has_update = component.id.split('/')[0] in self._updates_list
                    download_size = game_sizes[component.id][1]
                    installed_size = game_sizes[component.id][2]

                gr = self._gameRepository.get(component.id)
                if gr:
                    if not process:
                        installed = gr['installed']
                        has_update = gr['has_update']
                        download_size = gr['download_size']
                        installed_size = gr['installed_size']

                    last_played_date = gr['last_played_date']
                    created_date = gr['created_date']
                else:
                    created_date = datetime.now()
                urls = self.getUrls(component.urls)
                urls.append(Url(type='manifest', url=self.flatHub['git'] + '/' + (component.id[:-8] if component.id.endswith('.desktop') else component.id)))

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
                    tags=self.collateTags(self.cleanCategories(component.categories), component.keywords),
                    antiFeatures=antiFeatures,
                    releases=self.getReleases(component.releases),
                    urls=urls,
                    ref=self.getRef(component),
                    installed=installed,
                    hasUpdate=has_update,
                    lastPlayedDate=last_played_date,
                    createdDate=created_date,
                    downloadSize=download_size,
                    installedSize=installed_size
                )

                if process:
                    self._gameRepository.set(game=game)

                self.gameLoaded.emit(game)

        self.finishLoading()

    def cleanCategories(self, categories):
        transfer = []
        for category in categories:
            result = category.replace('Game', '')
            if result:
                transfer.append(result)
        return transfer

    def collateTags(self, categories, keywords):
        if keywords:
            return categories + keywords['en']
        else:
            return categories

    def getIconSmall(self, icons):
        path = self._iconsPath
        if icons:
            if icons['cached'][0]['height'] == '64':
                return path + '/64x64/' + icons['cached'][0]['value']
            elif icons['cached'][1]['height'] == '64':
                return path + '/64x64/' + icons['cached'][0]['value']
            else:
                return path + '/128x128/' + icons['cached'][0]['height']['value']
        else:
            return ''

    def getIconLarge(self, icons):
        path = self._iconsPath
        if icons:
            cached_icon = icons['cached'][0]
            if cached_icon['height'] == '128':
                return path + '/128x128/' + cached_icon['value']
            elif cached_icon['height'] == '64':
                return path + '/64x64/' + cached_icon['value']
        else:
            return ''

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

    def getUrls(self, urls):
        transfer = []
        for type, url in urls.items():
            transfer.append(Url(type=type, url=url))
        return transfer
    
    def acceptedGame(self, component=None):
        if component.id in alwaysAccept:
            return True
        if component.id in alwaysDeny:
            return False

        return component.project_license and \
            not [x for x in badLicenses if x in component.project_license] and \
            'Game' in component.categories and \
            not [x for x in badCategories if x in component.categories]

class DarwinLoader(Loader):
    finished = pyqtSignal()
    started = pyqtSignal()
    stateChanged = pyqtSignal()
    messageChanged = pyqtSignal()
    errorChanged = pyqtSignal()
    logChanged = pyqtSignal()
    gameLoaded = pyqtSignal(Game)


    def __init__(self, db=None, metaRepository=None, gameRepository=None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._db = db
        self._metaRepository = metaRepository
        self._gameRepository = gameRepository
        self._loading = True
        self._error = False
        self._processes = []
        self._timer = QTimer()
        self._timer.timeout.connect(self.changeMessage)
        self._message = random.choice(loadingMessages)
        self._log = ''

        self._appsteamPath = 'https://flathub.org/repo/appstream/x86_64/appstream.xml.gz'
        self._iconsPath = 'https://flathub.org/repo/appstream/x86_64/icons'
        self._iconsPath

        self._installed_list = ''
        self._updates_list = ''
        self._sizes_list = ''

    def changeMessage(self):
        self.message = random.choice(loadingMessages)

    def load(self):
        self.loadAppstream()

    def getRef(self, component):
        return 'test'

    def reset(self):
        pass

    def runUpdateCommands(self, proc_number=0):
        pass

    def runListCommands(self, proc_number=0):
        pass

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

    def startLoading(self):
        self.loading = True
        self._timer.start(3000)
        self.started.emit()

    def finishLoading(self):
        self.loading = False
        self.finished.emit()

class GNULoader(Loader):
    finished = pyqtSignal()
    started = pyqtSignal()
    stateChanged = pyqtSignal()
    messageChanged = pyqtSignal()
    errorChanged = pyqtSignal()
    logChanged = pyqtSignal()
    gameLoaded = pyqtSignal(Game)

    arch = platform.machine()

    metaKey = 'flathub_added'

    flatHub = {'name':'flathub', 'url':'https://flathub.org/repo/flathub.flatpakrepo', 'git':'https://github.com/flathub'}


    def __init__(self, inFlatpak=False, db=None, metaRepository=None, gameRepository=None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._inFlatpak = inFlatpak
        self._db = db
        self._metaRepository = metaRepository
        self._gameRepository = gameRepository
        self._loading = True
        self._error = False
        self._processes = []
        self._timer = QTimer()
        self._timer.timeout.connect(self.changeMessage)
        self._message = random.choice(loadingMessages)
        self._appsteamPath = QStandardPaths.writableLocation(QStandardPaths.GenericDataLocation) + '/flatpak/appstream/{remote}/{arch}/active/appstream.xml.gz'
        self._appsteamPath = self._appsteamPath.format(remote=self.flatHub['name'], arch=self.arch)
        self._iconsPath = QStandardPaths.writableLocation(QStandardPaths.GenericDataLocation) + '/flatpak/appstream/{remote}/{arch}/active/icons'
        self._iconsPath = self._iconsPath.format(remote=self.flatHub['name'], arch=self.arch)
        self._log = ''

        self._installed_list = ''
        self._updates_list = ''
        self._sizes_list = ''

    def load(self):
        if self._metaRepository.get(self.metaKey):
            self.loadAppstream()
        else:
            self.runUpdateCommands()

    def reset(self):
        self._db.erase()
        self._db.init()
        self.runUpdateCommands()

    def runUpdateCommands(self, proc_number=0):
        commandProcess = QProcess()
        commandProcess.finished.connect(partial(self._processes.remove, commandProcess))
        commandProcess.errorOccurred.connect(self.handleError)
        commandProcess.readyReadStandardOutput.connect(partial(self.appendLog, commandProcess))
        if proc_number == 0:
            commandProcess.started.connect(self.startLoading)
            commandProcess.finished.connect(partial(self.runUpdateCommands, 1))
            if self._inFlatpak:
                commandProcess.start('flatpak-spawn', ['--host', 'flatpak', 'remote-add', '--if-not-exists', '--user', self.flatHub['name'], self.flatHub['url']])
            else:
                commandProcess.start('flatpak', ['remote-add', '--if-not-exists', '--user', self.flatHub['name'], self.flatHub['url']])
        elif proc_number == 1:
            commandProcess.finished.connect(partial(self.runUpdateCommands, 2))
            if self._inFlatpak:
                commandProcess.start('flatpak-spawn', ['--host', 'flatpak', 'update', '--appstream', '--user'])
            else:
                commandProcess.start('flatpak', ['update', '--appstream', '--user'])
        elif proc_number == 2:
            commandProcess.finished.connect(self.runListCommands)
            if self._inFlatpak:
                commandProcess.start('flatpak-spawn', ['--host', 'flatpak', 'update', '--user', '-y'])
            else:
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
            if self._inFlatpak:
                commandProcess.start('flatpak-spawn', ['--host', 'flatpak', 'list', '--user', '--app', '--columns=application'])
            else:
                commandProcess.start('flatpak', ['list', '--user', '--app', '--columns=application'])
        if proc_number == 1:
            commandProcess.finished.connect(partial(self.runListCommands, 2))
            commandProcess.finished.connect(partial(self.loadListData, commandProcess, proc_number))
            if self._inFlatpak:
                commandProcess.start('flatpak-spawn', ['--host', 'flatpak', 'remote-ls', '--updates', '--user', '--app', '--columns=application'])
            else:
                commandProcess.start('flatpak', ['remote-ls', '--updates', '--user', '--app', '--columns=application'])
        if proc_number == 2:
            commandProcess.finished.connect(partial(self.loadListData, commandProcess, proc_number))
            if self._inFlatpak:
                commandProcess.start('flatpak-spawn', ['--host', 'flatpak', 'remote-ls', '--user', '--app', '--columns=application,download-size,installed-size'])
            else:
                commandProcess.start('flatpak', ['remote-ls', '--user', '--app', '--columns=application,download-size,installed-size'])
        self._processes.append(commandProcess)

    def loadListData(self, process, proc_number):
        if proc_number == 0:
            self._installed_list = str(process.readAllStandardOutput(), 'utf-8')
        if proc_number == 1:
            self._updates_list = str(process.readAllStandardOutput(), 'utf-8')
        if proc_number == 2:
            self._sizes_list = str(process.readAllStandardOutput(), 'utf-8')
            self.loadAppstream(process=True)

    def getRef(self, component):
        return component.bundle['value']

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
        self.message = random.choice(loadingMessages)

    def startLoading(self):
        self.loading = True
        self._timer.start(3000)
        self.started.emit()

    def finishLoading(self):
        self._metaRepository.set(self.metaKey, 'y')
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
