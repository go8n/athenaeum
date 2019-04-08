from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal

class Settings(QObject):
    showTrayIconChanged = pyqtSignal(bool)
    closeToTrayChanged = pyqtSignal(bool)
    alwaysShowLogsChanged = pyqtSignal(bool)
    notificationsEnabledChanged = pyqtSignal(bool)
    themeChanged = pyqtSignal(str)

    def __init__(self, *args, settingRepository=None, **kwargs):
        super().__init__(*args, **kwargs)
        self._settingRepository = settingRepository
        showTrayIcon = self._settingRepository.get('show_tray_icon')
        self._showTrayIcon = True if showTrayIcon is None else showTrayIcon
        closeToTray = self._settingRepository.get('close_to_tray')
        self._closeToTray = True if closeToTray is None else closeToTray
        alwaysShowLogs = self._settingRepository.get('close_to_tray')
        self._alwaysShowLogs = False if alwaysShowLogs is None else alwaysShowLogs
        notificationsEnabled = self._settingRepository.get('notifications_enabled')
        self._notificationsEnabled = True if notificationsEnabled is None else notificationsEnabled
        theme = self._settingRepository.get('theme')
        self._theme = 'Dark' if theme is None else theme

    @pyqtProperty(bool, notify=showTrayIconChanged)
    def showTrayIcon(self):
        return self._showTrayIcon

    @showTrayIcon.setter
    def showTrayIcon(self, showTrayIcon):
        if showTrayIcon != self._showTrayIcon:
            self._showTrayIcon = showTrayIcon
            self._settingRepository.set('show_tray_icon', showTrayIcon)
            self.showTrayIconChanged.emit(showTrayIcon)

    @pyqtProperty(bool, notify=closeToTrayChanged)
    def closeToTray(self):
        return self._closeToTray

    @closeToTray.setter
    def closeToTray(self, closeToTray):
        if closeToTray != self._closeToTray:
            self._closeToTray = closeToTray
            self._settingRepository.set('close_to_tray', closeToTray)
            print(not closeToTray)
            self.closeToTrayChanged.emit(not closeToTray)

    @pyqtProperty(bool, notify=alwaysShowLogsChanged)
    def alwaysShowLogs(self):
        return self._alwaysShowLogs

    @alwaysShowLogs.setter
    def alwaysShowLogs(self, alwaysShowLogs):
        if alwaysShowLogs != self._alwaysShowLogs:
            self._alwaysShowLogs = alwaysShowLogs
            self._settingRepository.set('close_to_tray', alwaysShowLogs)
            self.alwaysShowLogsChanged.emit(alwaysShowLogs)

    @pyqtProperty(bool, notify=notificationsEnabledChanged)
    def notificationsEnabled(self):
        return self._notificationsEnabled

    @notificationsEnabled.setter
    def notificationsEnabled(self, notificationsEnabled):
        if notificationsEnabled != self._notificationsEnabled:
            self._notificationsEnabled = notificationsEnabled
            self._settingRepository.set('notifications_enabled', notificationsEnabled)
            self.notificationsEnabledChanged.emit(notificationsEnabled)
            
    @pyqtProperty(str, notify=themeChanged)
    def theme(self):
        return self._theme

    @theme.setter
    def theme(self, theme):
        if theme != self._theme:
            self._theme = theme
            self._settingRepository.set('theme', theme)
            self.themeChanged.emit(theme)
            
