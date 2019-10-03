from functools import partial
from datetime import datetime, timedelta
import operator

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, QProcess, pyqtSlot
from PyQt5.QtQml import QQmlListProperty

from game import Game
from stemming.porter import stem
from numpy import dot, isnan, array, arange, minimum, add
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
                return None
            
            vector = [0] * len(self._vectorKeywordIndex)
            for word in wordList:
                vector[self._vectorKeywordIndex[stem(word)]] += 1; #Use simple Term Count Model
            return vector
        
    def cosine(self, vector1, vector2):
        """ related documents j and q are in the concept space by comparing the vectors :
            cosine  = ( V1 * V2 ) / ||V1|| x ||V2|| """
        try:
            return float(dot(vector1,vector2) / (norm(vector1) * norm(vector2)))
        except ValueError:
            return 0

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

    # https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#Python
    def levenshtein(self, source, target):
        if len(source) < len(target):
            return self.levenshtein(target, source)

        # So now we have len(source) >= len(target).
        if len(target) == 0:
            return len(source)

        # We call tuple() to force strings to be used as sequences
        # ('c', 'a', 't', 's') - numpy uses them as values by default.
        source = array(tuple(source))
        target = array(tuple(target))

        # We use a dynamic programming algorithm, but with the
        # added optimization that we only need the last two rows
        # of the matrix.
        previous_row = arange(target.size + 1)
        for s in source:
            # Insertion (target grows longer than source):
            current_row = previous_row + 1

            # Substitution or matching:
            # Target and source items are aligned, and either
            # are different (cost of 1), or are the same (cost of 0).
            current_row[1:] = minimum(
                    current_row[1:],
                    add(previous_row[:-1], target != s))

            # Deletion (target grows shorter than source):
            current_row[1:] = minimum(
                    current_row[1:],
                    current_row[0:-1] + 1)

            previous_row = current_row

        return (previous_row[-1] / len(source))

