from PyQt5.QtCore import QVariant, QMetaType, QObject
from PyQt5.QtDBus import QDBusConnection, QDBusArgument, QDBusInterface, QDBus

class Notify(QObject):
    def __init__(self, name='', *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._appName = name
        
        self._bus = QDBusConnection.sessionBus()
        if not self._bus.isConnected():
            print("Not connected to dbus!")
        
    def showNotifitcation(self, header, message, icon):
        item = "org.freedesktop.Notifications"
        path = "/org/freedesktop/Notifications"
        interface = "org.freedesktop.Notifications"

        v = QVariant(12321)  # random int to identify all notifications
        if v.convert(QVariant.UInt):
            id_replace = v

        actions_list = QDBusArgument([], QMetaType.QStringList)
        hint = {}
        
        time = 100

        notify = QDBusInterface(item, path, interface, self._bus)
        if notify.isValid():
            x = notify.call(QDBus.AutoDetect, "Notify", self._appName,
                            id_replace, icon, header, message,
                            actions_list, hint, time)
            if x.errorName():
                print("Failed to send notification!")
                print(x.errorMessage())
        else:
            print("Invalid dbus interface")
