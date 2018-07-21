import random
from functools import partial

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, QProcess, QTimer

from models import getMeta, setMeta

class Loader(QObject):
    finished = pyqtSignal()
    stateChanged = pyqtSignal()
    messageChanged = pyqtSignal()
    errorChanged = pyqtSignal()

    metaKey = 'flathub_added'

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
            self.finishLoading()
        else:
            self.runCommands()

    def runCommands(self, proc_number=0):
        commandProcess = QProcess()
        commandProcess.errorOccurred.connect(self.handleError)
        if proc_number == 0:
            commandProcess.started.connect(self.startLoading)
            commandProcess.finished.connect(partial(self.runCommands, 1))
            commandProcess.start('flatpak', ['remote-add', '--if-not-exists', 'flathub', 'https://flathub.org/repo/flathub.flatpakrepo'])
        elif proc_number == 1:
            commandProcess.finished.connect(partial(self.runCommands, 2))
            commandProcess.start('flatpak', ['remote-ls', '--updates'])
        elif proc_number == 2:
            commandProcess.finished.connect(self.finishLoading)
            commandProcess.start('flatpak', ['update', '--appstream'])
        self._processes.append(commandProcess)

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
