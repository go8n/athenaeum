from functools import partial
from datetime import datetime, timedelta
import operator
import random

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, QProcess, pyqtSlot
from PyQt5.QtQml import QQmlListProperty

from game import Game


class Recommendation(QObject):
    whatChanged = pyqtSignal()
    whyChanged = pyqtSignal()
    
    def __init__(self, what=None, why=None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._what = what
        self._why = why
        
    @pyqtProperty(Game, notify=whatChanged)
    def what(self):
        return self._what
    
    @pyqtProperty(Game, notify=whyChanged)
    def why(self):
        return self._why

class Browse(QObject):
    recommendedChanged = pyqtSignal()
    newChanged = pyqtSignal()
    spotlightChanged = pyqtSignal()
    
    def __init__(self, gameManager=None, recommender=None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._gameManager = gameManager
        self._recommender = recommender
        self._k = 0
        
    def load(self):
        self._k = 6
        self.recommendedChanged.emit()
        self.newChanged.emit()
        self.spotlightChanged.emit()
    
    @pyqtSlot(str, result=Game)
    def getGameById(self, gameId):
        for game in self._gameManager.games():
            if game.id == gameId:
                return game
        return None
    
    @pyqtProperty(QQmlListProperty, notify=spotlightChanged)
    def spotlight(self):
        return QQmlListProperty(Game, self, random.sample(self._gameManager.games(), k=self._k))
        
    def getRecommendations(self, games):
        recommendations = []
        for game in random.sample(games, 4) if len(games) > 4 else games:
                for recommendedGame in self.findSimilarGames(game.id, 3):
                    if recommendedGame.id in map(operator.attrgetter('id'), games):
                        continue
                    if recommendedGame.id in map(operator.attrgetter('what.id'), recommendations):
                        continue

                    recommendations.append(Recommendation(what=recommendedGame, why=game))
                    
        return recommendations
        
        
    @pyqtProperty(QQmlListProperty, notify=recommendedChanged)
    def recommended(self):
        installed = list(filter(lambda x: x.installed, self._gameManager.games()))
        recommended = self.getRecommendations(installed)
            
        random.shuffle(recommended)
        return QQmlListProperty(Game, self, recommended)
         
    @pyqtProperty(QQmlListProperty, notify=newChanged)
    def new(self):
        return QQmlListProperty(Game, self, random.sample(self._gameManager.games(), k=self._k))

    @pyqtSlot(str, result=list)
    def findSimilarGames(self, gameId, amount=5):
        if not gameId:
            return []

        games = []
        results = self._recommender.search(gameId)[:amount+1]
        for result in results:
            if result[0] == gameId:
                continue
            games.append(self._gameManager.getGameById(result[0]))

        return games
