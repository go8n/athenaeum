from functools import partial
from datetime import datetime, timedelta
import operator

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, QProcess, pyqtSlot
from PyQt5.QtQml import QQmlListProperty

from game import Game
from stemming.porter import stem
from numpy import dot, isnan
from numpy.linalg import norm


class Recommender(QObject):
    def __init__(self, gameManager=None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._gameManager = gameManager
        self._tags = set()
        self._vectorKeywordIndex = {}
        self._gameVectors = {}
        
    def load(self):
        for game in self._gameManager.games():
            for tag in game.tags:
                self._tags.add(stem(tag))
                
        self.getVectorKeywordIndex()
        
        for game in self._gameManager.games():
            vector = self.makeVector(game.tags)
            if vector:
                self._gameVectors[game.id] = vector

    def getVectorKeywordIndex(self):
        offset = 0
        #Associate a position with the keywords which maps to the dimension on the vector used to represent this word
        for tag in self._tags:
            self._vectorKeywordIndex[tag]=offset
            offset += 1

    def makeVector(self, wordList):
            if len(wordList) is 0:
                return None;
            
            vector = [0] * len(self._vectorKeywordIndex)
            for word in wordList:
                vector[self._vectorKeywordIndex[stem(word)]] += 1; #Use simple Term Count Model
            return vector
        
    def cosine(self, vector1, vector2):
        """ related documents j and q are in the concept space by comparing the vectors :
            cosine  = ( V1 * V2 ) / ||V1|| x ||V2|| """
        return float(dot(vector1,vector2) / (norm(vector1) * norm(vector2)))

    def search(self, gameId):
            ratings = []
            
            try:
                queryVector = self._gameVectors[gameId]
            except KeyError:
                return ratings
            
            for id, gameVector in self._gameVectors.items():
                ratings.append([id, self.cosine(queryVector, gameVector)]) 

            ratings.sort(key=lambda x: x[1] if not isnan(x[1]) else 0 , reverse=True)
            return ratings
            
    @pyqtSlot(str, result=list)
    def findSimilarGames(self, gameId):
        if not gameId:
            return []

        games = []
        results = self.search(gameId)[:6]
        for result in results:
            if result[0] == gameId:
                continue
            games.append(self._gameManager.getGameById(result[0]))

        return games
