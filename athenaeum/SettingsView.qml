import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Athenaeum 1.0

Page {
    background: Rectangle {
        anchors.fill: parent
        color: Material.background
    }
    header: NavigationBar {
        activeView: 'settings'
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
        Button {
            onClicked: {
                window.resetDatabase()
            }
            text: qsTr('Reset Database')
        }
    }
}
