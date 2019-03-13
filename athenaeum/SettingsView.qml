import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Athenaeum 1.0

Page {
    id: settingsView

    background: Rectangle {
        anchors.fill: parent
        color: Material.background
    }
    header: ToolBar {
        id: toolBar
        RowLayout {
            spacing: 0
            anchors.fill: parent
            ToolButton {
                contentItem: Text {
                        text: qsTr("‹")
                        color: Material.foreground
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    anchors.fill: parent
                    color: Material.background
                    implicitWidth: 40
                    implicitHeight: 40
                }
                Layout.fillHeight: true
                onClicked: stackView.pop()
            }
            Label {
                background: Rectangle {
                    anchors.fill: parent
                    color: Material.background
                }
                color: Material.foreground
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
                        color: Material.foreground
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    anchors.fill: parent
                    color: Material.background
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
                color: Material.foreground
                text: qsTr("Show Tray Icon")
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
                color: Material.foreground
                text: qsTr("Always Show Logs")
            }
        }
        Row {
            CheckBox {
                checked: settings.notificationsEnabled
                onClicked: {
                    settings.notificationsEnabled = checked
                }
            }
            Text {
                height: parent.height
                verticalAlignment: Qt.AlignVCenter
                color: Material.foreground
                text: qsTr("Notifications Enabled")
            }
        }
        Row {
            Text {
                height: parent.height
                verticalAlignment: Qt.AlignVCenter
                color: Material.foreground
                text: qsTr("Theme")
                rightPadding: 10
            }
            ComboBox {
                id: materialTheme
                model: ["Light", "Dark", "System"]
                currentIndex: theme
                onActivated: {
                    settings.theme = model[index]
                    if (model[index] == "Light") {
                        theme = Material.Light
                    } else if (model[index] == "Dark") {
                        theme = Material.Dark
                    } else {
                        theme = Material.System
                    }
                }
            }
        }
        // Row {
        //     CheckBox {
        //         checked: settings.closeToTray
        //         onClicked: {
        //             settings.closeToTray = checked
        //         }
        //     }
        //     Text {
        //         height: parent.height
        //         verticalAlignment: Qt.AlignVCenter
        //         //color: tc
        //         text: qsTr("Close to Tray")
        //     }
        // }
    }
}
