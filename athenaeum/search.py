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
    sortOptionsChanged = pyqtSignal()
    platformsChanged = pyqtSignal()
    repositoriesChanged = pyqtSignal()
    searchQueryChanged = pyqtSignal()
    searchTagsValueChanged = pyqtSignal()
    
    def __init__(self, gameManager=None, recommender=None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._gameManager = gameManager
        self._recommender = recommender
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
        self._sortOptions = ["Relevance", "A-Z", "Z-A"]
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
                
    @pyqtProperty(int, notify=searchQueryChanged)
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

    @pyqtProperty(list, notify=sortOptionsChanged)
    def sortOptions(self):
        return self._sortOptions
    
    @pyqtProperty(list, notify=platformsChanged)
    def platforms(self):
        return self._platforms
    
    @pyqtProperty(list, notify=repositoriesChanged)
    def repositories(self):
        return self._repositories
    
    @pyqtProperty(QQmlListProperty, notify=searchQueryChanged)
    def results(self):
        exactResults = []
        fuzzyResults = []
        for game in self._gameManager.games():
            if self._searchValue:
                if game.name.lower().startswith(self._searchValue.lower()):
                    exactResults.append(game)
                if self._recommender.levenshtein(game.name.lower(), self._searchValue.lower()) >= 0.75:
                    continue

            if not set(map(lambda x: game.name, self.activeTags)).issubset(set(game.tags)):
                continue

            fuzzyResults.append(game)

        if self.sortValue == 0 and self._searchValue:
            fuzzyResults.sort(key= lambda x: self._recommender.levenshtein(x.name.lower(), self._searchValue.lower()))

        results = exactResults + fuzzyResults

        if self.sortValue == 1:
            results.sort(key = lambda index: operator.attrgetter('name')(index).lower())
        if self.sortValue == 2:
            results.sort(key = lambda index: operator.attrgetter('name')(index).lower(), reverse=True)

        self._results = QQmlListProperty(Game, self, results)

        return self._results
