import signal, os, sys

from PyQt5.QtGui import QIcon
from PyQt5.QtCore import QTranslator, QLocale
from PyQt5.QtQml import QQmlApplicationEngine, qmlRegisterType
from PyQt5.QtWidgets import QApplication

# Helpful snippet from kawaii-player https://github.com/kanishka-linux/kawaii-player/
if getattr(sys, 'frozen', False):
    BASEDIR, BASEFILE = os.path.split(os.path.abspath(sys.executable))
else:
    BASEDIR, BASEFILE = os.path.split(os.path.abspath(__file__))
sys.path.insert(0, BASEDIR)

from game import Game
from library import Library
from loader import Loader
from models import GameRecord, MetaRecord, SettingsRecord, db
from systemtrayicon import SystemTrayIcon


def main():
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    print('Press Ctrl+C to quit.')

    icon = 'athena_icon_32x32.png'

    db.connect()
    db.create_tables([GameRecord, MetaRecord, SettingsRecord], safe=True)

    app = QApplication(sys.argv)
    app.setApplicationDisplayName('Athenaeum')
    app.setWindowIcon(QIcon(icon))
    app.setQuitOnLastWindowClosed(False)

    tr = QTranslator()
    tr.load("app_" + QLocale.system().name());

    app.installTranslator(tr);

    qmlRegisterType(Game, 'Athenaeum', 1, 0, 'Game')
    qmlRegisterType(Library, 'Athenaeum', 1, 0, 'Library')
    qmlRegisterType(Loader, 'Athenaeum', 1, 0, 'Loader')

    loader = Loader(parent=app)
    library = Library(parent=app)

    loader.started.connect(library.reset)
    loader.finished.connect(library.load)
    loader.gameLoaded.connect(library.appendGame)

    engine = QQmlApplicationEngine(parent=app)
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
    root.sort.connect(library.sortGames)

    systemTrayIcon = SystemTrayIcon(icon=QIcon(icon), root=root, parent=app)
    systemTrayIcon.playGame.connect(library.playGame)
    library.recentChanged.connect(systemTrayIcon.prepareMenu)

    loader.load()

    os._exit(app.exec())

if __name__ == '__main__':
    main()
