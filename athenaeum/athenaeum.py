import signal, os, sys
from functools import partial

from PyQt5.QtGui import QIcon
from PyQt5.QtCore import QTranslator, QLocale, Qt, QVariant, QMetaType, QStandardPaths
from PyQt5.QtQml import QQmlApplicationEngine, qmlRegisterType
from PyQt5.QtWidgets import QApplication

APP_NAME = 'com.gitlab.librebob.Athenaeum'
APP_TITLE = 'athenaeum'
APP_UPPER_TITLE = 'Athenaeum'
APP_DEFAULT_WIDTH = 1280
APP_DEFAULT_HEIGHT = 720

# Helpful snippet from kawaii-player https://github.com/kanishka-linux/kawaii-player/
if getattr(sys, 'frozen', False):
    BASEDIR, BASEFILE = os.path.split(os.path.abspath(sys.executable))
else:
    BASEDIR, BASEFILE = os.path.split(os.path.abspath(__file__))
sys.path.insert(0, BASEDIR)

from browse import Browse, Recommendation
from game import Game
from gamemanager import GameManager, GameManagerFactory
from library import Library
from loader import Loader, LoaderFactory
from models import Database, MetaRepository, SettingRepository, GameRepository
from network import NetworkAccessManagerFactory
from notify import Notify
from recommender import Recommender
from search import Search
from settings import Settings
from systemtrayicon import SystemTrayIcon
from mousehandler import MouseHandler


def cleanUp(applicationWindow=None, metaRepository=None):
    metaRepository.set('window_width', applicationWindow.property('width'))
    metaRepository.set('window_height', applicationWindow.property('height'))

    metaRepository.set('window_x', applicationWindow.property('x'))
    metaRepository.set('window_y', applicationWindow.property('y'))

