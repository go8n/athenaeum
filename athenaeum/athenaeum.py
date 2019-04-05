import signal, os, sys

from PyQt5.QtGui import QIcon
from PyQt5.QtCore import QTranslator, QLocale, Qt, QVariant, QMetaType
from PyQt5.QtQml import QQmlApplicationEngine, qmlRegisterType
from PyQt5.QtWidgets import QApplication

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
from models import GameRecord, MetaRecord, SettingsRecord, db
from systemtrayicon import SystemTrayIcon


def main():
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    print('Press Ctrl+C to quit.')

    db.connect()
    db.create_tables([GameRecord, MetaRecord, SettingsRecord], safe=True)

    os.environ['QT_STYLE_OVERRIDE'] = ''
    os.environ['QT_QUICK_CONTROLS_STYLE'] = 'Material'
    #os.environ['QT_QPA_PLATFORM'] = 'wayland;xcb'

    app = QApplication(sys.argv)

    app.setApplicationDisplayName('Athenaeum')
    app.setWindowIcon(QIcon.fromTheme('athenaeum', QIcon(BASEDIR + "/resources/icons/hicolor/64x64/athenaeum.png")))
    app.setQuitOnLastWindowClosed(False)

    tr = QTranslator()
    loaded = tr.load(QLocale.system(), "athenaeum", "_", BASEDIR + "/translations");
    if loaded:
        print('Loaded ' + QLocale.system().name() + ' translation.')
    else:
        print('Using default translation.')

    app.installTranslator(tr);

    qmlRegisterType(Game, 'Athenaeum', 1, 0, 'Game')
    qmlRegisterType(Library, 'Athenaeum', 1, 0, 'Library')
    qmlRegisterType(Loader, 'Athenaeum', 1, 0, 'Loader')
    qmlRegisterType(Settings, 'Athenaeum', 1, 0, 'Settings')

    settings = Settings(parent=app)
    loader = Loader(parent=app)
    library = Library(parent=app)

    loader.started.connect(library.reset)
    loader.finished.connect(library.load)
    loader.gameLoaded.connect(library.appendGame)

    engine = QQmlApplicationEngine(parent=app)
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

    root.search.connect(library.searchGames)
    root.filter.connect(library.filterGames)

    notify = None
    try:
        notify = Notify("Athenaeum")
        root.notify.connect(notify.show_notifitcation)
    except Error as e:
        print('Error initializing notifications.');

    systemTrayIcon = SystemTrayIcon(icon=QIcon.fromTheme('athenaeum', QIcon(BASEDIR + "/resources/icons/hicolor/32x32/athenaeum.png")),
    root=root, show=settings.showTrayIcon, parent=app)

    systemTrayIcon.playGame.connect(library.playGame)
    library.filtersChanged.connect(systemTrayIcon.prepareMenu)

    settings.showTrayIconChanged.connect(systemTrayIcon.setVisible)
    # settings.closeToTrayChanged.connect(app.setQuitOnLastWindowClosed)

    loader.load()

    os._exit(app.exec())


if __name__ == '__main__':
    main()
