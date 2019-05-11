import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Athenaeum 1.0

Page {
    header: NavigationBar {
        activeView: 'browse'
    }
    
    Flickable {
        id: browseFront
        anchors.fill: parent
        contentHeight: column.height
        contentWidth: parent.width
        ScrollBar.vertical: ScrollBar { }
        boundsBehavior: Flickable.StopAtBounds
        Column {
            spacing: 20
            id: column
            width: parent.width
            Rectangle {
                id: highlight
                height: 300
                width: parent.width
                color: 'red'
                
                SwipeView {
                    id: swipeView

                    currentIndex: 1
                    anchors.fill: parent

                    Item {
                        id: firstPage
                    }
                    Item {
                        id: secondPage
                        Rectangle {
                            anchors.fill: parent
                            Image {
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                                clip: true
                                source: visible ? (library.currentGame.screenshots[0] ? library.currentGame.screenshots[0].sourceUrl : '') : ''
                            }
                            Rectangle {
                                width: newGames.width
                                height: parent.height
                                anchors.centerIn: parent
                                color: tr
                                Text {
                                    id: gameTitle
                                    text: library.currentGame.name
                                    color: Material.foreground
                                    font.pixelSize: 64
                                    font.bold: true
                                }
                                Text {
                                    anchors.top: gameTitle.bottom
                                    text: library.currentGame.summary
                                    color: Material.foreground
                                    font.pixelSize: 24
                                }
                                Text {
                                    text: 'Popular Now'
                                    color: Material.foreground
                                    font.pixelSize: 42
                                    anchors.bottom: parent.bottom
                                }
                            }
                        }
                    }
                    Item {
                        id: thirdPage
                    }
                }
                Button {
                    icon.source: 'icons/left.svg'
                    anchors.left: parent.left
                    height: parent.height
                    width: 60
                    onClicked: swipeView.decrementCurrentIndex()
                    background: Rectangle {
                        anchors.fill: parent
                        color: Material.primary
                        opacity: 0.4
                    }
                }
                Button {
                    icon.source: 'icons/right.svg'
                    anchors.right:parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 60
                    onClicked: swipeView.incrementCurrentIndex()
                    background: Rectangle {
                        anchors.fill: parent
                        color: Material.primary
                        opacity: 0.4
                    }
                }

                PageIndicator {
                    id: indicator

                    count: swipeView.count
                    currentIndex: swipeView.currentIndex

                    anchors.bottom: swipeView.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            
            Text {
                text: 'Recommended For You'
                color: Material.foreground
                width: parent.width - 400
                font.pixelSize: 24
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            ListView {
                width: parent.width - 400
                height: 100
                anchors.horizontalCenter: parent.horizontalCenter
                ScrollBar.horizontal: ScrollBar { 
                    policy: ScrollBar.AlwaysOn
                }
                
                boundsBehavior: Flickable.StopAtBounds
                orientation: ListView.Horizontal
                model: library.filter
                clip: true

                delegate: Component {
                    Rectangle {
                        width: 200
                        height: parent.height
                        color: Material.background
                        border.color: Material.accent
                        border.width: 1
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                changeView(gameView, id)
                            }
                        }

                        Image {
                            id: iconPr
                            anchors.top: parent.top
                            anchors.left: parent.left
                            width: 50
                            height: 50
                            anchors.margins: 5
                            fillMode: Image.PreserveAspectFit
                            source: iconLarge
                        }

                        Text {
                            anchors.left: iconPr.right
                            text: name
                            color: Material.foreground
                            font.pixelSize: 20
                        }
                        Text {
                            anchors.top: iconPr.bottom
                            text: 'Because you played: '
                            color: Material.foreground
                            font.pixelSize: 18
                        }
                    }
                }
            }
            
            Text {
                text: 'New and Popular'
                color: Material.foreground
                width: parent.width - 400
                font.pixelSize: 24
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Rectangle {
                id: newGames
                width: parent.width - 400
                height: 400
                color: Material.background
                anchors.horizontalCenter: parent.horizontalCenter
                ListView {
                    model: library.filter
                    id: newList
                    anchors.left: parent.left
                    anchors.right: previewGame.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    clip: true
                    
                    delegate: Component {
                        Rectangle {
                            width: parent.width
                            height: 50
                            color:  Material.background
                            Rectangle {
                                visible: itemMouseArea.containsMouse
                                anchors.left: parent.left 
                                width: 1
                                height: parent.height
                                color: Material.accent
                            }
                            Rectangle { 
                                visible: itemMouseArea.containsMouse
                                anchors.top: parent.top
                                height: 1
                                width: parent.width
                                color: Material.accent
                            }
                            Rectangle { 
                                visible: itemMouseArea.containsMouse
                                anchors.bottom: parent.bottom
                                height: 1
                                width: parent.width
                                color: Material.accent
                            }
                            MouseArea {
                                anchors.fill: parent
                                onEntered: {
                                    window.indexUpdated(index)

//                                     parent.color = Material.accent
                                }
                                onExited: {
//                                     parent.color = Material.background
                                }
                                id: itemMouseArea
                                hoverEnabled: true
                            }
                            
                            Rectangle {
                                id: iconPr
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: parent.height
                                height: parent.height
                                
                                color: tr
                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    fillMode: Image.PreserveAspectFit
                                    source: iconLarge
                                }
                            }
                            Text {
                                anchors.left: iconPr.right
                                text: name
                                color: Material.foreground
                                font.pixelSize: 20
                            }
                        }
                    }
                }
                GridView {
                    id: previewGame
                    width: 200
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    model: library.currentGame.screenshots
                    delegate: Image {
                        fillMode: Image.PreserveAspectFit
                        source: thumbUrl || ''
                    }
                }
            }
            Rectangle {
                height: 50
                width: parent.width
                color: tr
            }
        }
    }
}
