from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal


class Screenshot(QObject):
    thumbUrlChanged = pyqtSignal()
    sourceUrlChanged = pyqtSignal()

    def __init__(self, thumbUrl='', sourceUrl='', *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._thumbUrl = thumbUrl
        self._sourceUrl = sourceUrl

    @pyqtProperty('QString', notify=thumbUrlChanged)
    def thumbUrl(self):
        return self._thumbUrl

    @thumbUrl.setter
    def thumbUrl(self, thumbUrl):
        if thumbUrl != self._thumbUrl:
            self._thumbUrl = thumbUrl
            self.thumbUrlChanged.emit()

    @pyqtProperty('QString', notify=sourceUrlChanged)
    def sourceUrl(self):
        return self._sourceUrl

    @sourceUrl.setter
    def sourceUrl(self, sourceUrl):
        if sourceUrl != self._sourceUrl:
            self._sourceUrl = sourceUrl
            self.sourceUrlChanged.emit()
