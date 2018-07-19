import QtQuick 2.6
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.4
import QtQuick.Layouts 1.11
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
                text: "Settings"
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
                        text: "Reset All"
                    }
                }
            }
        }
    }
}
