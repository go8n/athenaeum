import signal
import io
import datetime
from sys import argv

from PyQt5.QtCore import QObject, QTimer, pyqtProperty, pyqtSignal, QThread
from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQml import QQmlListProperty, QQmlApplicationEngine, qmlRegisterType, qmlRegisterSingletonType

from peewee import SqliteDatabase
from peewee import DoesNotExist

# Local imports
import appstream
from threads import PlayThread
from threads import InstallThread
from models import GameRecord, db

class Game(QObject):
    idChanged = pyqtSignal()
    nameChanged = pyqtSignal()
    iconChanged = pyqtSignal()
    logsChanged = pyqtSignal()
    refChanged = pyqtSignal()
    playingChanged = pyqtSignal()
    installedChanged = pyqtSignal()
    installingChanged = pyqtSignal()

    def __init__(self, id='', name='', icon='', ref='', installed=False, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Persisted values
        self._id = id
        self._name = name
        self._icon = icon
        self._ref = ref
        self._installed = installed

        # Dynamic values
        self._playing = False
        self._installing = False

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

    @pyqtProperty('QString', notify=iconChanged)
    def icon(self):
        return self._icon

    @icon.setter
    def icon(self, icon):
        if icon != self._icon:
            self._icon = icon
            self.iconChanged.emit()

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

    @pyqtProperty(bool, notify=installingChanged)
    def installing(self):
        return self._installing

    @installing.setter
    def installing(self, installing):
        self._installing = installing
        self.installingChanged.emit()

    def stopGame(self):
        self.playing = False
        print('stop game')

class Library(QObject):

    libraryChanged = pyqtSignal()
    currentGameChanged = pyqtSignal()
    logChanged = pyqtSignal()

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._games = []
        self._currentGame = Game()
        self._log = ''
        self._threads = []

        stream = appstream.Store()
        stream.from_file('/var/lib/flatpak/appstream/flathub/x86_64/active/appstream.xml.gz')

        for component in stream.get_components():
            if component.project_license and not 'LicenseRef-proprietary' in component.project_license:
                if 'Game' in component.categories:
                    try:
                        gr = GameRecord.get(GameRecord.id == component.id)
                    except DoesNotExist:
                        gr = None
                    self.appendGame(Game(component.id, component.name, self.getIcon(component.icons), component.bundle['value'], gr.installed if gr else False))

        self._currentGame = self._games[0]

    def getIcon(self, icons):
        cached_icon = icons['cached'][0]
        if cached_icon['height'] == '128':
            return '/var/lib/flatpak/appstream/flathub/x86_64/active/icons/128x128/' + cached_icon['value']
        elif cached_icon['height'] == '64':
            return '/var/lib/flatpak/appstream/flathub/x86_64/active/icons/64x64/' + cached_icon['value']

    def findById(self, game_id):
        for index, game in enumerate(self.games):
            if game.id == game_id:
                return index
        return None

    @pyqtProperty(Game, notify=currentGameChanged)
    def currentGame(self):
        return self._currentGame

    @currentGame.setter
    def currentGame(self, game):
        if game != self._currentGame:
            self._currentGame = game
            self.currentGameChanged.emit()

    @pyqtProperty(str, notify=logChanged)
    def log(self):
        return self._log

    @log.setter
    def log(self, data):
        if data:
            self._log += data
            self.logChanged.emit()

    @pyqtProperty(QQmlListProperty, notify=libraryChanged)
    def games(self):
        return QQmlListProperty(Game, self, self._games)

    @games.setter
    def games(self, games):
        if games != self._games:
            self._games = games
            self.libraryChanged.emit()

    def appendGame(self, game):
        self._games.append(game)
        self.libraryChanged.emit()

    def indexUpdated(self, index):
        self.currentGame = self._games[index]

    def installGame(self, game_id):
        self._currentGame.installing = True
        installThread = InstallThread(self._currentGame.ref)
        installThread.outputChanged.connect(self.updateLog)
        installThread.finished.connect(self.installFinished)
        installThread.start()
        self._threads.append(installThread)

    def installFinished(self):
        self._currentGame.installing = False
        self._currentGame.installed = True
        (GameRecord.replace(
            id=self._currentGame.id,
            installed=self._currentGame.installed,
            modified_date=datetime.datetime.now()
        ).execute())
        self._log = '';
        self.logChanged.emit()

    def playGame(self, game_id):
        idx = self.findById(game_id)
        if idx is not None:
            self._currentGame.playing = True
            playThread = PlayThread(self._currentGame.ref)

            playThread.finished.connect(self._games[idx].stopGame)
            playThread.start()

            self._threads.append(playThread)
            print('run game')

    def stopGame(self):
        self._currentGame.playing = False
        print('stop game')

    # def logClear(self):


    def updateLog(self, data):
        print(data)
        self.log = data

# class Loader():


def main():
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    print('Press Ctrl+C')

    db.connect()
    db.create_tables([GameRecord], safe=True)

    app = QGuiApplication(argv)

    qmlRegisterType(Game, 'Example', 1, 0, 'Game')
    qmlRegisterType(Library, 'Example', 1, 0, 'Library')
    # qmlRegisterSingletonType()
    library = Library()

    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty('library', library)

    engine.load('main.qml')

    engine.rootObjects()[0].indexUpdated.connect(library.indexUpdated)
    engine.rootObjects()[0].installGame.connect(library.installGame)
    engine.rootObjects()[0].playGame.connect(library.playGame)

    exit(app.exec_())


if __name__ == '__main__':
    main()
