from PyQt5.QtCore import QStandardPaths
from PyQt5.QtQml import QQmlNetworkAccessManagerFactory
from PyQt5.QtNetwork import QNetworkAccessManager, QNetworkDiskCache

class NetworkDiskCache(QNetworkDiskCache):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

class NetworkAccessManager(QNetworkAccessManager):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

class NetworkAccessManagerFactory(QQmlNetworkAccessManagerFactory):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def create(self, parent=None):
        networkAccessManager = NetworkAccessManager(parent=parent)

        networkDiskCache = NetworkDiskCache(parent=parent)
        networkDiskCache.setMaximumCacheSize(524288000)

        networkDiskCache.setCacheDirectory(QStandardPaths.writableLocation(QStandardPaths.CacheLocation))
        networkAccessManager.setCache(networkDiskCache)

        return networkAccessManager
