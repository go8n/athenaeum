import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Athenaeum 1.0

Page {
    id: settingsView

    property color bg : '#202228'
    property color sel: '#4d84c7'
    property color hl: '#314661'
    property color fg: '#2d3139'
    property color tc: '#caccd1'
    property color dg: '#e0e0e0'

    background: Rectangle {
        anchors.fill: parent
        color: bg
    }
    header: ToolBar {
        id: toolBar
        RowLayout {
            spacing: 0
            anchors.fill: parent
            ToolButton {
                contentItem: Text {
                        text: qsTr("‹")
                        color: tc
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    anchors.fill: parent
                    color: fg
                    implicitWidth: 40
                    implicitHeight: 40
                }
                Layout.fillHeight: true
                onClicked: stackView.pop()
            }
            Label {
                background: Rectangle {
                    anchors.fill: parent
                    color: fg
                }
                color: tc
                text: qsTr("Settings")
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            ToolButton {
                contentItem: Text {
                        text: qsTr("⋮")
                        color: tc
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    anchors.fill: parent
                    color: fg
                    implicitWidth: 40
                    implicitHeight: 40
                }
                Layout.fillHeight: true
                onClicked: menu.open()
                Menu {
                    id: menu
                    MenuItem {
                        text: qsTr("Reset All")
                    }
                    MenuItem {
                        text: qsTr('Exit')
                        onTriggered: Qt.quit()
                    }
                }
            }
        }
    }

    Column {
        padding: 40
        Row {
            CheckBox {
                checked: settings.showTrayIcon
                onClicked: {
                    settings.showTrayIcon = checked
                }
            }
            Text {
                height: parent.height
                verticalAlignment: Qt.AlignVCenter
                color: tc
                text: qsTr("Show Tray Icon")
            }
        }
        Row {
            CheckBox {
                checked: settings.closeToTray
                onClicked: {
                    settings.closeToTray = checked
                }
            }
            Text {
                height: parent.height
                verticalAlignment: Qt.AlignVCenter
                color: tc
                text: qsTr("Close to Tray")
            }
        }
        Row {
            CheckBox {
                checked: settings.alwaysShowLogs
                onClicked: {
                    settings.alwaysShowLogs = checked
                }
            }
            Text {
                height: parent.height
                verticalAlignment: Qt.AlignVCenter
                color: tc
                text: qsTr("Always Show Logs")
            }
        }
    }
}
