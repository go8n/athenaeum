import signal, os, sys

from PyQt5.QtGui import QIcon
from PyQt5.QtCore import QTranslator, QLocale, Qt, QVariant, QMetaType
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
from settings import Settings
from library import Library
from loader import Loader
from models import initDatabase, MetaRepository, SettingRepository, GameRepository
from network import NetworkAccessManagerFactory
from systemtrayicon import SystemTrayIcon


def main():
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    print('Press Ctrl+C to quit.')

    inFlatpak = False
    if os.path.isfile('/.flatpak-info'):
        inFlatpak = True

    initDatabase()

    os.environ['QT_STYLE_OVERRIDE'] = ''
    os.environ['QT_QUICK_CONTROLS_STYLE'] = 'Material'
    #os.environ['QT_QPA_PLATFORM'] = 'wayland;xcb'

    app = QApplication(sys.argv)

    app.setApplicationDisplayName(APP_UPPER_TITLE)
    app.setApplicationName(APP_NAME)
    app.setWindowIcon(QIcon.fromTheme(APP_NAME, QIcon(BASEDIR + "/resources/icons/hicolor/64x64/com.gitlab.librebob.Athenaeum.png")))
    app.setQuitOnLastWindowClosed(False)

    tr = QTranslator()
    loaded = tr.load(QLocale.system(), APP_NAME, "_", BASEDIR + "/translations");
    if loaded:
        print('Loaded ' + QLocale.system().name() + ' translation.')
    else:
        print('Using default translation.')

    app.installTranslator(tr);

    qmlRegisterType(Game, APP_UPPER_TITLE, 1, 0, 'Game')
    qmlRegisterType(Library, APP_UPPER_TITLE, 1, 0, 'Library')
    qmlRegisterType(Loader, APP_UPPER_TITLE, 1, 0, 'Loader')
    qmlRegisterType(Settings, APP_UPPER_TITLE, 1, 0, 'Settings')

    metaRepository = MetaRepository()
    settingRepository = SettingRepository()
    gameRepository = GameRepository()

    settings = Settings(parent=app, settingRepository=settingRepository)
    loader = Loader(parent=app, flatpak=inFlatpak, metaRepository=metaRepository, gameRepository=gameRepository)
    library = Library(parent=app, flatpak=inFlatpak, metaRepository=metaRepository, gameRepository=gameRepository)

    loader.started.connect(library.reset)
    loader.finished.connect(library.load)
    loader.gameLoaded.connect(library.appendGame)

    networkAccessManagerFactory = NetworkAccessManagerFactory()

    engine = QQmlApplicationEngine(parent=app)
    engine.setNetworkAccessManagerFactory(networkAccessManagerFactory)
    engine.rootContext().setContextProperty('settings', settings)
    engine.rootContext().setContextProperty('loader', loader)
    engine.rootContext().setContextProperty('library', library)

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

    root.search.connect(library.searchGames)
    root.filter.connect(library.filterGames)

    try:
        notify = Notify(APP_UPPER_TITLE)
        root.notify.connect(notify.show_notifitcation)
    except Error as e:
        print('Error initializing notifications.');

    systemTrayIcon = SystemTrayIcon(icon=QIcon.fromTheme(APP_NAME, QIcon(BASEDIR + "/resources/icons/hicolor/32x32/com.gitlab.librebob.Athenaeum.png")),
    root=root, show=settings.showTrayIcon, parent=app)

    systemTrayIcon.playGame.connect(library.playGame)
    library.filtersChanged.connect(systemTrayIcon.prepareMenu)

    settings.showTrayIconChanged.connect(systemTrayIcon.setVisible)
    # settings.closeToTrayChanged.connect(app.setQuitOnLastWindowClosed)

    loader.load()

    os._exit(app.exec())


if __name__ == '__main__':
    main()
