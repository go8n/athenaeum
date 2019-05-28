from functools import partial
from datetime import datetime, timedelta
import operator
import random

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, QProcess, pyqtSlot
from PyQt5.QtQml import QQmlListProperty

from game import Game

class Browse(QObject):
    recommendedChanged = pyqtSignal()
    newChanged = pyqtSignal()
    spotlightChanged = pyqtSignal()
    
    def __init__(self, gameManager=None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._gameManager = gameManager
        self._spotlight = []
        self._k = 0
        
    def load(self):
        self._k = 6
        self.recommendedChanged.emit()
        self.newChanged.emit()
        self.spotlight = [
            self.getGameById('net.supertuxkart.SuperTuxKart'),
            self.getGameById('com.play0ad.zeroad'),
            self.getGameById('net.minetest.Minetest')
        ]
    
    @pyqtSlot(str, result=Game)
    def getGameById(self, gameId):
        for game in self._gameManager.games():
            if game.id == gameId:
                return game
        return None
    
    @pyqtProperty(QQmlListProperty, notify=spotlightChanged)
    def spotlight(self):
        return QQmlListProperty(Game, self, self._spotlight)

    @spotlight.setter
    def spotlight(self, spotlight):
        if spotlight != self._spotlight:
            self._spotlight = spotlight
            self.spotlightChanged.emit()
        
    @pyqtProperty(QQmlListProperty, notify=recommendedChanged)
    def recommended(self):
        return QQmlListProperty(Game, self, random.sample(self._gameManager.games(), k=self._k))
         
    @pyqtProperty(QQmlListProperty, notify=newChanged)
    def new(self):
        return QQmlListProperty(Game, self, random.sample(self._gameManager.games(), k=self._k))
         
