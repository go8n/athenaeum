import QtQuick 2.7
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import Athenaeum 1.0

ApplicationWindow {
    id: window
    signal indexUpdated(int index)
    signal installGame(string id)
    signal uninstallGame(string id)
    signal updateGame(string id)
    signal playGame(string id)
    signal search(string query)
    signal updateAll()
    signal checkAll()
    signal filterAll()
    signal filterInstalled()
    // signal filterFavourites()
    signal filterRecent()
    signal sortAZ()
    signal sortZA()

    width: 1000
    height: 700
    visible: true

    property color bg : '#202228'
    property color sel: '#4d84c7'
    property color hl: '#314661'
    property color fg: '#2d3139'
    property color tc: '#caccd1'
    property color dg: '#e0e0e0'

    // property Component gameView: GameView{}
    property Component libraryView: LibraryView{}
    property Component settingsView: SettingsView{}

    StackView {
        id: stackView
        anchors.fill: parent
        visible: !loader.loading
        initialItem:  libraryView
    }
    Rectangle {
        anchors.fill: parent
        color: bg
        visible: loader.loading
        BusyIndicator {
            id: loadingIndicator
            anchors.centerIn: parent
            running: loader.loading && !loader.error
        }
        Text {
            id: loadingMessage
            anchors.top: loadingIndicator.bottom
            text: loader.message
            color: tc
            width: parent.width
            topPadding: 10
            horizontalAlignment: Text.AlignHCenter
        }

        /* Logs */
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 40
            anchors.leftMargin: 40
            anchors.bottom: parent.bottom
            color: bg
            height: 150

            Flickable {
                id: testFlick
                anchors.fill: parent

                clip: true
                boundsBehavior: Flickable.StopAtBounds

                TextArea {
                    id: ta
                    onContentHeightChanged: {
                        testFlick.contentY = (contentHeight <= 150 ? 0 : contentHeight - 150)
                    }
                    color: tc
                    readOnly: true
                    text: loader.log
                }
            }
        }
    }

}
