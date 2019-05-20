from functools import partial
from datetime import datetime, timedelta
import operator

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, QProcess, pyqtSlot
from PyQt5.QtQml import QQmlListProperty

from game import Game


class Search(QObject):
    tagsChanged = pyqtSignal()
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._tags = [
                'Shooter',
                'Arcade',
                'Action',
                'Roleplaying',
                'Strategy',
                'Puzzle'
                'FPS',
                'Multiplayer',
            ]

    @pyqtProperty(list, notify=tagsChanged)
    def tags(self):
        return self._tags

    @tags.setter
    def tags(self, tags):
        if tags != self._tags:
            self._tags = tags
            self.tagsChanged.emit()
