from functools import partial
from datetime import datetime, timedelta
import operator

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, QProcess, pyqtSlot
from PyQt5.QtQml import QQmlListProperty

from game import Game

class SpotlightItem(QObject):
    gameChanged = pyqtSignal()
    titleChanged = pyqtSignal()
    
    def __init__(self, game=None, title='', *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._game = game
        self._title = title
        
    @pyqtProperty(Game, notify=gameChanged)
    def game(self):
        return self._game

    @game.setter
    def game(self, game):
        if game != self._game:
            self._game = game
            self.gameChanged.emit()
        
    @pyqtProperty('QString', notify=titleChanged)
    def title(self):
        return self._title

    @title.setter
    def title(self, title):
        if title != self._title:
            self._title = title
            self.titleChanged.emit()

class Browse(QObject):
    recommendedChanged = pyqtSignal()
    newChanged = pyqtSignal()
    spotlightChanged = pyqtSignal()
    
    def __init__(self, gameManager=None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._gameManager = gameManager
        self._spotlight = []
        
    def load(self):
        self.recommendedChanged.emit()
        self.newChanged.emit()
        self.spotlight = [
            SpotlightItem(self.getGameById('net.supertuxkart.SuperTuxKart'), 'Online Multiplayer Now Here!'),
            SpotlightItem(self.getGameById('com.play0ad.zeroad'), 'Popular Now!'),
            SpotlightItem(self.getGameById('net.minetest.Minetest'), 'Now with Mod Manager!')
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
        return QQmlListProperty(Game, self, self._gameManager.games()[:6])
         
    @pyqtProperty(QQmlListProperty, notify=newChanged)
    def new(self):
        return QQmlListProperty(Game, self, self._gameManager.games()[-8:])
         
