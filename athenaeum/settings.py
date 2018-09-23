from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal

from models import setSetting, getSetting

class Settings(QObject):
    showTrayIconChanged = pyqtSignal(bool)
    closeToTrayChanged = pyqtSignal(bool)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        showTrayIcon = getSetting('show_tray_icon')
        self._showTrayIcon = True if showTrayIcon is None else showTrayIcon
        closeToTray = getSetting('close_to_tray')
        self._closeToTray = True if closeToTray is None else closeToTray

    @pyqtProperty(bool, notify=showTrayIconChanged)
    def showTrayIcon(self):
        return self._showTrayIcon

    @showTrayIcon.setter
    def showTrayIcon(self, showTrayIcon):
        if showTrayIcon != self._showTrayIcon:
            self._showTrayIcon = showTrayIcon
            setSetting('show_tray_icon', showTrayIcon)
            self.showTrayIconChanged.emit(showTrayIcon)

    @pyqtProperty(bool, notify=closeToTrayChanged)
    def closeToTray(self):
        return self._closeToTray

    @closeToTray.setter
    def closeToTray(self, closeToTray):
        if closeToTray != self._closeToTray:
            self._closeToTray = closeToTray
            setSetting('close_to_tray', closeToTray)
            print(not closeToTray)
            self.closeToTrayChanged.emit(not closeToTray)