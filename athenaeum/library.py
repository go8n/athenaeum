from functools import partial
from datetime import datetime, timedelta
import operator

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, QProcess, pyqtSlot
from PyQt5.QtQml import QQmlListProperty

from game import Game


class Library(QObject):
    gamesChanged = pyqtSignal()
    filterChanged = pyqtSignal()
    filtersChanged = pyqtSignal(list)
    filterValueChanged = pyqtSignal()
    searchValueChanged = pyqtSignal()
    currentIndexChanged = pyqtSignal()
    currentGameChanged = pyqtSignal()
    errorChanged = pyqtSignal()
    displayNotification = pyqtSignal(int, str, arguments=['index', 'action'])

    def __init__(self, flatpak=False, metaRepository=None, gameRepository=None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._flatpak = flatpak
        self._metaRepository = metaRepository
        self._gameRepository = gameRepository
        self.reset()

    def load(self):
        self.filterValue = self._metaRepository.get('filter')
        self.sortGames()
        self.updateFilters(new_load=True)
        self.indexUpdated()
        print('load')

    def reset(self):
        self._games = []
        self._filter = []
        self._filters = {
            'installed': [],
            'recent': [],
            'new': [],
            'has_updates': [],
            'processing': []
        }
        self._filterValue = ''
        self._searchValue = ''
        self._currentIndex = 0
        self._currentGame = Game()
        self._threads = []
        self._processes = []
        self._error = 0

    @pyqtSlot(result=int)
    def getIndexForCurrentGame(self):
        for index, game in enumerate(self._filter):
            if game.id == self._currentGame.id:
                return index
            
        if not self._currentGame.id:
            return 0
        return -1


    def findById(self, game_id):
        for index, game in enumerate(self._games):
            if game.id == game_id:
                return index
        return None

    @pyqtProperty(int, notify=currentIndexChanged)
    def currentIndex(self):
        return self._currentIndex

    @currentIndex.setter
    def currentIndex(self, game):
        if game != self._currentIndex:
            self._currentIndex = game
            self.currentIndexChanged.emit()

    @pyqtProperty(Game, notify=currentGameChanged)
    def currentGame(self):
        return self._currentGame

    @currentGame.setter
    def currentGame(self, game):
        if game != self._currentGame:
            self._currentGame = game
            self.currentGameChanged.emit()

    @pyqtProperty(list, notify=gamesChanged)
    def games(self):
        return self._games

    @games.setter
    def games(self, games):
        if games != self._games:
            self._games = games
            self.gamesChanged.emit()

    @pyqtProperty(int, notify=filtersChanged)
    def recentCount(self):
        return len(self._filters['recent'])

    @pyqtProperty(int, notify=filtersChanged)
    def newCount(self):
        return len(self._filters['new'])

    @pyqtProperty(int, notify=filtersChanged)
    def hasUpdatesCount(self):
        return len(self._filters['has_updates'])

    @pyqtProperty(int, notify=filtersChanged)
    def installedCount(self):
        return len(self._filters['installed'])

    @pyqtProperty(int, notify=filtersChanged)
    def processingCount(self):
        return len(self._filters['processing'])

    @pyqtProperty(QQmlListProperty, notify=filterChanged)
    def filter(self):
        return QQmlListProperty(Game, self, self._filter)

    @filter.setter
    def filter(self, filter):
        if filter != self._filter:
            self._filter = filter
            self.filterChanged.emit()

    @pyqtProperty('QString', notify=filterValueChanged)
    def filterValue(self):
        return self._filterValue

    @filterValue.setter
    def filterValue(self, filterValue):
        if filterValue != self._filterValue:
            self._filterValue = filterValue
            self.filterValueChanged.emit()

    @pyqtProperty('QString', notify=searchValueChanged)
    def searchValue(self):
        return self._searchValue

    @searchValue.setter
    def searchValue(self, searchValue):
        if searchValue != self._searchValue:
            self._searchValue = searchValue
            self.searchValueChanged.emit()

    def appendGame(self, game):
        self._games.append(game)
        self.gamesChanged.emit()

    def indexUpdated(self):
        try:
            self.currentGame = self._filter[self.currentIndex]
        except IndexError:
            print('Index does not exist.')

    def processCleanup(self, process, index, action=None):
        if action:
            self.displayNotification.emit(index, action)

        self._processes.remove(process)

    def installGame(self, game_id):
        idx = self.findById(game_id)
        if idx is not None:
            installProcess = QProcess(parent=self.parent())
            installProcess.started.connect(partial(self.installStarted, idx))
            installProcess.started.connect(self.updateFilters)
            installProcess.finished.connect(partial(self.installFinished, installProcess, idx))
            installProcess.finished.connect(self.updateFilters)
            installProcess.readyReadStandardOutput.connect(partial(self._games[idx].appendLog, installProcess))
            installProcess.readyReadStandardError.connect(partial(self._games[idx].appendLog, installProcess))
            if self._flatpak:
                installProcess.start('flatpak-spawn', ['--host', 'flatpak', 'install', 'flathub', self._games[idx].ref, '-y', '--user'])
            else:
                installProcess.start('flatpak', ['install', 'flathub', self._games[idx].ref, '-y', '--user'])
            self._processes.append(installProcess)

    def installStarted(self, index):
        self._games[index].processing = True

    def installFinished(self, process, index):
        self._games[index].processing = False

        if process.exitCode():
            action = 'error'
            self._games[index].error = True
        else:
            action = 'install'
            self._games[index].error = False
            self._games[index].installed = True

        self._games[index].appendLog(process, finished=True)
        self._gameRepository.set(self._games[index])
        self.processCleanup(process, index, action)

    def uninstallGame(self, game_id):
        idx = self.findById(game_id)
        if idx is not None:
            print('uninstall')
            uninstallProcess = QProcess(parent=self.parent())
            uninstallProcess.started.connect(partial(self.uninstallStarted, idx))
            uninstallProcess.started.connect(self.updateFilters)
            uninstallProcess.finished.connect(partial(self.uninstallFinishd, uninstallProcess, idx))
            uninstallProcess.finished.connect(self.updateFilters)
            uninstallProcess.readyReadStandardOutput.connect(partial(self._games[idx].appendLog, uninstallProcess))
            uninstallProcess.readyReadStandardError.connect(partial(self._games[idx].appendLog, uninstallProcess))
            if self._flatpak:
                uninstallProcess.start('flatpak-spawn', ['--host', 'flatpak', 'uninstall', self._games[idx].ref, '-y', '--user'])
            else:
                uninstallProcess.start('flatpak', ['uninstall', self._games[idx].ref, '-y', '--user'])
            self._processes.append(uninstallProcess)

    def uninstallStarted(self, index):
        self._games[index].processing = True

    def uninstallFinishd(self, process, index):
        self._games[index].processing = False

        if process.exitCode():
            action = 'error'
            self._games[index].error = True
        else:
            action = 'uninstall'
            self._games[index].error = False
            self._games[index].installed = False

        self._games[index].appendLog(process, finished=True)
        self._gameRepository.set(self._games[index])
        self.processCleanup(process, index, action)

    def updateGame(self, game_id):
        idx = self.findById(game_id)
        if idx is not None:
            print('update')
            updateProcess = QProcess(parent=self.parent())
            updateProcess.started.connect(partial(self.startUpdate, index))
            updateProcess.started.connect(self.updateFilters)
            updateProcess.finished.connect(partial(self.updateFinished, updateProcess, index))
            updateProcess.finished.connect(self.updateFilters)
            updateProcess.readyReadStandardOutput.connect(partial(self._games[idx].appendLog, updateProcess))
            updateProcess.readyReadStandardError.connect(partial(self._games[idx].appendLog, updateProcess))
            if self._flatpak:
                updateProcess.start('flatpak-spawn', ['--host', 'flatpak', 'update', self._games[idx].ref, '-y', '--user'])
            else:
                updateProcess.start('flatpak', ['update', self._games[idx].ref, '-y', '--user'])
            self._processes.append(updateProcess)

    def updateStarted(self, index):
        self._games[index].processing = True

    def updateFinished(self, process, index):
        self._games[index].processing = False

        if process.exitCode():
            action = 'error'
            self._games[index].error = True
        else:
            action = 'update'
            self._games[index].error = False
            self._games[index].hasUpdate = False

        self._games[index].appendLog(process, finished=True)
        self._gameRepository.set(self._games[index])
        self.processCleanup(process, index, action)

    def playGame(self, game_id):
        idx = self.findById(game_id)
        if idx is not None:
            playProcess = QProcess(parent=self.parent())
            playProcess.started.connect(partial(self.startGame, idx))
            playProcess.started.connect(self.updateFilters)
            playProcess.finished.connect(partial(self.stopGame, playProcess, idx))
            playProcess.finished.connect(self.updateFilters)
            playProcess.readyReadStandardOutput.connect(partial(self._games[idx].appendLog, playProcess))
            playProcess.readyReadStandardError.connect(partial(self._games[idx].appendLog, playProcess))
            if self._flatpak:
                playProcess.start('flatpak-spawn', ['--host', 'flatpak', 'run', self._games[idx].ref])
            else:
                playProcess.start('flatpak', ['run', self._games[idx].ref])
            self._processes.append(playProcess)

    def startGame(self, index):
        self._games[index].playing = True
        self._games[index].lastPlayedDate = datetime.now()

    def stopGame(self, process, index):
        self._games[index].playing = False
        self._games[index].lastPlayedDate = datetime.now()
        self._games[index].appendLog(process, finished=True)
        self._gameRepository.set(self._games[index])
        self.processCleanup(process, index)

    def searchGames(self):
        if self.searchValue:
            tmp = []
            query = self.searchValue.lower()
            if self.filterValue == 'all':
                for game in self._games:
                    if query in game.name.lower():
                        tmp.append(game)
            else:
                for game in self._filters[self.filterValue]:
                    if query in game.name.lower():
                        tmp.append(game)
            self.filter = tmp
        else:
            self.filterGames()

    def filterGames(self, override=False):
        if override or self.filterValue == 'all' or self.filterValue not in self._filters.keys():
            self.filterValue = 'all'
            self.filter = self._games
        else:
            self.filter = self._filters[self.filterValue]

        self._metaRepository.set(key='filter', value=self.filterValue)

    def updateFilters(self, new_load=False):
        filters = {
            'installed': [],
            'recent': [],
            'new': [] if new_load else self._filters['new'],
            'has_updates': [],
            'processing': []
        }

        now = datetime.now()
        for game in self._games:
            if game.installed:
                filters['installed'].append(game)
            if game.processing:
                filters['processing'].append(game)
            if game.hasUpdate:
                filters['has_updates'].append(game)
            if game.lastPlayedDate:
                if (game.lastPlayedDate + timedelta(days=3)) > now:
                    filters['recent'].append(game)
            if game.createdDate and new_load:
                if (game.createdDate + timedelta(days=3)) > now:
                    filters['new'].append(game)

        self._filters = filters
        self.filterGames()
        self.searchGames()
        self.filtersChanged.emit(self._filters['recent'][:5] or self._filters['installed'][:5])

    def sortGames(self, sort='az'):
        if sort == 'za':
            self._games.sort(key = lambda idx: operator.attrgetter('name')(idx).lower(), reverse=True)
        else:
            self._games.sort(key = lambda idx: operator.attrgetter('name')(idx).lower())
