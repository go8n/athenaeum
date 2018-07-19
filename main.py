import signal
from sys import argv

from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQml import QQmlApplicationEngine, qmlRegisterType

from peewee import SqliteDatabase

from game import Game
from library import Library
from models import GameRecord, db

def main():
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    print('Press Ctrl+C to quit.')

    db.connect()
    db.create_tables([GameRecord], safe=True)

    app = QGuiApplication(argv)
    app.setApplicationDisplayName('Athenaeum')

    qmlRegisterType(Game, 'Athenaeum', 1, 0, 'Game')
    qmlRegisterType(Library, 'Athenaeum', 1, 0, 'Library')

    library = Library()

    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty('library', library)

    engine.load('main.qml')

    engine.rootObjects()[0].indexUpdated.connect(library.indexUpdated)
    engine.rootObjects()[0].installGame.connect(library.installGame)
    engine.rootObjects()[0].uninstallGame.connect(library.uninstallGame)
    engine.rootObjects()[0].updateGame.connect(library.updateGame)
    engine.rootObjects()[0].playGame.connect(library.playGame)
    engine.rootObjects()[0].search.connect(library.search)

    exit(app.exec_())

if __name__ == '__main__':
    main()
