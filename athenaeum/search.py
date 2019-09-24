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
    searchTagsValueChanged = pyqtSignal()
    
    def __init__(self, gameManager=None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._gameManager = gameManager
        self._tags = [
                Tag(name='Action'),
                Tag(name='Adventure'),
                Tag(name='Arcade'),
                Tag(name='Board'),
                Tag(name='Blocks'),
                Tag(name='Card'),
                Tag(name='Kids'),
                Tag(name='Logic'),
                Tag(name='RolePlaying'),
                Tag(name='Shooter'),
                Tag(name='Simulation'),
                Tag(name='Sports'),
                Tag(name='Strategy')
            ]
        self._platforms = ['GNU']
        self._repositories = ['Flathub']
        self._searchValue = ''
        self._searchTagsValue = ''
        self._sortValue = 0
        
    def load(self):
        self.searchQueryChanged.emit()
    
    @pyqtProperty('QString', notify=searchTagsValueChanged)
    def searchTagsValue(self):
        return self._searchTagsValue
    
    @searchTagsValue.setter
    def searchTagsValue(self, searchTagsValue):
        if searchTagsValue != self._searchTagsValue:
            self._searchTagsValue = searchTagsValue
            self.searchTagsValueChanged.emit()
    
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
         
    @pyqtProperty(QQmlListProperty, notify=searchTagsValueChanged)
    def searchTags(self):
        return QQmlListProperty(Tag, self, list(filter(lambda x: self.searchTagsValue.lower() in x.name.lower(), self._tags)))

    @pyqtProperty(list, notify=platformsChanged)
    def platforms(self):
        return self._platforms
    
    @pyqtProperty(list, notify=repositoriesChanged)
    def repositories(self):
        return self._repositories
    
    @pyqtProperty(QQmlListProperty, notify=searchQueryChanged)
    def results(self):
        self._results = QQmlListProperty(Game, self, list(filter(self.filterFunc, self._gameManager.games())))
        return self._results
    
    # @pyqtProperty(QQmlListProperty, notify=searchQueryChanged)
    # def resultsShort(self):
    #     return QQmlListProperty(Game, self, list(filter(lambda x: self.searchValue.lower() in x.name.lower(), self._gameManager.games()))[:5] if self.searchValue else [])
    
    def filterFunc(self, x):
        if self.searchValue and self.searchValue.lower() not in x.name.lower():
            return False
        
        if not set(map(lambda x: x.name, self.activeTags)).issubset(set(x.tags)):
            return False
        
        return True
    
    # def sortGames(self, games):
    #     if self.sortValue == 1:
    #         return sorted(games, key = lambda index: operator.attrgetter('name')(index).lower())
    #     if self.sortValue == 2:
    #         return sorted(games, key = lambda index: operator.attrgetter('name')(index).lower(), reverse=True)
    #     return games
    
