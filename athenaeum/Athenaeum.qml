import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Athenaeum 1.0

ApplicationWindow {
    id: window
    signal indexUpdated(int index)
    signal installGame(string id)
    signal uninstallGame(string id)
    signal updateGame(string id)
    signal playGame(string id)
    signal search(string query)
    signal filter(string filter)
    signal sort(string sort)
    signal updateAll()
    signal checkAll()
    signal notify(string name, string message, string icon)
    signal resetDatabase()

    width: 1000
    height: 700
    visible: true

    property int theme: settings.theme == 'Dark' ? Material.Dark : settings.theme == 'Light' ? Material.Light: Material.System

    property color tr: 'transparent'

    property Component libraryView: LibraryView{}
    property Component settingsView: SettingsView{}

    Material.theme: theme
    Material.accent: Material.LightBlue
    Material.primary: Material.Grey

    StackView {
        id: stackView
        anchors.fill: parent
        visible: !loader.loading
        initialItem:  libraryView
    }
    Rectangle {
        anchors.fill: parent
        color: Material.background
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
            color: Material.foreground
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
            color: Material.background
            height: 160

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
                    color: Material.foreground
                    readOnly: true
                    text: loader.log
                    background: Rectangle {
                        anchors.fill: parent
                        color: Material.background
                    }
                }
            }
        }
    }
}
