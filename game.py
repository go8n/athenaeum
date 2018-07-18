from datetime import datetime

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, QProcess
from PyQt5.QtQml import QQmlListProperty

from models import GameRecord

class Game(QObject):
    idChanged = pyqtSignal()
    nameChanged = pyqtSignal()
    iconChanged = pyqtSignal()

    refChanged = pyqtSignal()
    playingChanged = pyqtSignal()
    installedChanged = pyqtSignal()
    installingChanged = pyqtSignal()

    logChanged = pyqtSignal()

    def __init__(self, id='', name='', icon='', ref='', installed=False, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Persisted values
        self._id = id
        self._name = name
        self._icon = icon
        self._ref = ref
        self._installed = installed

        # Dynamic values
        self._playing = False
        self._installing = False
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

    @pyqtProperty('QString', notify=iconChanged)
    def icon(self):
        return self._icon

    @icon.setter
    def icon(self, icon):
        if icon != self._icon:
            self._icon = icon
            self.iconChanged.emit()

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

    @pyqtProperty(bool, notify=installingChanged)
    def installing(self):
        return self._installing

    @installing.setter
    def installing(self, installing):
        self._installing = installing
        self.installingChanged.emit()

    @pyqtProperty('QString', notify=logChanged)
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
        self.installing = True

    def finishInstall(self, process):
        self.installing = False
        self.installed = True
        (GameRecord.replace(
            id=self.id,
            installed=self.installed,
            modified_date=datetime.now()
        ).execute())

        self.appendLog(process, finished=True)

    def appendLog(self, process, finished=False):
        log_data = str(process.readAllStandardOutput(), 'utf-8')
        print(log_data)
        if finished:
            self._log = ''
        else:
            self._log = self._log + log_data
        self.logChanged.emit()