def main():
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    print('Press Ctrl+C to quit.')

    inFlatpak = os.path.isfile('/.flatpak-info')

    os.environ['QT_STYLE_OVERRIDE'] = ''
    os.environ['QT_QUICK_CONTROLS_STYLE'] = 'Material'
    #os.environ['QT_QPA_PLATFORM'] = 'wayland;xcb'

    app = QApplication(sys.argv)

    app.setApplicationDisplayName(APP_UPPER_TITLE)
    app.setApplicationName(APP_NAME)
    app.setWindowIcon(QIcon.fromTheme(app.applicationName(), QIcon(BASEDIR + '/resources/icons/hicolor/64x64/' + app.applicationName() + '.png')))
    app.setQuitOnLastWindowClosed(True)

    tr = QTranslator()
    loaded = tr.load(QLocale.system(), app.applicationName(), "_", BASEDIR + "/translations");
    if loaded:
        print('Loaded ' + QLocale.system().name() + ' translation.')
    else:
        print('Using default translation.')

    app.installTranslator(tr)

    qmlRegisterType(GameManager, APP_UPPER_TITLE, 1, 0, 'GameManager')
    qmlRegisterType(Game, APP_UPPER_TITLE, 1, 0, 'Game')
    qmlRegisterType(Library, APP_UPPER_TITLE, 1, 0, 'Library')
    qmlRegisterType(Loader, APP_UPPER_TITLE, 1, 0, 'Loader')
    qmlRegisterType(Settings, APP_UPPER_TITLE, 1, 0, 'Settings')
    qmlRegisterType(Browse, APP_UPPER_TITLE, 1, 0, 'Browse')
    qmlRegisterType(Recommender, APP_UPPER_TITLE, 1, 0, 'Recommender')
    qmlRegisterType(Recommendation, APP_UPPER_TITLE, 1, 0, 'Recommendation')
    qmlRegisterType(Search, APP_UPPER_TITLE, 1, 0, 'Search')
    qmlRegisterType(MouseHandler, APP_UPPER_TITLE, 1, 0, 'MouseHandler')

    database = Database(dataPath=QStandardPaths.writableLocation(QStandardPaths.AppDataLocation))
    database.init()

    metaRepository = MetaRepository(db=database)
    settingRepository = SettingRepository(db=database)
    gameRepository = GameRepository(db=database)

    loaderFactory = LoaderFactory(parent=app, inFlatpak=inFlatpak, db=database, metaRepository=metaRepository, gameRepository=gameRepository)
    gameManagerFactory = GameManagerFactory(parent=app, inFlatpak=inFlatpak, gameRepository=gameRepository)

    settings = Settings(parent=app, settingRepository=settingRepository)
    loader = loaderFactory.create()
    gameManager = gameManagerFactory.create()
    recommender = Recommender(parent=app, gameManager=gameManager)
    
    library = Library(parent=app, gameManager=gameManager, metaRepository=metaRepository)
    browse = Browse(parent=app, gameManager=gameManager, recommender=recommender)
    search = Search(parent=app, gameManager=gameManager, recommender=recommender)
    
    loader.started.connect(gameManager.reset)
    loader.finished.connect(gameManager.load)
    loader.gameLoaded.connect(gameManager.appendGame)
    
    gameManager.ready.connect(recommender.load)
    
    gameManager.ready.connect(library.load)
    gameManager.ready.connect(browse.load)
    gameManager.ready.connect(search.load)

    networkAccessManagerFactory = NetworkAccessManagerFactory()

    mouseHandler = MouseHandler()
    app.installEventFilter(mouseHandler)

    engine = QQmlApplicationEngine(parent=app)
    engine.setNetworkAccessManagerFactory(networkAccessManagerFactory)
    engine.rootContext().setContextProperty('settings', settings)
    engine.rootContext().setContextProperty('loader', loader)
    engine.rootContext().setContextProperty('library', library)
    engine.rootContext().setContextProperty('browse', browse)
    engine.rootContext().setContextProperty('search', search)
    engine.rootContext().setContextProperty('gameManager', gameManager)
    engine.rootContext().setContextProperty('recommender', recommender)
    engine.rootContext().setContextProperty('mouseHandler', mouseHandler)

    engine.load(BASEDIR + '/Athenaeum.qml')

    root = engine.rootObjects()[0]

    app.aboutToQuit.connect(partial(cleanUp, root, metaRepository))
    
    root.setProperty('width', metaRepository.get('window_width') or APP_DEFAULT_WIDTH)
    root.setProperty('height', metaRepository.get('window_height') or APP_DEFAULT_HEIGHT)
    
    rect = app.desktop().screenGeometry()

    root.setProperty('x', metaRepository.get('window_x') or rect.width() / 2 - APP_DEFAULT_WIDTH / 2)
    root.setProperty('y', metaRepository.get('window_y') or rect.height() / 2 - APP_DEFAULT_HEIGHT / 2)

    root.indexUpdated.connect(library.indexUpdated)
    root.installGame.connect(library.installGame)
    root.uninstallGame.connect(library.uninstallGame)
    root.updateGame.connect(library.updateGame)
    root.playGame.connect(library.playGame)
    root.cancelGame.connect(library.cancelGame)

    root.markInstalled.connect(library.markInstalled)
    root.markUninstalled.connect(library.markUninstalled)
    root.clearErrors.connect(library.clearErrors)

    root.updateAll.connect(loader.runUpdateCommands)
    root.checkAll.connect(loader.runListCommands)
    root.resetDatabase.connect(loader.reset)

    try:
        notify = Notify(parent=app, name=APP_UPPER_TITLE)
        gameManager.displayNotification.connect(notify.showNotifitcation)
    except Exception:
        print('Error initializing notifications.')

    #systemTrayIcon = SystemTrayIcon(icon=QIcon.fromTheme(app.applicationName(), QIcon(BASEDIR + '/resources/icons/hicolor/32x32/' + app.applicationName() + '.png')),
    #root=root, show=settings.showTrayIcon, parent=app)

    #systemTrayIcon.playGame.connect(library.playGame)
    #library.filtersChanged.connect(systemTrayIcon.prepareMenu)

    #settings.showTrayIconChanged.connect(systemTrayIcon.setVisible)
    # settings.closeToTrayChanged.connect(app.setQuitOnLastWindowClosed)

    loader.load()

    os._exit(app.exec())


if __name__ == '__main__':
    main()
