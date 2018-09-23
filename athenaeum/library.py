from functools import partial
from datetime import datetime, timedelta
import operator

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, QProcess
from PyQt5.QtQml import QQmlListProperty

from game import Game
from models import setMeta, getMeta


class Library(QObject):
    gamesChanged = pyqtSignal()
    recentChanged = pyqtSignal(list)
    newChanged = pyqtSignal(list)
    filterChanged = pyqtSignal()
    filterValueChanged = pyqtSignal()
    currentGameChanged = pyqtSignal()

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.reset()

    def load(self):
        recent = []
        new = []
        now = datetime.now()
        for game in self._games:
            if game.lastPlayedDate:
                if (game.lastPlayedDate + timedelta(days=3)) > now:
                    recent.append(game)
            if game.createdDate:
                if (game.createdDate + timedelta(days=3)) > now:
                    new.append(game)

        self.recent = recent
        self.new = new

        self.filterValue = getMeta('filter')
        self.filterGames(self.filterValue or 'all')
        self.indexUpdated(0)

    def reset(self):
        self._games = []
        self._filter = []
        self._filterValue = ''
        self._currentGame = Game()
        self._threads = []
        self._processes = []
        self._recent = []
        self._new = []

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

    @pyqtProperty(list, notify=recentChanged)
    def recent(self):
        return self._recent

    @recent.setter
    def recent(self, recent):
        if recent != self._recent:
            self._recent = recent
            self.recentChanged.emit(self._recent)

    @pyqtProperty(list, notify=newChanged)
    def new(self):
        return self._new

    @new.setter
    def new(self, new):
        if new != self._new:
            self._new = new
            self.newChanged.emit(self._new)

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

    def appendFilter(self, game):
        self._filter.append(game)
        self.filterChanged.emit()

    def appendRecent(self, game):
        if game not in self._recent:
            self._recent.append(game)
            self.recentChanged.emit(self._recent)

    def indexUpdated(self, index):
        try:
            self.currentGame = self._filter[index]
        except IndexError:
            print('Index does not exist.')

    def installGame(self, game_id):
        idx = self.findById(game_id)
        if idx is not None:
            installProcess = QProcess(parent=self.parent())
            installProcess.started.connect(self._games[idx].startInstall)
            installProcess.finished.connect(partial(self._processes.remove, installProcess))
            installProcess.finished.connect(partial(self._games[idx].finishInstall, installProcess))
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
            uninstallProcess.finished.connect(partial(self._processes.remove, uninstallProcess))
            uninstallProcess.finished.connect(partial(self._games[idx].finishUninstall, uninstallProcess))
            uninstallProcess.readyReadStandardOutput.connect(partial(self._games[idx].appendLog, uninstallProcess))
            uninstallProcess.start('flatpak', ['uninstall', self._games[idx].ref, '-y', '--user'])
            self._processes.append(uninstallProcess)

    def updateGame(self, game_id):
        idx = self.findById(game_id)
        if idx is not None:
            print('update')
            updateProcess = QProcess(parent=self.parent())
            updateProcess.started.connect(self._games[idx].startUpdate)
            updateProcess.finished.connect(partial(self._processes.remove, updateProcess))
            updateProcess.finished.connect(partial(self._games[idx].finishUpdate, updateProcess))
            updateProcess.readyReadStandardOutput.connect(partial(self._games[idx].appendLog, updateProcess))
            updateProcess.start('flatpak', ['update', self._games[idx].ref, '-y', '--user'])
            self._processes.append(updateProcess)

    def playGame(self, game_id):
        idx = self.findById(game_id)
        if idx is not None:
            playProcess = QProcess(parent=self.parent())
            playProcess.started.connect(self._games[idx].startGame)
            playProcess.finished.connect(partial(self._processes.remove, playProcess))
            playProcess.finished.connect(self._games[idx].stopGame)
            playProcess.start('flatpak', ['run', self._games[idx].ref])
            self.appendRecent(self._games[idx])
            self._processes.append(playProcess)

    def searchGames(self, query):
        if query:
            self.filterValue = 'results'
            self.filter = []
            query = query.lower()
            for game in self._games:
                if query in game.name.lower():
                    self.appendFilter(game)
        else:
            self.filterGames(self.filterValue)

    def filterGames(self, filter):
        self.filterValue = filter

        if filter == 'installed':
            self.filter = []
            for game in self._games:
                if game.installed:
                    self.appendFilter(game)
        elif filter == 'recent':
            self.filter = self.recent
        elif filter == 'new':
            self.filter = self.new
        elif filter == 'update':
            self.filter = []
            for game in self._games:
                if game.hasUpdate:
                    self.appendFilter(game)
        else:
            self.filter = self.games

        setMeta(key='filter', value=filter)

    def sortGames(self, sort):
        if sort == 'za':
            self._filter.sort(key = lambda idx: operator.attrgetter('name')(idx).lower(), reverse=True)
        else:
            self._filter.sort(key = lambda idx: operator.attrgetter('name')(idx).lower())
        self.filterChanged.emit()
