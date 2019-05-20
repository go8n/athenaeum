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

        CheckBox {
            checked: settings.showTrayIcon
            text: qsTr("Show Tray Icon")
            onClicked: {
                settings.showTrayIcon = checked
            }
        }
        CheckBox {
            checked: settings.alwaysShowLogs
            text: qsTr("Always Show Logs")
            onClicked: {
                settings.alwaysShowLogs = checked
            }
        }
        CheckBox {
            checked: settings.notificationsEnabled
            text: qsTr("Notifications Enabled")
            onClicked: {
                settings.notificationsEnabled = checked
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
