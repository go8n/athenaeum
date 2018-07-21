import QtQuick 2.6
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.4
import QtQuick.Layouts 1.11
import Athenaeum 1.0

// signal messageReceived(string person, string notice)

Page {
    id: libraryView

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
            TextField {
                id: searchField
                placeholderText: 'Search...'
                // background: Rectangle {
                //     anchors.fill: parent
                //     implicitWidth: 200
                // }
                Layout.fillHeight: true
                onTextChanged: {
                    window.search(text)
                }
                onAccepted: {
                    window.indexUpdated(0)
                }
                Keys.onEscapePressed: {
                    text = ''
                }
            }
            Label {
                background: Rectangle {
                    anchors.fill: parent
                    color: fg
                }
                color: tc
                text: "Library"
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
                // Layout.fillWidth: true
                Layout.fillHeight: true
                onClicked: menu.open()
                Menu {
                    id: menu
                    // y: fileButton.height

                    MenuItem {
                        text: "Settings"
                        onTriggered: stackView.push(settingsView)
                    }
                    MenuItem {
                        text: "Update All"
                        onTriggered: window.updateAll()
                    }
                    MenuItem {
                        text: "Exit"
                        onTriggered: Qt.quit()
                    }
                }
            }
        }
    }

    ListView {
        id: listView
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        model: library.filter
        width: 200
        ScrollBar.vertical: ScrollBar { }
        boundsBehavior: Flickable.StopAtBounds
        delegate: Component {
            id: delegateComponent
                Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 40
                id: rect
                border.color: bg
                border.width: 1
                // color: Qt.rgba(Math.random(),Math.random(),Math.random(),1)
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        window.indexUpdated(index)
                        listView.currentIndex = index
                        // stackView.push(gameView)
                        // currentItem.color = '#4d84c7';
                        // listView.currentItem.color = '#4d84c7';
                    }
                    id: itemMouseArea
                    hoverEnabled: true
                }
                // color:
                color: ListView.isCurrentItem ? sel : itemMouseArea.containsMouse ? hl : fg

                Image {
                    id: gameIcon
                    // anchors.horizontalCenter: parent.horizontalCenter
                    // anchors.verticalCenter: parent.verticalCenter
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    fillMode: Image.PreserveAspectFit

                    source: iconSmall
                }
                Text {
                    // anchors.horizontalCenter: parent.horizontalCenter
                    color: tc
                    clip: true
                    width: parent.width
                    anchors.bottom: parent.bottom
                    // wrapMode: Text.WordWrap
                    text: name
                    // horizontalAlignment: Text.AlignHCenter
                    leftPadding: gameIcon.width + 2
                    bottomPadding: 2
                }
            }
        }
    }
    ScrollView {
        id: gameDetailView
        anchors.left: listView.right
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        Column {
            id: gameColumView
            anchors.right: parent.right
            anchors.left: parent.left
            Row {
                anchors.right: parent.right
                anchors.left: parent.left
                padding: 40
                spacing: 40
                Image {
                    width: 128
                    height: 128
                    // anchors.horizontalCenter: parent.horizontalCenter
                    // anchors.verticalCenter: parent.verticalCenter
                    // anchors.left: parent.right
                    // anchors.bottom: parent.bottom
                    fillMode: Image.PreserveAspectFit

                    source: library.currentGame.iconLarge
                }
                Column {
                    // width: parent.width
                    Text {
                        color: tc
                        // fontSizeMode: Text.HorizontalFit
                        text: library.currentGame.name
                        font.pixelSize: 56
                        horizontalAlignment: Text.AlignLeft
                    }
                    Text {
                        color: tc
                        text: library.currentGame.id
                        font.pixelSize: 16
                        // leftPadding: 4
                        horizontalAlignment: Text.AlignLeft

                    }
                    Row {
                        spacing: 5
                        topPadding: 4
                        Button {
                            text: 'Install'
                            visible: !library.currentGame.installed
                            enabled: !library.currentGame.processing
                            onClicked: {
                                window.installGame(library.currentGame.id)
                            }

                        }
                        Button {
                            text: 'Play'
                            visible:  library.currentGame.installed
                            enabled: !library.currentGame.playing
                            onClicked: {
                                window.playGame(library.currentGame.id)
                            }
                            background: Rectangle {
                                implicitWidth: 100
                                implicitHeight: 40
                                color: library.currentGame.playing ? 'lightgreen' : 'lightblue'
                            }
                        }
                        Button {
                            text: 'Uninstall'
                            visible: library.currentGame.installed
                            enabled: !library.currentGame.processing
                            MouseArea {
                                id: uninstallMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    window.uninstallGame(library.currentGame.id)
                                }
                            }
                            background: Rectangle {
                                implicitWidth: 100
                                implicitHeight: 40
                                color: uninstallMouseArea.containsMouse ? 'lightcoral' : dg
                            }
                        }
                    }

                }
            }
            Row {
                visible: library.currentGame.processing
                ScrollView {
                    id: logScroller
                    height: 400
                    width: gameDetailView.width
                    // width: 500
                    // visible: library.currentGame.log
                    TextArea {
                        width: parent.width
                        color: tc
                        readOnly: true
                        text: library.currentGame.log
                        background: Rectangle {
                            anchors.fill: parent
                            color: fg

                        }
                    }
                }
            }
        }
    }
}
