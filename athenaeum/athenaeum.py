import signal, os, sys

from PyQt5.QtGui import QIcon
from PyQt5.QtCore import QTranslator, QLocale, Qt, QVariant, QMetaType, QStandardPaths
from PyQt5.QtQml import QQmlApplicationEngine, qmlRegisterType
from PyQt5.QtWidgets import QApplication

APP_NAME = 'com.gitlab.librebob.Athenaeum'
APP_TITLE = 'athenaeum'
APP_UPPER_TITLE = 'Athenaeum'

# Helpful snippet from kawaii-player https://github.com/kanishka-linux/kawaii-player/
if getattr(sys, 'frozen', False):
    BASEDIR, BASEFILE = os.path.split(os.path.abspath(sys.executable))
else:
    BASEDIR, BASEFILE = os.path.split(os.path.abspath(__file__))
sys.path.insert(0, BASEDIR)

from notify import Notify
from game import Game
from gamemanager import GameManager
from settings import Settings
from library import Library
from browse import Browse
from search import Search
from loader import Loader
from models import Database, MetaRepository, SettingRepository, GameRepository
from network import NetworkAccessManagerFactory
from systemtrayicon import SystemTrayIcon


def main():
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    print('Press Ctrl+C to quit.')

    inFlatpak = False
    if os.path.isfile('/.flatpak-info'):
        inFlatpak = True

    os.environ['QT_STYLE_OVERRIDE'] = ''
    os.environ['QT_QUICK_CONTROLS_STYLE'] = 'Material'
    #os.environ['QT_QPA_PLATFORM'] = 'wayland;xcb'

    app = QApplication(sys.argv)

    app.setApplicationDisplayName(APP_UPPER_TITLE)
    app.setApplicationName(APP_NAME)
    app.setWindowIcon(QIcon.fromTheme(app.applicationName(), QIcon(BASEDIR + '/resources/icons/hicolor/64x64/' + app.applicationName() + '.png')))
    app.setQuitOnLastWindowClosed(False)

    tr = QTranslator()
    loaded = tr.load(QLocale.system(), app.applicationName(), "_", BASEDIR + "/translations");
    if loaded:
        print('Loaded ' + QLocale.system().name() + ' translation.')
    else:
        print('Using default translation.')

    app.installTranslator(tr);

    qmlRegisterType(Game, APP_UPPER_TITLE, 1, 0, 'Game')
    qmlRegisterType(Library, APP_UPPER_TITLE, 1, 0, 'Library')
    qmlRegisterType(Loader, APP_UPPER_TITLE, 1, 0, 'Loader')
    qmlRegisterType(Settings, APP_UPPER_TITLE, 1, 0, 'Settings')
    qmlRegisterType(Browse, APP_UPPER_TITLE, 1, 0, 'Browse')
    qmlRegisterType(Search, APP_UPPER_TITLE, 1, 0, 'Search')

    database = Database(dataPath=QStandardPaths.writableLocation(QStandardPaths.AppDataLocation))
    database.init()

    metaRepository = MetaRepository(db=database)
    settingRepository = SettingRepository(db=database)
    gameRepository = GameRepository(db=database)

    settings = Settings(parent=app, settingRepository=settingRepository)
    loader = Loader(parent=app, flatpak=inFlatpak, db=database, metaRepository=metaRepository, gameRepository=gameRepository)
    gameManager = GameManager(flatpak=inFlatpak, gameRepository=gameRepository)
    library = Library(parent=app, gameManager=gameManager, metaRepository=metaRepository)
    browse = Browse(parent=app, gameManager=gameManager)
    search = Search(parent=app, gameManager=gameManager)
    
    loader.started.connect(gameManager.reset)
    loader.finished.connect(gameManager.load)
    loader.gameLoaded.connect(gameManager.appendGame)
    
    gameManager.ready.connect(library.load)
    gameManager.ready.connect(browse.load)
    gameManager.ready.connect(search.load)

    networkAccessManagerFactory = NetworkAccessManagerFactory()

    engine = QQmlApplicationEngine(parent=app)
    engine.setNetworkAccessManagerFactory(networkAccessManagerFactory)
    engine.rootContext().setContextProperty('settings', settings)
    engine.rootContext().setContextProperty('loader', loader)
    engine.rootContext().setContextProperty('library', library)
    engine.rootContext().setContextProperty('browse', browse)
    engine.rootContext().setContextProperty('search', search)

    engine.load(BASEDIR + '/Athenaeum.qml')

    root = engine.rootObjects()[0]

    root.indexUpdated.connect(library.indexUpdated)
    root.installGame.connect(library.installGame)
    root.uninstallGame.connect(library.uninstallGame)
    root.updateGame.connect(library.updateGame)
    root.playGame.connect(library.playGame)

    root.updateAll.connect(loader.runUpdateCommands)
    root.checkAll.connect(loader.runListCommands)
    root.resetDatabase.connect(loader.reset)

    root.searchGames.connect(library.searchGames)
    root.filter.connect(library.filterGames)

    try:
        notify = Notify(APP_UPPER_TITLE)
        root.notify.connect(notify.show_notifitcation)
    except Error as e:
        print('Error initializing notifications.');

    systemTrayIcon = SystemTrayIcon(icon=QIcon.fromTheme(app.applicationName(), QIcon(BASEDIR + '/resources/icons/hicolor/32x32/' + app.applicationName() + '.png')),
    root=root, show=settings.showTrayIcon, parent=app)

    systemTrayIcon.playGame.connect(library.playGame)
    library.filtersChanged.connect(systemTrayIcon.prepareMenu)

    settings.showTrayIconChanged.connect(systemTrayIcon.setVisible)
    # settings.closeToTrayChanged.connect(app.setQuitOnLastWindowClosed)

    loader.load()

    os._exit(app.exec())


if __name__ == '__main__':
    main()
