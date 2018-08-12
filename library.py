from time import sleep
from functools import partial
from datetime import datetime, timedelta
import operator

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, QProcess
from PyQt5.QtQml import QQmlListProperty

from game import Game
import appstream


class Library(QObject):
    gamesChanged = pyqtSignal()
    recentChanged = pyqtSignal(list)
    filterChanged = pyqtSignal()
    currentGameChanged = pyqtSignal()

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self._games = []
        self._filter = []
        self._currentGame = Game()
        self._threads = []
        self._processes = []
        self._recent = []

    def load(self):
        self.filter = self.games
        self.indexUpdated(0)

        recent = []
        now = datetime.now()
        for game in self._games:
            if game.lastPlayedDate:
                if (game.lastPlayedDate + timedelta(days=3)) > now:
                    recent.append(game)
        self.recent = recent

    def reset(self):
        self._games = []
        self._filter = []
        self._currentGame = Game()
        self._threads = []
        self._processes = []
        self._recent = []

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

    @pyqtProperty(QQmlListProperty, notify=filterChanged)
    def filter(self):
        return QQmlListProperty(Game, self, self._filter)

    @filter.setter
    def filter(self, filter):
        if filter != self._filter:
            self._filter = filter
            self.filterChanged.emit()

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

    def search(self, query):
        if query:
            self.filter = []
            query = query.lower()
            for game in self._games:
                if query in game.name.lower():
                    self.appendFilter(game)
        else:
            self.filter = self.games

    def filterAll(self):
        self.filter = self.games

    def filterInstalled(self):
        self.filter = []
        for game in self._games:
            if game.installed:
                self.appendFilter(game)

    def filterRecent(self):
        self.filter = self.recent

    def sortAZ(self):
        self._filter.sort(key = lambda idx: operator.attrgetter('name')(idx).lower())
        self.filterChanged.emit()

    def sortZA(self):
        self._filter.sort(key = lambda idx: operator.attrgetter('name')(idx).lower(), reverse=True)
        self.filterChanged.emit()
