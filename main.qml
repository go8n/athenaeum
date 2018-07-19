import QtQuick 2.6
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import Athenaeum 1.0

// property Item item0: Library
// property alias libview: Library

ApplicationWindow {
    id: window
    signal indexUpdated(int index)
    signal installGame(string id)
    signal uninstallGame(string id)
    signal updateGame(string id)
    signal playGame(string id)
    signal search(string query)

    width: 1000
    height: 700
    visible: true

    // property Component gameView: GameView{}
    property Component libraryView: LibraryView{}

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem:  libraryView
    }
}
