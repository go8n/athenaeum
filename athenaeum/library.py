from functools import partial
from datetime import datetime, timedelta
import operator

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, QProcess
from PyQt5.QtQml import QQmlListProperty

from game import Game
from models import setMeta, getMeta


class Library(QObject):
    gamesChanged = pyqtSignal()
    filterChanged = pyqtSignal()
    filtersChanged = pyqtSignal(list)
    filterValueChanged = pyqtSignal()
    currentGameChanged = pyqtSignal()
    errorChanged = pyqtSignal()
    displayNotification = pyqtSignal(int, str, arguments=['index', 'action'])

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.reset()

    def load(self):
        self.filterValue = getMeta('filter')

        self.sortGames()
        self.updateFilters(True)

        self.filterGames(self.filterValue or 'all')
        if not self.filter:
            self.filterGames('all')
        self.indexUpdated(0)

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
        self._currentGame = Game()
        self._threads = []
        self._processes = []
        self._error = 0

    def findById(self, game_id):
        for index, game in enumerate(self.games):
            if game.id == game_id:
                return index
        return None

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

    def appendGame(self, game):
        self._games.append(game)
        self.gamesChanged.emit()

    def indexUpdated(self, index):
        try:
            self.currentGame = self._filter[index]
        except IndexError:
            print('Index does not exist.')
    #
    # @pyqtProperty(int, notify=errorChanged)
    # def error(self):
    #     return self._error
    #
    # @error.setter
    # def error(self, error):
    #     if error != self._error:
    #         self._error = error
    #         self.errorChanged.emit()

    def processCleanup(self, process, index, action=''):
        exit_code = process.exitCode()

        if exit_code:
            action = 'error'

        if action:
            self.displayNotification.emit(index, action)

        self._processes.remove(process)

    def installGame(self, game_id):
        idx = self.findById(game_id)
        if idx is not None:
            installProcess = QProcess(parent=self.parent())
            installProcess.started.connect(self._games[idx].startInstall)
            installProcess.started.connect(self.updateFilters)
            installProcess.finished.connect(partial(self.processCleanup, installProcess, idx, 'install'))
            installProcess.finished.connect(partial(self._games[idx].finishInstall, installProcess))
            installProcess.finished.connect(self.updateFilters)
            installProcess.readyReadStandardOutput.connect(partial(self._games[idx].appendLog, installProcess))
            installProcess.start('flatpak', ['install', 'flathub', self._games[idx].ref, '-y', '--user'])
            self._processes.append(installProcess)

    def uninstallGame(self, game_id):
        print('uninstall')
        idx = self.findById(game_id)
        if idx is not None:
            print('uninstall')
            uninstallProcess = QProcess(parent=self.parent())
            uninstallProcess.started.connect(self._games[idx].startUninstall)
            uninstallProcess.started.connect(self.updateFilters)
            uninstallProcess.finished.connect(partial(self.processCleanup, uninstallProcess, idx, 'uninstall'))
            uninstallProcess.finished.connect(partial(self._games[idx].finishUninstall, uninstallProcess))
            uninstallProcess.finished.connect(self.updateFilters)
            uninstallProcess.readyReadStandardOutput.connect(partial(self._games[idx].appendLog, uninstallProcess))
            uninstallProcess.start('flatpak', ['uninstall', self._games[idx].ref, '-y', '--user'])
            self._processes.append(uninstallProcess)

    def updateGame(self, game_id):
        idx = self.findById(game_id)
        if idx is not None:
            print('update')
            updateProcess = QProcess(parent=self.parent())
            updateProcess.started.connect(self._games[idx].startUpdate)
            updateProcess.started.connect(self.updateFilters)
            updateProcess.finished.connect(partial(self.processCleanup, updateProcess, idx, 'update'))
            updateProcess.finished.connect(partial(self._games[idx].finishUpdate, updateProcess))
            updateProcess.finished.connect(self.updateFilters)
            updateProcess.readyReadStandardOutput.connect(partial(self._games[idx].appendLog, updateProcess))
            updateProcess.start('flatpak', ['update', self._games[idx].ref, '-y', '--user'])
            self._processes.append(updateProcess)

    def playGame(self, game_id):
        idx = self.findById(game_id)
        if idx is not None:
            playProcess = QProcess(parent=self.parent())
            playProcess.started.connect(self._games[idx].startGame)
            playProcess.started.connect(self.updateFilters)
            playProcess.finished.connect(partial(self.processCleanup, playProcess, idx))
            playProcess.finished.connect(partial(self._games[idx].stopGame, playProcess))
            playProcess.finished.connect(self.updateFilters)
            playProcess.readyReadStandardOutput.connect(partial(self._games[idx].appendLog, playProcess))
            playProcess.readyReadStandardError.connect(partial(self._games[idx].appendLog, playProcess))
            playProcess.start('flatpak', ['run', self._games[idx].ref])
            self._processes.append(playProcess)

    def searchGames(self, query):
        if query:
            tmp = []
            query = query.lower()
            for game in self._filter:
                if query in game.name.lower():
                    tmp.append(game)
            self.filter = tmp
        else:
            self.filterGames(self.filterValue)

    def filterGames(self, filter):
        if filter not in self._filters.keys():
            self.filterValue = 'all'
            self.filter = self.games
        else:
            self.filterValue = filter
            self.filter = self._filters[filter]

        setMeta(key='filter', value=filter)

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
        self.filterGames(self.filterValue)
        self.filtersChanged.emit(self._filters['recent'][:5] or self._filters['installed'][:5])

    def sortGames(self, sort='az'):
        if sort == 'za':
            self._games.sort(key = lambda idx: operator.attrgetter('name')(idx).lower(), reverse=True)
        else:
            self._games.sort(key = lambda idx: operator.attrgetter('name')(idx).lower())
