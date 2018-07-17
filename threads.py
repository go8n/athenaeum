import io
from PyQt5.QtCore import pyqtSignal, QThread
from subprocess import Popen, PIPE
from time import sleep

class InstallThread(QThread):
    outputChanged = pyqtSignal('QString')

    def __init__(self, game_ref):
        QThread.__init__(self)
        self._game_ref = game_ref

    def __del__(self):
        self.wait()

    def run(self):
        process = Popen(['flatpak', 'install', 'flathub', self._game_ref, '-y'], stdout=PIPE, stderr=PIPE)
        for output in io.TextIOWrapper(process.stdout, encoding="utf-8"):
            self.outputChanged.emit(output)
        for output in io.TextIOWrapper(process.stderr, encoding="utf-8"):
            self.outputChanged.emit(output)
        sleep(1)

class PlayThread(QThread):
    def __init__(self, game_ref):
        QThread.__init__(self)
        self._game_ref = game_ref

    def __del__(self):
        self.wait()

    def run(self):
        process = Popen(['flatpak', 'run', self._game_ref], stdout=PIPE, stderr=PIPE)
        process.wait()
        sleep(1)
