from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal


class Url(QObject):
    typeChanged = pyqtSignal()
    iconChanged = pyqtSignal()
    urlChanged = pyqtSignal()

    def __init__(self, type='', icon = '', url='', *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._type = type
        self._icon = icon or self.findUrlIcon(type)
        self._url = url

    def findUrlIcon(self, type):
        if ('homepage' == type):
            return 'home.svg'
        elif ('bugtracker' == type):
            return 'bug.svg'
        elif ('help' == type):
            return 'help.svg'
        elif ('faq' == type):
            return 'question.svg'
        elif ('donation' == type):
            return 'donate.svg'
        elif ('translate' == type):
            return 'globe.svg'
        elif ('unknown' == type):
            return 'cogs.svg'
        elif ('manifest' == type):
            return 'manifest.svg'

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

    @pyqtProperty('QString', notify=urlChanged)
    def url(self):
        return self._url

    @url.setter
    def url(self, url):
        if url != self._url:
            self._url = url
            self.urlChanged.emit()
