from time import sleep
from functools import partial

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, QProcess
from PyQt5.QtQml import QQmlListProperty

from peewee import DoesNotExist
from models import GameRecord

from game import Game
import appstream


class Library(QObject):
    gamesChanged = pyqtSignal()
    filterChanged = pyqtSignal()
    currentGameChanged = pyqtSignal()
    logChanged = pyqtSignal()

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self._games = []
        self._filter = []
        self._currentGame = Game()
        self._log = ''
        self._threads = []
        self._processes = []

        stream = appstream.Store()
        stream.from_file('/var/lib/flatpak/appstream/flathub/x86_64/active/appstream.xml.gz')

        for component in stream.get_components():
            if component.project_license and not 'LicenseRef-proprietary' in component.project_license:
                if 'Game' in component.categories:
                    try:
                        gr = GameRecord.get(GameRecord.id == component.id)
                    except DoesNotExist:
                        gr = None
                    self.appendGame(Game(component.id, component.name, self.getIcon(component.icons), component.bundle['value'], gr.installed if gr else False))

        self._currentGame = self._games[0]
        self.filter = self.games

    def getIcon(self, icons):
        cached_icon = icons['cached'][0]
        if cached_icon['height'] == '128':
            return '/var/lib/flatpak/appstream/flathub/x86_64/active/icons/128x128/' + cached_icon['value']
        elif cached_icon['height'] == '64':
            return '/var/lib/flatpak/appstream/flathub/x86_64/active/icons/64x64/' + cached_icon['value']

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

    @pyqtProperty(str, notify=logChanged)
    def log(self):
        return self._log

    @log.setter
    def log(self, data):
        if data:
            self._log += data
            self.logChanged.emit()

    @pyqtProperty(list, notify=gamesChanged)
    def games(self):
        return self._games

    @games.setter
    def games(self, games):
        if games != self._games:
            self._games = games
            self.gamesChanged.emit()

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

    def indexUpdated(self, index):
        try:
            self.currentGame = self._filter[index]
        except IndexError:
            print('Index does not exist.')    


    def installGame(self, game_id):
        idx = self.findById(game_id)
        if idx is not None:
            installProcess = QProcess()
            installProcess.started.connect(self._games[idx].startInstall)
            installProcess.finished.connect(partial(self._games[idx].finishInstall, installProcess))
            installProcess.readyReadStandardOutput.connect(partial(self._games[idx].appendLog, installProcess))
            installProcess.start('flatpak', ['install', 'flathub', self._games[idx].ref, '-y'])
            self._processes.append(installProcess)

    def uninstallGame(self, game_id):
        print('uninstall')
        idx = self.findById(game_id)
        if idx is not None:
            print('uninstall')
            uninstallProcess = QProcess()
            uninstallProcess.started.connect(self._games[idx].startUninstall)
            uninstallProcess.finished.connect(partial(self._games[idx].finishUninstall, uninstallProcess))
            uninstallProcess.readyReadStandardOutput.connect(partial(self._games[idx].appendLog, uninstallProcess))
            uninstallProcess.start('flatpak', ['uninstall', self._games[idx].ref, '-y'])
            self._processes.append(uninstallProcess)

    def updateGame(self, game_id):
        idx = self.findById(game_id)
        if idx is not None:
            print('update')
            updateProcess = QProcess()
            updateProcess.started.connect(self._games[idx].startUpdate)
            updateProcess.finished.connect(partial(self._games[idx].finishUpdate, updateProcess))
            updateProcess.readyReadStandardOutput.connect(partial(self._games[idx].appendLog, updateProcess))
            updateProcess.start('flatpak', ['update', self._games[idx].ref, '-y'])
            self._processes.append(updateProcess)

    def playGame(self, game_id):
        idx = self.findById(game_id)
        if idx is not None:
            playProcess = QProcess()
            playProcess.started.connect(self._games[idx].startGame)
            playProcess.finished.connect(self._games[idx].stopGame)
            playProcess.start('flatpak', ['run', self._games[idx].ref])
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

    def updateLibrary(self):
        pass
