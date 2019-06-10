import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.3
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
                            Image {
                                id: spotlightImage
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                                clip: true
                                source: screenshots[0] ? screenshots[0].sourceUrl : ''
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    enter(gameView, id)
                                }
                            }
                            Rectangle {
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: newGames.width
                                height: parent.height
                                anchors.centerIn: parent
                                color: tr
                                Text {
                                    id: gameTitle
                                    text: name
                                    color: 'white'
                                    font.pixelSize: 64
                                    font.bold: true
                                }
                                Text {
                                    id: gameSummary
                                    anchors.top: gameTitle.bottom
                                    text: summary
                                    color: 'white'
                                    font.pixelSize: 24
                                    width: parent.width
                                    wrapMode: Text.WordWrap
                                }
                                DropShadow {
                                    anchors.fill: gameTitle
                                    horizontalOffset: 3
                                    verticalOffset: 3
                                    radius: 8.0
                                    samples: 18
                                    color: "#80000000"
                                    source: gameTitle
                                }
                                DropShadow {
                                    anchors.fill: gameSummary
                                    horizontalOffset: 3
                                    verticalOffset: 3
                                    radius: 8.0
                                    samples: 18
                                    color: "#80000000"
                                    source: gameSummary
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
            
            Flow {
                id: recommendedFlow
                width: parent.width - 400
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                property int minWidth: 250
                property int count: Math.floor(width / minWidth)
                property int spacingWidth: (count - 1) * spacing
                property int cellWidth: width > minWidth ? (width / count) - spacingWidth : width

                Repeater {
                    id: recommendedRepeated
                    model: browse.recommended
                    delegate: Rectangle {
                        color: Material.color(Material.Grey, theme == Material.Dark ? Material.Shade900 : Material.Shade100)
                        width: recommendedFlow.cellWidth
                        height: 150
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                enter(gameView, recommendedRepeated.model[index].what.id)
                            }
                        }
                        Column {
                            padding: 10
                            width: recommendedFlow.cellWidth
                            Row {
                                padding: 5
                                spacing: 5
                                Image {
                                    width: 50
                                    height: 50
                                    fillMode: Image.PreserveAspectFit
                                    source: recommendedRepeated.model[index].what.iconLarge
                                }
                                Column {
                                    Text {
                                        text: recommendedRepeated.model[index].what.name
                                        color: Material.foreground
                                        font.pixelSize: 20
                                    }
                                    Row {
                                        spacing: 5
                                        Text {
                                            text: qsTr('Flathub')
                                            color: Material.primary
                                            font.italic: true
                                            font.pixelSize: 14
                                        }
                                        Text {
                                            text: '|'   
                                            color: Material.primary
                                            font.pixelSize: 14
                                        }
                                        Text {
                                            text: recommendedRepeated.model[index].what.license
                                            color: Material.primary
                                            font.italic: true
                                            font.pixelSize: 14
                                        }
                                    }
                                }
                            }
                            Text {
                                padding: 5
                                text: qsTr('Because you play:')
                                color: Material.foreground
                                font.pixelSize: 18
                            }
                            Row {
                                padding: 5
                                spacing: 5
                                Image {
                                    width: 25
                                    fillMode: Image.PreserveAspectFit
                                    source: recommendedRepeated.model[index].why.iconSmall
                                }
                                Text {
                                    text: recommendedRepeated.model[index].why.name
                                    color: Material.foreground
                                    font.pixelSize: 18
                                }
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
                                Column {
                                    Text {
                                        text: name
                                        color: Material.foreground
                                        font.pixelSize: 20
                                    }
                                    Row {
                                        spacing: 5
                                        Text {
                                            text: qsTr('Flathub')
                                            color: Material.primary
                                            font.italic: true
                                            font.pixelSize: 14
                                        }
                                        Text {
                                            text: '|'   
                                            color: Material.primary
                                            font.pixelSize: 14
                                        }
                                        Text {
                                            text: license
                                            color: Material.primary
                                            font.italic: true
                                            font.pixelSize: 14
                                        }
                                    }
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
                    clip: true
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
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                fullscreenPreview.open()
                            }
                        }
                        FullscreenPreview {
                            id: fullscreenPreview
                            source: sourceUrl
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
