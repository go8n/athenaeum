from datetime import datetime

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, QProcess
from PyQt5.QtQml import QQmlListProperty

from models import GameRecord

class Game(QObject):
    idChanged = pyqtSignal()
    nameChanged = pyqtSignal()
    iconSmallChanged = pyqtSignal()
    iconLargeChanged = pyqtSignal()

    refChanged = pyqtSignal()
    playingChanged = pyqtSignal()
    installedChanged = pyqtSignal()
    processingChanged = pyqtSignal()

    logChanged = pyqtSignal()

    def __init__(self, id='', name='', iconSmall='', iconLarge='', ref='', installed=False, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Persisted values
        self._id = id
        self._name = name
        self._iconSmall = iconSmall
        self._iconLarge = iconLarge
        self._ref = ref
        self._installed = installed

        # Dynamic values
        self._playing = False
        self._processing = False
        self._log = ''

    @pyqtProperty('QString', notify=idChanged)
    def id(self):
        return self._id

    @id.setter
    def id(self, id):
        if id != self._id:
            self._id = id
            self.idChanged.emit()

    @pyqtProperty('QString', notify=nameChanged)
    def name(self):
        return self._name

    @name.setter
    def name(self, name):
        if name != self._name:
            self._name = name
            self.nameChanged.emit()

    @pyqtProperty('QString', notify=iconSmallChanged)
    def iconSmall(self):
        return self._iconSmall

    @iconSmall.setter
    def iconSmall(self, iconSmall):
        if iconSmall != self._iconSmall:
            self._iconSmall = iconSmall
            self.iconSmallChanged.emit()

    @pyqtProperty('QString', notify=iconLargeChanged)
    def iconLarge(self):
        return self._iconLarge

    @iconLarge.setter
    def iconLarge(self, iconLarge):
        if iconLarge != self._iconLarge:
            self._iconLarge = iconLarge
            self.iconLargeChanged.emit()

    @pyqtProperty('QString', notify=refChanged)
    def ref(self):
        return self._ref

    @ref.setter
    def ref(self, ref):
        if ref != self._ref:
            self._ref = ref
            self.refChanged.emit()

    @pyqtProperty(bool, notify=playingChanged)
    def playing(self):
        return self._playing

    @playing.setter
    def playing(self, playing):
        self._playing = playing
        self.playingChanged.emit()

    @pyqtProperty(bool, notify=installedChanged)
    def installed(self):
        return self._installed

    @installed.setter
    def installed(self, installed):
        self._installed = installed
        self.installedChanged.emit()

    @pyqtProperty(bool, notify=processingChanged)
    def processing(self):
        return self._processing

    @processing.setter
    def processing(self, processing):
        self._processing = processing
        self.processingChanged.emit()

    @pyqtProperty(str, notify=logChanged)
    def log(self):
        return self._log

    @log.setter
    def log(self, log):
        if log != self._log:
            self._log = log
            self.logChanged.emit()

    def startGame(self):
        self.playing = True
        print('start game')

    def stopGame(self):
        self.playing = False
        print('stop game')

    def startInstall(self):
        self.processing = True

    def finishInstall(self, process):
        self.processing = False
        self.installed = True
        (GameRecord.replace(
            id=self.id,
            installed=self.installed,
            modified_date=datetime.now()
        ).execute())
        self.appendLog(process, finished=True)

    def startUninstall(self):
        self.processing = True

    def finishUninstall(self, process):
        self.processing = False
        self.installed = False
        (GameRecord.replace(
            id=self.id,
            installed=self.installed,
            modified_date=datetime.now()
        ).execute())
        self.appendLog(process, finished=True)

    def startUpdate(self):
        self.processing = True

    def finishUpdate(self):
        self.processing = False

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
