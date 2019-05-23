from functools import partial
from datetime import datetime, timedelta
import operator

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, QProcess, pyqtSlot
from PyQt5.QtQml import QQmlListProperty

from game import Game


class Browse(QObject):
    def __init__(self, flatpak=False, metaRepository=None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._metaRepository = metaRepository
