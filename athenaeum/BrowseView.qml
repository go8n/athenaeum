import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Athenaeum 1.0

Page {
    id: browseView
    header: ToolBar {
        id: toolBar
        Rectangle {
            anchors.fill: parent
            color: Material.background
            Label {
                anchors.centerIn: parent
                color: Material.foreground
                text: qsTr('Browse')
            }
            ToolButton {
                height: parent.height
                anchors.right: parent.right
                contentItem: Text {
                        text: qsTr("⋮")
                        color: Material.foreground
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                }
                onClicked: menu.open()
                Menu {
                    id: menu
                    MenuItem {
                        text: qsTr('Settings')
                        onTriggered: stackView.push(settingsView)
                    }
                    MenuItem {
                        text: qsTr('Check For Updates')
                        onTriggered: window.checkAll()
                    }
                    MenuItem {
                        text: qsTr('Update All')
                        onTriggered: window.updateAll()
                    }
                    MenuItem {
                        text: qsTr('Exit')
                        onTriggered: library.processingCount > 0 ? confirmExit.open() : Qt.quit()
                        Popup {
                            id: confirmExit
                             background: Rectangle {
                                anchors.fill: parent
                                color: Material.background
                            }
                            x: Math.round((parent.width - width) / 2)
                            y: Math.round((parent.height - height) / 2)
                            parent: stackView
                            dim: true
                            modal: true
                            contentItem: Column {
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: Material.foreground
                                    font.pixelSize: 20
                                    text: qsTr('You have operations pending.')
                                }
                                Row {
                                    topPadding: 20
                                    spacing: 20
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    Button {
                                        MouseArea {
                                            id: exitPopupMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                Qt.quit()
                                            }
                                        }
                                        contentItem: Text {
                                            color: Material.background
                                            text: qsTr('Close Anyway')
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        background: Rectangle {
                                            implicitWidth: 100
                                            implicitHeight: 40
                                            color: exitPopupMouseArea.containsMouse ? Material.color(Material.Grey, theme == Material.Dark ? Material.Shade600 : Material.Shade400) : Material.primary
                                        }
                                    }
                                    Button {
                                        contentItem: Text {
                                            color: Material.background
                                            text: qsTr('Cancel')
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        MouseArea {
                                            id: cancelExitPopupMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                confirmExit.close()
                                            }
                                        }
                                        background: Rectangle {
                                            implicitWidth: 100
                                            implicitHeight: 40
                                            color: cancelExitPopupMouseArea.containsMouse ? Material.color(Material.Grey, theme == Material.Dark ? Material.Shade600 : Material.Shade400) : Material.primary
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    Rectangle {
        height: 300
        width: parent.width
        color: 'red'
    }
}
