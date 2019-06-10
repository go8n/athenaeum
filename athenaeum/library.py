from functools import partial
from datetime import datetime, timedelta
import operator

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, QProcess, pyqtSlot
from PyQt5.QtQml import QQmlListProperty

from game import Game


class Library(QObject):
    gamesChanged = pyqtSignal()
    filterChanged = pyqtSignal()
    filtersChanged = pyqtSignal(list)
    filterValueChanged = pyqtSignal()
    searchValueChanged = pyqtSignal()
    currentGameChanged = pyqtSignal()
    errorChanged = pyqtSignal()

    def __init__(self, gameManager=None, metaRepository=None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._gameManager = gameManager
        self._metaRepository = metaRepository
        self.reset()

    def load(self):
        self.filterValue = self._metaRepository.get('filter') or 'installed'
        self.updateFilters(new_load=True)
        self.currentGame = self.filter[0] if len(self._filter) else Game()

    def reset(self):
        self._filter = []
        self._filters = {
            'installed': [],
            'recent': [],
            'has_updates': [],
            'processing': []
        }
        self._filterValue = ''
        self._searchValue = ''
        self._currentGame = Game()

    @pyqtSlot(result=int)
    def getIndexForCurrentGame(self):
        for index, game in enumerate(self._filter):
            if game.id == self._currentGame.id:
                return index
            
        if not self._currentGame.id:
            return 0
        
        return -1

    @pyqtSlot(str)
    def updateCurrentGame(self, game_id):
        for key, games in self._filters.items():
            for game in games:
                if game.id == game_id:
                    self.currentGame = game
                    self.filterValue = key
                    self.filterGames()
                    return

    @pyqtSlot(str, result=int)
    def findById(self, game_id):
        for index, game in enumerate(self._gameManager.games()):
            if game.id == game_id:
                return index
        return None

    @pyqtProperty(Game, notify=currentGameChanged)
    def currentGame(self):
        return self._currentGame

    @currentGame.setter
    def currentGame(self, game):
        if game != self._currentGame:
            self._currentGame = game
            self.currentGameChanged.emit()

    @pyqtProperty(int, notify=filtersChanged)
    def recentCount(self):
        return len(self._filters['recent'])

    @pyqtProperty(int, notify=filtersChanged)
    def hasUpdatesCount(self):
        return len(self._filters['has_updates'])

    @pyqtProperty(int, notify=filtersChanged)
    def installedCount(self):
        return len(self._filters['installed'])

    @pyqtProperty(int, notify=filtersChanged)
    def processingCount(self):
        return len(self._filters['processing'])

    @pyqtProperty(QQmlListProperty, notify=filterChanged)
    def filter(self):
        return QQmlListProperty(Game, self, self._filter)

    @filter.setter
    def filter(self, filter):
        if filter != self._filter:
            self._filter = filter
            self.filterChanged.emit()

    @pyqtProperty('QString', notify=filterValueChanged)
    def filterValue(self):
        return self._filterValue

    @filterValue.setter
    def filterValue(self, filterValue):
        if filterValue != self._filterValue:
            self._filterValue = filterValue
            self.filterValueChanged.emit()

    @pyqtProperty('QString', notify=searchValueChanged)
    def searchValue(self):
        return self._searchValue

    @searchValue.setter
    def searchValue(self, searchValue):
        if searchValue != self._searchValue:
            self._searchValue = searchValue
            self.searchValueChanged.emit()

    def indexUpdated(self, index):
        try:
            self.currentGame = self._filter[index]
        except IndexError:
            print('Index does not exist.')

    def installGame(self, game_id):
        self._gameManager.installGame(game_id, startedCallback=self.updateFilters, finishedCallback=self.updateFilters)

    def uninstallGame(self, game_id):
        self._gameManager.uninstallGame(game_id, finishedCallback=self.updateFilters)

    def updateGame(self, game_id):
        self._gameManager.updateGame(game_id)

    def playGame(self, game_id):
        self._gameManager.playGame(game_id)

    def searchGames(self):
        if self.searchValue:
            tmp = []
            query = self.searchValue.lower()
            for game in self._filters[self.filterValue]:
                if query in game.name.lower():
                    tmp.append(game)
            self.filter = tmp
        else:
            self.filterGames()

    def filterGames(self):
        self.filter = self._filters[self.filterValue]
        self._metaRepository.set(key='filter', value=self.filterValue)

    def updateFilters(self, new_load=False):
        filters = {
            'installed': [],
            'recent': [],
            'has_updates': [],
            'processing': []
        }

        now = datetime.now()
        for game in self._gameManager.games():
            if game.installed:
                filters['installed'].append(game)
            if game.processing:
                filters['processing'].append(game)
            if game.hasUpdate:
                filters['has_updates'].append(game)
            if game.lastPlayedDate:
                if (game.lastPlayedDate + timedelta(days=15)) > now:
                    filters['recent'].append(game)

        self._filters = filters
        self.filterGames()
        self.searchGames()
        self.filtersChanged.emit(self._filters['recent'][:5] or self._filters['installed'][:5])
