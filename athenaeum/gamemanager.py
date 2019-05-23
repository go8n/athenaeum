from functools import partial
from datetime import datetime, timedelta
import operator
from game import Game


class GameManager():
    def __init__(self, flatpak=False, gameRepository=None):
        self._flatpak = flatpak
        self._gameRepository = gameRepository
        self.reset()
        
    def load(self):
        pass
        #self.sortGames()

    def reset(self):
        self._games = []
        self._threads = []
        self._processes = []

    def games(self):
        return self._games

    def appendGame(self, game):
        self._games.append(game)

    def processCleanup(self, process, index, action=None):
        if action:
            self.displayNotification.emit(index, action)
        self._processes.remove(process)

    def installGame(self, game_id):
        index = self.findById(game_id)
        if index is not None:
            installProcess = QProcess(parent=self.parent())
            installProcess.started.connect(partial(self.installStarted, index))
            installProcess.finished.connect(partial(self.installFinished, installProcess, index))
            installProcess.readyReadStandardOutput.connect(partial(self._games[index].appendLog, installProcess))
            installProcess.readyReadStandardError.connect(partial(self._games[index].appendLog, installProcess))
            if self._flatpak:
                installProcess.start('flatpak-spawn', ['--host', 'flatpak', 'install', 'flathub', self._games[index].ref, '-y', '--user'])
            else:
                installProcess.start('flatpak', ['install', 'flathub', self._games[index].ref, '-y', '--user'])
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
        index = self.findById(game_id)
        if index is not None:
            print('uninstall')
            uninstallProcess = QProcess(parent=self.parent())
            uninstallProcess.started.connect(partial(self.uninstallStarted, index))
            uninstallProcess.finished.connect(partial(self.uninstallFinishd, uninstallProcess, index))
            uninstallProcess.readyReadStandardOutput.connect(partial(self._games[index].appendLog, uninstallProcess))
            uninstallProcess.readyReadStandardError.connect(partial(self._games[index].appendLog, uninstallProcess))
            if self._flatpak:
                uninstallProcess.start('flatpak-spawn', ['--host', 'flatpak', 'uninstall', self._games[index].ref, '-y', '--user'])
            else:
                uninstallProcess.start('flatpak', ['uninstall', self._games[index].ref, '-y', '--user'])
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
        index = self.findById(game_id)
        if index is not None:
            print('update')
            updateProcess = QProcess(parent=self.parent())
            updateProcess.started.connect(partial(self.startUpdate, index))
            updateProcess.finished.connect(partial(self.updateFinished, updateProcess, index))
            updateProcess.readyReadStandardOutput.connect(partial(self._games[index].appendLog, updateProcess))
            updateProcess.readyReadStandardError.connect(partial(self._games[index].appendLog, updateProcess))
            if self._flatpak:
                updateProcess.start('flatpak-spawn', ['--host', 'flatpak', 'update', self._games[index].ref, '-y', '--user'])
            else:
                updateProcess.start('flatpak', ['update', self._games[index].ref, '-y', '--user'])
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
        index = self.findById(game_id)
        if index is not None:
            playProcess = QProcess(parent=self.parent())
            playProcess.started.connect(partial(self.startGame, index))
            playProcess.finished.connect(partial(self.stopGame, playProcess, index))
            playProcess.readyReadStandardOutput.connect(partial(self._games[index].appendLog, playProcess))
            playProcess.readyReadStandardError.connect(partial(self._games[index].appendLog, playProcess))
            if self._flatpak:
                playProcess.start('flatpak-spawn', ['--host', 'flatpak', 'run', self._games[index].ref])
            else:
                playProcess.start('flatpak', ['run', self._games[index].ref])
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

    def sortGames(self, sort='az'):
        if sort == 'za':
            self._games.sort(key = lambda index: operator.attrgetter('name')(index).lower(), reverse=True)
        else:
            self._games.sort(key = lambda index: operator.attrgetter('name')(index).lower())
