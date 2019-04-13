from datetime import datetime

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, QProcess
from PyQt5.QtQml import QQmlListProperty

from url import Url
from screenshot import Screenshot
from release import Release


class Game(QObject):
    idChanged = pyqtSignal()
    nameChanged = pyqtSignal()
    iconSmallChanged = pyqtSignal()
    iconLargeChanged = pyqtSignal()

    licenseChanged = pyqtSignal()
    developerNameChanged = pyqtSignal()
    summaryChanged = pyqtSignal()
    descriptionChanged = pyqtSignal()
    screenshotsChanged = pyqtSignal()
    releasesChanged = pyqtSignal()
    categoriesChanged = pyqtSignal()
    urlsChanged = pyqtSignal()

    refChanged = pyqtSignal()

    installedChanged = pyqtSignal()
    hasUpdateChanged = pyqtSignal()
    lastPlayedDateChanged = pyqtSignal()
    createdDateChanged = pyqtSignal()

    playingChanged = pyqtSignal()
    processingChanged = pyqtSignal()

    logChanged = pyqtSignal()
    errorChanged = pyqtSignal()

    def __init__(self,
            id='',
            name='',
            iconSmall='',
            iconLarge='',
            license='',
            developerName='',
            summary='',
            description='',
            screenshots=[],
            releases=[],
            categories=[],
            urls=[],
            ref='',
            installed=False,
            hasUpdate=False,
            lastPlayedDate=None,
            createdDate=None,
            *args,
            **kwargs):
        super().__init__(*args, **kwargs)
        # Persisted values
        self._id = id
        self._name = name
        self._iconSmall = iconSmall
        self._iconLarge = iconLarge

        self._license = license
        self._developerName = developerName
        self._summary = summary
        self._description = description
        self._screenshots = screenshots
        self._releases = releases
        self._categories = categories
        self._urls = urls

        self._ref = ref

        self._installed = installed
        self._hasUpdate = hasUpdate
        self._lastPlayedDate = lastPlayedDate
        self._createdDate = createdDate

        # Dynamic values
        self._playing = False
        self._processing = False
        self._log = ''
        self._error = False

    @pyqtProperty('QString', notify=idChanged)
    def id(self):
        return self._id

    @id.setter
    def id(self, id):
        if id != self._id:
            self._id = id
            self.idChanged.emit()

    @pyqtProperty('QString', notify=nameChanged)
    def name(self):
        return self._name

    @name.setter
    def name(self, name):
        if name != self._name:
            self._name = name
            self.nameChanged.emit()

    @pyqtProperty('QString', notify=iconSmallChanged)
    def iconSmall(self):
        return self._iconSmall

    @iconSmall.setter
    def iconSmall(self, iconSmall):
        if iconSmall != self._iconSmall:
            self._iconSmall = iconSmall
            self.iconSmallChanged.emit()

    @pyqtProperty('QString', notify=iconLargeChanged)
    def iconLarge(self):
        return self._iconLarge

    @iconLarge.setter
    def iconLarge(self, iconLarge):
        if iconLarge != self._iconLarge:
            self._iconLarge = iconLarge
            self.iconLargeChanged.emit()

    @pyqtProperty('QString', notify=licenseChanged)
    def license(self):
        return self._license

    @license.setter
    def license(self, license):
        if license != self._license:
            self._license = license
            self.licenseChanged.emit()

    @pyqtProperty('QString', notify=developerNameChanged)
    def developerName(self):
        return self._developerName

    @developerName.setter
    def developerName(self, developerName):
        if developerName != self._developerName:
            self._developerName = developerName
            self.developerNameChanged.emit()

    @pyqtProperty('QString', notify=summaryChanged)
    def summary(self):
        return self._summary

    @summary.setter
    def summary(self, summary):
        if summary != self._summary:
            self._summary = summary
            self.summaryChanged.emit()

    @pyqtProperty(str, notify=descriptionChanged)
    def description(self):
        return self._description

    @description.setter
    def description(self, description):
        if description != self._description:
            self._description = description
            self.descriptionChanged.emit()

    @pyqtProperty(QQmlListProperty, notify=screenshotsChanged)
    def screenshots(self):
        return QQmlListProperty(Screenshot, self, self._screenshots)

    @screenshots.setter
    def screenshots(self, screenshots):
        if screenshots != self._screenshots:
            self.screenshots = screenshots
            selfscreenshotsChanged.emit()

    @pyqtProperty(QQmlListProperty, notify=releasesChanged)
    def releases(self):
        return QQmlListProperty(Release, self, self._releases)

    @releases.setter
    def releases(self, releases):
        if releases != self._releases:
            self.releases = releases
            selfreleasesChanged.emit()

    @pyqtProperty(list, notify=categoriesChanged)
    def categories(self):
        return self._categories

    @categories.setter
    def categories(self, categories):
        if categories != self._categories:
            self.categories = categories
            selfcategoriesChanged.emit()

    @pyqtProperty(QQmlListProperty, notify=urlsChanged)
    def urls(self):
        return QQmlListProperty(Url, self, self._urls)

    @urls.setter
    def urls(self, urls):
        if urls != self._urls:
            self.urls = urls
            selfurlsChanged.emit()

    @pyqtProperty('QString', notify=refChanged)
    def ref(self):
        return self._ref

    @ref.setter
    def ref(self, ref):
        if ref != self._ref:
            self._ref = ref
            self.refChanged.emit()

    @pyqtProperty(bool, notify=playingChanged)
    def playing(self):
        return self._playing

    @playing.setter
    def playing(self, playing):
        self._playing = playing
        self.playingChanged.emit()

    @pyqtProperty(bool, notify=installedChanged)
    def installed(self):
        return self._installed

    @installed.setter
    def installed(self, installed):
        self._installed = installed
        self.installedChanged.emit()

    @pyqtProperty(bool, notify=hasUpdateChanged)
    def hasUpdate(self):
        return self._hasUpdate

    @hasUpdate.setter
    def hasUpdate(self, hasUpdate):
        self._hasUpdate = hasUpdate
        self.hasUpdateChanged.emit()

    @pyqtProperty(datetime, notify=lastPlayedDateChanged)
    def lastPlayedDate(self):
        return self._lastPlayedDate

    @lastPlayedDate.setter
    def lastPlayedDate(self, lastPlayedDate):
        self._lastPlayedDate = lastPlayedDate
        self.lastPlayedDateChanged.emit()

    @pyqtProperty(datetime, notify=createdDateChanged)
    def createdDate(self):
        return self._createdDate

    @createdDate.setter
    def createdDate(self, createdDate):
        self._createdDate = createdDate
        self.createdDateChanged.emit()

    @pyqtProperty(bool, notify=processingChanged)
    def processing(self):
        return self._processing

    @processing.setter
    def processing(self, processing):
        self._processing = processing
        self.processingChanged.emit()

    @pyqtProperty(str, notify=logChanged)
    def log(self):
        return self._log

    @log.setter
    def log(self, log):
        if log != self._log:
            self._log = log
            self.logChanged.emit()
    
    @pyqtProperty(bool, notify=errorChanged)
    def error(self):
        return self._error
    
    @error.setter
    def error(self, error):
        if error != self._error:
            self._error = error
            self.errorChanged.emit()

    def appendLog(self, process, finished=False):
        output_data = str(process.readAllStandardOutput(), 'utf-8')
        if '\n' == output_data:
            output_data = ''
        error_data = str(process.readAllStandardError(), 'utf-8')
        if '\n' == error_data:
            error_data = ''

        log_data = output_data + error_data
        if finished:
            pass
        else:
            if log_data[:1] == '\r':
                rs = self._log.rsplit('\r', 1)
                if len(rs) > 1:
                    self._log = rs[0] + log_data
                else:
                    self._log = self._log.rsplit('\n', 1)[0] + log_data
            else:
                self._log = self._log + log_data
        self.logChanged.emit()
