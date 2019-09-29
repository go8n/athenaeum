from functools import partial
from datetime import datetime, timedelta
import operator

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, QProcess, pyqtSlot
from PyQt5.QtQml import QQmlListProperty


from game import Game


class GameManager(QObject):
    ready = pyqtSignal()
    displayNotification = pyqtSignal(str, str, str, arguments=['header', 'message', 'icon'])
    
    def __init__(self, inFlatpak=False, gameRepository=None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._inFlatpak = inFlatpak
        self._gameRepository = gameRepository
        self.reset()
        
    def load(self):
        self.sortGames()
        self.ready.emit()

    def reset(self):
        self._games = []
        self._threads = []
        self._processes = {}

    def games(self):
        return self._games

    def appendGame(self, game):
        self._games.append(game)
        
    @pyqtSlot(str, result=int)
    def findIndexById(self, game_id):
        for index, game in enumerate(self._games):
            if game.id == game_id:
                return index
        return None
    
    def getGameById(self, id):
        for game in self._games:
            if game.id == id:
                return game
        return None
        
    @pyqtSlot(int, result=Game)
    def findByIndex(self, index):
        return self._games[index]

    def processCancel(self, game_id):
        index = self.findIndexById(game_id)
        if len(self._processes[self._games[index].id]):
            process = self._processes[self._games[index].id][0]
            process.finished.disconnect()
            process.terminate()
            self._games[index].processing = False
            self.processCleanup(process, index, 'cancel')
    
    def processCleanup(self, process, index, action=None):
        if action and action != 'cancel':
            message = ''
            if action == 'install':
                message = 'Installed successfully.'
            if action == 'uninstall':
                message = 'Uninstalled successfully.'
            if action == 'update':
                message = 'Updated successfully.'
            if action == 'error':
                message = 'An error occurred.'
            self.displayNotification.emit(self._games[index].name, message, self._games[index].iconLarge)

        self._processes[self._games[index].id].remove(process)
        if len(self._processes[self._games[index].id]) == 0:
            del self._processes[self._games[index].id]

    def recordProcess(self, game_id, process):
        if not game_id in self._processes:
            self._processes[game_id] = []
        self._processes[game_id].append(process)

    def installGame(self, game_id, startedCallback=None, finishedCallback=None):
        index = self.findIndexById(game_id)
        if index is not None:
            process = QProcess(parent=self.parent())
            process.started.connect(partial(self.installStarted, index, startedCallback))
            process.finished.connect(partial(self.installFinished, process, index, finishedCallback))
            process.readyReadStandardOutput.connect(partial(self._games[index].appendLog, process))
            process.readyReadStandardError.connect(partial(self._games[index].appendLog, process))
            if self._inFlatpak:
                process.start('flatpak-spawn', ['--host', 'flatpak', 'install', 'flathub', self._games[index].ref, '-y', '--user'])
            else:
                process.start('flatpak', ['install', 'flathub', self._games[index].ref, '-y', '--user'])
            self.recordProcess(game_id, process)

    def installStarted(self, index, callback=None):
        self._games[index].processing = True
        if callback: callback()

    def installFinished(self, process, index, callback=None):
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
        if callback: callback()

    def uninstallGame(self, game_id, startedCallback=None, finishedCallback=None):
        index = self.findIndexById(game_id)
        if index is not None:
            process = QProcess(parent=self.parent())
            process.started.connect(partial(self.uninstallStarted, index, startedCallback))
            process.finished.connect(partial(self.uninstallFinishd, process, index, finishedCallback))
            process.readyReadStandardOutput.connect(partial(self._games[index].appendLog, process))
            process.readyReadStandardError.connect(partial(self._games[index].appendLog, process))
            if self._inFlatpak:
                process.start('flatpak-spawn', ['--host', 'flatpak', 'uninstall', self._games[index].ref, '-y', '--user'])
            else:
                process.start('flatpak', ['uninstall', self._games[index].ref, '-y', '--user'])
            self.recordProcess(game_id, process)

    def uninstallStarted(self, index, callback=None):
        self._games[index].processing = True
        if callback: callback()

    def uninstallFinishd(self, process, index, callback=None):
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
        if callback: callback()

    def updateGame(self, game_id, startedCallback=None, finishedCallback=None):
        index = self.findIndexById(game_id)
        if index is not None:
            print('update')
            process = QProcess(parent=self.parent())
            process.started.connect(partial(self.startUpdate, index))
            process.finished.connect(partial(self.updateFinished, process, index))
            process.readyReadStandardOutput.connect(partial(self._games[index].appendLog, process))
            process.readyReadStandardError.connect(partial(self._games[index].appendLog, process))
            if self._inFlatpak:
                process.start('flatpak-spawn', ['--host', 'flatpak', 'update', self._games[index].ref, '-y', '--user'])
            else:
                process.start('flatpak', ['update', self._games[index].ref, '-y', '--user'])
            self.recordProcess(game_id, process)

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

    def playGame(self, game_id, startedCallback=None, finishedCallback=None):
        index = self.findIndexById(game_id)
        if index is not None:
            process = QProcess(parent=self.parent())
            process.started.connect(partial(self.startGame, index, startedCallback))
            process.finished.connect(partial(self.stopGame, process, index, finishedCallback))
            process.readyReadStandardOutput.connect(partial(self._games[index].appendLog, process))
            process.readyReadStandardError.connect(partial(self._games[index].appendLog, process))
            if self._inFlatpak:
                process.start('flatpak-spawn', ['--host', 'flatpak', 'run', self._games[index].ref])
            else:
                process.start('flatpak', ['run', self._games[index].ref])
            self.recordProcess(game_id, process)

    def startGame(self, index, callback):
        self._games[index].playing = True
        self._games[index].lastPlayedDate = datetime.now()
        if callback: callback()

    def stopGame(self, process, index, callback):
        self._games[index].playing = False
        self._games[index].lastPlayedDate = datetime.now()
        self._games[index].appendLog(process, finished=True)
        self._gameRepository.set(self._games[index])
        self.processCleanup(process, index)
        if callback: callback()

    def sortGames(self, sort='az'):
        if sort == 'za':
            self._games.sort(key = lambda index: operator.attrgetter('name')(index).lower(), reverse=True)
        else:
            self._games.sort(key = lambda index: operator.attrgetter('name')(index).lower())

    def markInstalled(self, game_id):
        game = self.getGameById(game_id)
        game.installed = True
        self._gameRepository.set(game)
        self.clearErrors(game_id)

    def markUninstalled(self, game_id):
        game = self.getGameById(game_id)
        game.installed = False
        self._gameRepository.set(game)
        self.clearErrors(game_id)

    def clearErrors(self, game_id):
        game = self.getGameById(game_id)
        game.error = False
        # self._gameRepository.set(game)