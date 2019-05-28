import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
// import QtGraphicalEffects 1.3
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
                color: Material.background
                
                SwipeView {
                    id: swipeView
                    anchors.fill: parent
                    
                    Repeater {
                        model: browse.spotlight
                        Item {
                            id: secondPage
                            Image {
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                                clip: true
                                source: screenshots[0] ? screenshots[0].sourceUrl : ''
                            }
                            Rectangle {
                                width: newGames.width
                                height: parent.height
                                anchors.centerIn: parent
                                color: tr
                                Text {
                                    id: gameTitle
                                    text: name
                                    color: Material.foreground
                                    font.pixelSize: 64
                                    font.bold: true
                                }
                                Text {
                                    anchors.top: gameTitle.bottom
                                    text: summary
                                    color: Material.foreground
                                    font.pixelSize: 24
                                    width: parent.width
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }
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
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 400
                height: recommendedHeading.height
                color: Material.background
                Text {
                    id: recommendedHeading
                    anchors.left: parent.left
                    text: 'Recommended For You'
                    color: Material.foreground
                    font.pixelSize: 24
                }
//                 Button {
//                     anchors.right: parent.right
//                     anchors.verticalCenter: parent.verticalCenter
//                     text: qsTr('View More')
//                 }
            }
            
            GridView {
                id: gv
                width: parent.width - 400
                height: contentHeight
                anchors.horizontalCenter: parent.horizontalCenter
                boundsBehavior: Flickable.StopAtBounds
                model: browse.recommended
                property int minWidth: 270
                cellWidth: width > minWidth ? width / Math.floor(width / minWidth) : width
                cellHeight: 150
                delegate: 
                Rectangle {
                        color: Material.color(Material.Grey, theme == Material.Dark ? Material.Shade900 : Material.Shade100)
                        width: gv.cellWidth
                        height: gv.cellHeight
                        border.width: 5
                        border.color: Material.background
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                enter(gameView, id)
                            }
                        }
                    Column {
                        padding: 10
                        width: parent.width

                        Row {
                            padding: 5
                            spacing: 5
                            Image {
                               
                                id: iconPr
                                width: 50
                                height: 50
                                fillMode: Image.PreserveAspectFit
                                source: iconLarge
                            }

                            Text {
                                text: name
                                color: Material.foreground
                                font.pixelSize: 20
                            }
                        }
                        Text {
                            padding: 5
                            text: 'Because you played: '
                            color: Material.foreground
                            font.pixelSize: 18
                        }
                        Row {
                            padding: 5
                            spacing: 5
                            Image {
                                width: 25
                                fillMode: Image.PreserveAspectFit
                                source: library.currentGame.iconSmall
                            }
                            Text {
                                text: library.currentGame.name
                                color: Material.foreground
                                font.pixelSize: 18
                            }
                        }
                    }
                }
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 400
                height: newHeading.height
                color: Material.background
                Text {
                    id: newHeading
                    anchors.left: parent.left
                    text: 'New and Popular'
                    width: 200
                    color: Material.foreground
                    font.pixelSize: 24
                }
//                 Button {
//                     anchors.right: parent.right
//                     anchors.verticalCenter: parent.verticalCenter
//                     text: qsTr('View More')
//                 }
            }
            Rectangle {
                id: newGames
                width: parent.width - 400
                height: newList.height
                color: Material.color(Material.Grey, theme == Material.Dark ? Material.Shade900 : Material.Shade100)
                anchors.horizontalCenter: parent.horizontalCenter
                ListView {
                    model: browse.new
                    id: newList
                    anchors.left: parent.left
                    anchors.right: previewGame.left
                    height: contentHeight
                    boundsBehavior: Flickable.StopAtBounds
                    delegate: Component {
                        Rectangle {
                            width: parent.width
                            height: 70
                            color:   ListView.isCurrentItem ? Material.color(Material.Grey, theme == Material.Dark ? Material.Shade900 : Material.Shade100) : Material.background
                            MouseArea {
                                anchors.fill: parent
                                onEntered: {
                                    newList.currentIndex = index
                                }
                                onClicked: {
                                    enter(gameView, id)
                                }
                                hoverEnabled: true
                            }
                            
                            Row {
                                padding: 10
                                spacing: 5
                                Image {
                                    height: 50
                                    width: 50
                                    anchors.margins: 5
                                    fillMode: Image.PreserveAspectFit
                                    source: iconLarge
                                }
                                Text {
                                    text: name
                                    color: Material.foreground
                                    font.pixelSize: 20
                                }
                            }
                        }
                    }
                }
                GridView {
                    id: previewGame
                    width: 300
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    boundsBehavior: Flickable.StopAtBounds
                    model: newList.model[newList.currentIndex] ? newList.model[newList.currentIndex].screenshots : ''
                    cellWidth: 150
                    cellHeight: 150
                    delegate: Rectangle { 
                        width: previewGame.cellWidth
                        height: previewGame.cellHeight
                        color: Material.color(Material.Grey, theme == Material.Dark ? Material.Shade900 : Material.Shade100)
                        Image {
                            anchors.fill: parent
                            anchors.margins: 5
                            width: parent.width
                            fillMode: Image.PreserveAspectCrop
                            source: thumbUrl || ''
                        }
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
