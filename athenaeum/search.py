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
    platformsChanged = pyqtSignal()
    repositoriesChanged = pyqtSignal()
    searchQueryChanged = pyqtSignal()
    
    def __init__(self, gameManager=None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._gameManager = gameManager
        self._tags = [
                Tag(name='Shooter'),
                Tag(name='Arcade'),
                Tag(name='Action'),
                Tag(name='RolePlaying'),
                Tag(name='Strategy'),
                Tag(name='Puzzle'),
                Tag(name='FPS'),
                Tag(name='Multiplayer')
            ]
        self._platforms = ['GNU']
        self._repositories = ['Flathub']
        self._searchValue = ''
        self._sortValue = 0
    
    @pyqtProperty('QString', notify=searchQueryChanged)
    def searchValue(self):
        return self._searchValue
    
    @searchValue.setter
    def searchValue(self, searchValue):
        if searchValue != self._searchValue:
            self._searchValue = searchValue
            self.searchQueryChanged.emit()
                
    @pyqtProperty('QString', notify=searchQueryChanged)
    def sortValue(self):
        return self._sortValue
    
    @sortValue.setter
    def sortValue(self, sortValue):
        if sortValue != self._sortValue:
            self._sortValue = sortValue
            self.searchQueryChanged.emit()
        
    @pyqtProperty(QQmlListProperty, notify=tagsChanged)
    def tags(self):
        return QQmlListProperty(Tag, self, self._tags)

    @tags.setter
    def tags(self, tags):
        if tags != self._tags:
            self._tags = tags
            self.tagsChanged.emit()
         
    @pyqtProperty(QQmlListProperty, notify=searchQueryChanged)
    def activeTags(self):
        return QQmlListProperty(Tag, self, list(filter(lambda x: x.active, self._tags)))

    @pyqtProperty(list, notify=platformsChanged)
    def platforms(self):
        return self._platforms
    
    @pyqtProperty(list, notify=repositoriesChanged)
    def repositories(self):
        return self._repositories
    
    @pyqtProperty(QQmlListProperty, notify=searchQueryChanged)
    def searchResults(self):
        return QQmlListProperty(Game, self, list(filter(self.filterFunc, self._gameManager.games())))
    
    def filterFunc(self, x):
        if self.searchValue and self.searchValue not in x.name:
            return False
        
        if not set(map(lambda x: x.name, self.activeTags)).issubset(set(x.tags)):
            return False
        
        return True
    
    def sortGames(self, games):
        if self.sortValue == 1:
            return sorted(games, key = lambda index: operator.attrgetter('name')(index).lower())
        if self.sortValue == 2:
            return sorted(games, key = lambda index: operator.attrgetter('name')(index).lower(), reverse=True)
        return games
    
