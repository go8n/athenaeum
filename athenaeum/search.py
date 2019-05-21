from functools import partial
from datetime import datetime, timedelta
import operator

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, QProcess, pyqtSlot
from PyQt5.QtQml import QQmlListProperty

from game import Game


class Tag(QObject):
    tagChanged = pyqtSignal()
    def __init__(self, name='', active=False, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._name = name
        self._active = active
        
    @pyqtProperty(str, notify=tagChanged)
    def name(self):
        return self._name
            
    @pyqtProperty(bool, notify=tagChanged)
    def active(self):
        return self._active

    @active.setter
    def active(self, active):
        if active != self._active:
            self._active = active
            self.tagChanged.emit()

class Search(QObject):
    tagsChanged = pyqtSignal()
    activeTagsChanged = pyqtSignal()
    platformsChanged = pyqtSignal()
    repositoriesChanged = pyqtSignal()
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._tags = [
                Tag(name='Shooter'),
                Tag(name='Arcade'),
                Tag(name='Action'),
                Tag(name='Roleplaying'),
                Tag(name='Strategy'),
                Tag(name='Puzzle'),
                Tag(name='FPS'),
                Tag(name='Multiplayer')
            ]
        self._platforms = ['GNU']
        self._repositories = ['Flathub']
        
    @pyqtProperty(QQmlListProperty, notify=tagsChanged)
    def tags(self):
        return QQmlListProperty(Tag, self, self._tags)

    @tags.setter
    def tags(self, tags):
        if tags != self._tags:
            self._tags = tags
            self.tagsChanged.emit()
         
    @pyqtProperty(QQmlListProperty, notify=activeTagsChanged)
    def activeTags(self):
        return QQmlListProperty(Tag, self, list(filter(lambda x: x.active, self._tags)))

    @pyqtProperty(list, notify=platformsChanged)
    def platforms(self):
        return self._platforms
    
    @pyqtProperty(list, notify=repositoriesChanged)
    def repositories(self):
        return self._repositories
    
    
