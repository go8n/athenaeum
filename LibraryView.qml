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
                // elide: Label.ElideRight
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
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        window.indexUpdated(index)
                        listView.currentIndex = index
                    }
                    id: itemMouseArea
                    hoverEnabled: true
                }
                color: ListView.isCurrentItem ? sel : itemMouseArea.containsMouse ? hl : fg

                Image {
                    id: gameIcon
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: 5
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignHCenter
                    source: iconSmall
                }
                Text {
                    color: tc
                    clip: true
                    width: parent.width
                    anchors.bottom: parent.bottom
                    text: name
                    leftPadding: gameIcon.width + 2
                    bottomPadding: 2
                }
            }
        }
    }

    Rectangle {
        anchors.left: listView.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: bg
        ScrollView {
            // width: parent.width
            // height: parent.height
            anchors.fill: parent
            // ScrollBar.vertical: ScrollBar { }
            contentHeight: col.height
            contentWidth: parent.width
            Column {
                id: col
                width: parent.width

                spacing: 20
                Row {
                    padding: 40
                    spacing: 40
                    Rectangle {
                        width: 128
                        height: 128
                        Image {
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit

                            source: library.currentGame.iconLarge
                        }
                        color: fg
                        // border.color: "black"
                        // border.width: 5
                        radius: 10
                    }
                    Column {
                        spacing: 5
                        Row {
                            Text {
                                width: col.width
                                color: tc
                                text: library.currentGame.name
                                font.pixelSize: 48
                                horizontalAlignment: Text.AlignLeft
                                wrapMode: Text.WordWrap
                            }
                        }
                        Row {
                            // spacing: 10
                            Text {
                                color: tc
                                text: library.currentGame.developerName ? 'Created by ' + library.currentGame.developerName : ' '
                                font.pixelSize: 16
                                horizontalAlignment: Text.AlignLeft
                            }
                            // Text {
                            //     color: tc
                            //     text: library.currentGame.license
                            //     font.pixelSize: 16
                            //     horizontalAlignment: Text.AlignLeft
                            // }
                        }
                        Row {
                            spacing: 5
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
                ScrollView {
                    width: parent.width
                    height: 150
                    visible: library.currentGame.processing
                    TextArea {
                        anchors.fill: parent
                        color: tc
                        readOnly: true
                        text: library.currentGame.log
                        background: Rectangle {
                            anchors.fill: parent
                            color: fg
                        }
                    }
                }


                Column {
                    width: parent.width
                    clip: true
                    Rectangle {
                        visible: library.currentGame.screenshots.length
                        width: parent.width
                        height: 300
                        color: fg
                        Image {
                            fillMode: Image.PreserveAspectFit
                            anchors.fill: parent
                            source: visible ? library.currentGame.screenshots[carousel.currentIndex].sourceUrl : ''
                        }
                    }
                    ListView {
                        anchors.horizontalCenter: parent.horizontalCenter
                        id: carousel
                        clip: true
                        width: contentWidth
                        height: 50
                        visible: library.currentGame.screenshots.length
                        model: library.currentGame.screenshots
                        orientation: ListView.Horizontal
                        spacing: 5
                        boundsBehavior: Flickable.StopAtBounds
                        ScrollBar.horizontal: ScrollBar { }
                        delegate: Rectangle {
                            height: parent.height
                            width: 100
                            color: fg
                            Image {
                                anchors.fill: parent
                                anchors.margins: 1
                                // height: parent.height
                                // width: parent.width
                                fillMode: Image.PreserveAspectFit
                                source: thumbUrl
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    carousel.currentIndex = index
                                }
                                hoverEnabled: true
                                id: thumbMouseArea
                            }
                            border.color: ListView.isCurrentItem ? sel : thumbMouseArea.containsMouse ? hl : fg
                        }
                    }
                }
                Column {

                    // width: parent.width
                    Text {
                        padding: 20
                        width: col.width
                        color: tc
                        font.pixelSize: 24
                        text: 'Description'
                        wrapMode: Text.WrapAnywhere
                    }
                    Text {
                        padding: 20
                        width: col.width
                        color: tc
                        font.pixelSize: 16
                        text: library.currentGame.description
                        wrapMode: Text.WordWrap
                    }
                }
                // Rectangle {
                //
                //     color: 'red'
                //
                // }
                // Rectangle {
                //     width: parent.width
                //     height:50
                //     Text{
                //         anchors.fill: parent
                //         font.pixelSize: 48
                //         text: 'ylloooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooongggjhssssssssss'
                //         wrapMode: Text.WrapAnywhere
                //     }
                //     color: 'lightblue'
                // }

                ListView {
                    // clip: true
                    // visible: library.currentGame.releases.length
                    model: library.currentGame.releases
                    width: parent.width
                    height: contentHeight
                    spacing: 10
                    // anchors.centerIn: parent

                    // boundsBehavior: Flickable.StopAtBounds
                    delegate: Column {
                        width: parent.width
                        // height: contentHeight
                        function formatTimestamp(ts) {
                            var t = new Date( 0 );
                            t.setSeconds(ts)
                            return  t.toDateString()
                        }

                        Row {
                            width: parent.width
                            spacing: 10
                            Text {
                                leftPadding: 20
                                color: tc
                                font.pixelSize: 20
                                text: 'Version ' + version
                            }
                            Text {
                                rightPadding: 20
                                color: tc
                                font.pixelSize: 20
                                text: formatTimestamp(timestamp)
                            }
                        }
                        Text {
                            leftPadding: 20
                            rightPadding: 20
                            topPadding: 10
                            bottomPadding: 10
                            width: col.width
                            color: tc
                            font.pixelSize: 16
                            text: description
                            wrapMode: Text.WrapAnywhere
                        }
                    }
                }

                ListView {
                    // clip: true
                    model: library.currentGame.screenshots
                    width: parent.width
                    height: contentHeight
                    spacing: 30
                    // anchors.centerIn: parent

                    // boundsBehavior: Flickable.StopAtBounds
                    delegate: Rectangle {
                        width: parent.width
                        height: 50
                        color: 'green'
                        // Text {
                        //     anchors.fill: parent
                        //     font.pixelSize: 48
                        //     text: 'ylloooooooooojhssssssssss'
                        // }
                    }
                }
            }
        }
    }



    // ScrollView {
    //     id: gameDetailView
    //     anchors.left: listView.right
    //     anchors.right: parent.right
    //     anchors.bottom: parent.bottom
    //     anchors.top: parent.top
    //     // contentWidth:
    //     Column {
    //         width: libraryView - 200
    //         id: gameColumView
    //         // anchors.right: parent.right
    //         // anchors.left: parent.left
    //         Row {
    //             padding: 40
    //             spacing: 40
    //             Rectangle {
    //                 width: 128
    //                 height: 128
    //                 Image {
    //                     anchors.fill: parent
    //                     fillMode: Image.PreserveAspectFit
    //
    //                     source: library.currentGame.iconLarge
    //                 }
    //                 color: fg
    //                 // border.color: "black"
    //                 // border.width: 5
    //                 radius: 10
    //             }
    //             Column {
    //                 spacing: 5
    //                 Row {
    //                     Text {
    //                         color: tc
    //                         text: library.currentGame.name
    //                         font.pixelSize: 48
    //                         horizontalAlignment: Text.AlignLeft
    //                     }
    //                 }
    //                 Row {
    //                     // spacing: 10
    //                     Text {
    //                         color: tc
    //                         text: library.currentGame.developerName ? 'Created by ' + library.currentGame.developerName : ' '
    //                         font.pixelSize: 16
    //                         horizontalAlignment: Text.AlignLeft
    //                     }
    //                     // Text {
    //                     //     color: tc
    //                     //     text: library.currentGame.license
    //                     //     font.pixelSize: 16
    //                     //     horizontalAlignment: Text.AlignLeft
    //                     // }
    //                 }
    //                 Row {
    //                     spacing: 5
    //                     Button {
    //                         text: 'Install'
    //                         visible: !library.currentGame.installed
    //                         enabled: !library.currentGame.processing
    //                         onClicked: {
    //                             window.installGame(library.currentGame.id)
    //                         }
    //
    //                     }
    //                     Button {
    //                         text: 'Play'
    //                         visible:  library.currentGame.installed
    //                         enabled: !library.currentGame.playing
    //                         onClicked: {
    //                             window.playGame(library.currentGame.id)
    //                         }
    //                         background: Rectangle {
    //                             implicitWidth: 100
    //                             implicitHeight: 40
    //                             color: library.currentGame.playing ? 'lightgreen' : 'lightblue'
    //                         }
    //                     }
    //                     Button {
    //                         text: 'Uninstall'
    //                         visible: library.currentGame.installed
    //                         enabled: !library.currentGame.processing
    //                         MouseArea {
    //                             id: uninstallMouseArea
    //                             anchors.fill: parent
    //                             hoverEnabled: true
    //                             onClicked: {
    //                                 window.uninstallGame(library.currentGame.id)
    //                             }
    //                         }
    //                         background: Rectangle {
    //                             implicitWidth: 100
    //                             implicitHeight: 40
    //                             color: uninstallMouseArea.containsMouse ? 'lightcoral' : dg
    //                         }
    //                     }
    //                 }
    //
    //             }
    //         }
    //         Rectangle {
    //             // padding: 40
    //             // visible: library.currentGame.screenshots
    //             // Column {
    //             //     Rectangle {
    //             //
    //             //     }
    //             width: gameColumView.width
    //                 ListView {
    //                     clip: true
    //                     model: library.currentGame.screenshots
    //                     orientation: ListView.Horizontal
    //                     height: 150
    //
    //                     ScrollBar.horizontal: ScrollBar { }
    //                     boundsBehavior: Flickable.StopAtBounds
    //                     delegate: Image {
    //                         height: 150
    //                         fillMode: Image.PreserveAspectFit
    //
    //                         source: thumbUrl
    //                     }
    //
    //
    //                 }
    //             // }
    //         }
    //         Row {
    //             padding: 40
    //             // visible: library.currentGame.processing
    //             ScrollView {
    //                 id: logScroller
    //                 height: 40
    //                 // width: gameDetailView.width
    //                 TextArea {
    //                     // width: parent.width
    //                     color: tc
    //                     readOnly: true
    //                     text: library.currentGame.log
    //                     background: Rectangle {
    //                         anchors.fill: parent
    //                         color: fg
    //
    //                     }
    //                 }
    //             }
    //         }
    //     }
    // }
}
