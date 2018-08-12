from functools import partial

from PyQt5.QtGui import QIcon
from PyQt5.QtCore import pyqtSignal
from PyQt5.QtWidgets import QSystemTrayIcon, QMenu


class SystemTrayIcon(QSystemTrayIcon):
    playGame = pyqtSignal(str)

    def __init__(self, root, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._root = root

        self._trayIconMenu = QMenu();
        self.prepareMenu()

        self.setContextMenu(self._trayIconMenu)
        self.activated.connect(self.signalReceived)
        self.show()

    def signalReceived(self, reason):
        if reason == QSystemTrayIcon.Trigger:
            if self._root.isVisible():
                self._root.hide()
            else:
                self._root.show()
                # self.parent().activateWindow()

    def prepareMenu(self, recent=None):
        print("prepared")
        self._trayIconMenu.clear()
        if recent:
            for game in recent[:8]:
                playGameAction = self._trayIconMenu.addAction(QIcon(game.iconSmall), game.name)
                playGameAction.triggered.connect(partial(self.playGame.emit, game.id))
            self._trayIconMenu.addSeparator()

        exitAction = self._trayIconMenu.addAction(QIcon('icons/close.svg'), 'Exit')
        exitAction.triggered.connect(self.parent().quit)
