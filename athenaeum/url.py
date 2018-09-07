from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal


class Url(QObject):
    typeChanged = pyqtSignal()
    iconChanged = pyqtSignal()
    titleChanged = pyqtSignal()
    urlChanged = pyqtSignal()

    def __init__(self, type='', icon = '', title='', url='', *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._type = type
        self._icon = icon
        self._title = title
        self._url = url

    @pyqtProperty('QString', notify=typeChanged)
    def type(self):
        return self._type

    @type.setter
    def type(self, type):
        if type != self._type:
            self._type = type
            self.typeChanged.emit()

    @pyqtProperty('QString', notify=iconChanged)
    def icon(self):
        return self._icon

    @icon.setter
    def icon(self, icon):
        if icon != self._icon:
            self._icon = icon
            self.iconChanged.emit()

    @pyqtProperty('QString', notify=titleChanged)
    def title(self):
        return self._title

    @title.setter
    def title(self, title):
        if title != self._title:
            self._title = title
            self.titleChanged.emit()

    @pyqtProperty('QString', notify=urlChanged)
    def url(self):
        return self._url

    @url.setter
    def url(self, url):
        if url != self._url:
            self._url = url
            self.urlChanged.emit()
