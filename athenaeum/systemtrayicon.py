import os
from functools import partial

from PyQt5.QtGui import QIcon
from PyQt5.QtCore import pyqtSignal
from PyQt5.QtWidgets import QSystemTrayIcon, QMenu


class SystemTrayIcon(QSystemTrayIcon):
    playGame = pyqtSignal(str)

    def __init__(self, root, show, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._root = root

        self.setVisible(show)

        self._trayIconMenu = QMenu();
        self.prepareMenu()

        self.setContextMenu(self._trayIconMenu)
        self.activated.connect(self.signalReceived)

    def signalReceived(self, reason):
        if reason == QSystemTrayIcon.Trigger:
            if self._root.isVisible():
                self._root.hide()
            else:
                self._root.show()

    def prepareMenu(self, recent=None):
        self._trayIconMenu.clear()
        if recent:
            for game in recent:
                playGameAction = self._trayIconMenu.addAction(QIcon(game.iconSmall), game.name)
                playGameAction.triggered.connect(partial(self.playGame.emit, game.id))
            self._trayIconMenu.addSeparator()

        exitAction = self._trayIconMenu.addAction(QIcon(os.path.dirname(__file__) + '/icons/close.svg'), 'Exit')
        exitAction.triggered.connect(self.parent().quit)
