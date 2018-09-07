from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal


class Release(QObject):
    versionChanged = pyqtSignal()
    timestampChanged = pyqtSignal()
    descriptionChanged = pyqtSignal()

    def __init__(self, version='', timestamp=0, description='', *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._version = version
        self._timestamp = timestamp
        self._description = description

    @pyqtProperty('QString', notify=versionChanged)
    def version(self):
        return self._version

    @version.setter
    def version(self, version):
        if version != self._version:
            self._version = version
            self.versionChanged.emit()

    @pyqtProperty(int, notify=timestampChanged)
    def timestamp(self):
        return self._timestamp

    @timestamp.setter
    def timestamp(self, timestamp):
        if timestamp != self._timestamp:
            self._timestamp = timestamp
            self.timestampChanged.emit()

    @pyqtProperty('QString', notify=descriptionChanged)
    def description(self):
        return self._description

    @description.setter
    def description(self, description):
        if description != self._description:
            self._description = description
            self.descriptionChanged.emit()
