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
    ScrollView {
        anchors.fill: parent
        contentHeight: column.height
        contentWidth: parent.width
//         ScrollBar.vertical.policy: ScrollBar.AlwaysOff
        Column {
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
                                width: gameSearch.width
                                height: parent.height
                                anchors.centerIn: parent
                                color: tr
                                Text {
                                    
                                    text: library.currentGame.name
                                    color: Material.foreground
                                    font.pixelSize: 64
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
                    text: "‹"
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
                    text: "›"
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
                id: filters
                width: parent.width
                height: games.height
                color: Material.background
                Rectangle {
                    visible: false
                    id: categories
                    height: contentHeight
                    width: 200
//                     color: 'blue'
                    anchors.left: parent.left
                    
                }
                Flow {
                    id: selectedTags
                    
                    anchors.left: categories.right
                    anchors.right: tags.left
//                     anchors.margins: 10
                    topPadding: 20
                    bottomPadding: 10
                    spacing: 10
                    
                    Label { 
                        text: "Strategy"; 
                        color: Material.background 
                        padding: 4
                        rightPadding: 15
                        background: Rectangle {
                            anchors.fill: parent
                            color: Material.primary
                            radius: 5
                            Image {
                                anchors.right: parent.right
                                source: "icons/close.svg"
                            }
                        }
                        
                    }
                    Label { 
                        text: "FPS"; 
                        color: Material.background 
                        padding: 4
                        rightPadding: 15
                        background: Rectangle {
                            anchors.fill: parent
                            color: Material.primary
                            radius: 5
                            Image {
                                anchors.right: parent.right
                                source: "icons/close.svg"
                            }
                        }
                        
                    }
                    Label { 
                        text: "2D"; 
                        color: Material.background 
                        padding: 4
                        rightPadding: 15
                        background: Rectangle {
                            anchors.fill: parent
                            color: Material.primary
                            radius: 5
                            Image {
                                anchors.right: parent.right
                                source: "icons/close.svg"
                            }
                        }
                        
                    }
                    Label { 
                        text: "Online"; 
                        color: Material.background 
                        padding: 4
                        rightPadding: 15
                        background: Rectangle {
                            anchors.fill: parent
                            color: Material.primary
                            radius: 5
                            Image {
                                anchors.right: parent.right
                                source: "icons/close.svg"
                            }
                        }
                        
                    }
                }
                Flow {
                    id: searchBar
                    anchors.left: categories.right
                    anchors.right: tags.left
                    anchors.top: selectedTags.bottom
                    
                    TextField {
                        id: gameSearch
                        bottomPadding: 10
                        width: parent.width * 0.7
                        placeholderText: qsTr('Search')
                        onTextChanged: {
                            library.searchValue = text
                            window.search()
                        }
                        Keys.onEscapePressed: {
                            text = ''
                        }
                        background: Rectangle {
                            anchors.fill: parent
                            color: Material.background
                        }
                        Rectangle {
                            color: Material.foreground
                            height: 1
                            width: parent.width
                            anchors.bottom: parent.bottom
                        }
                    }
                    TextField {
                        id: tagSearch
                        width: parent.width * 0.3
                        bottomPadding: 10
                        leftPadding: 10
                        placeholderText: 'Search tags'
                        background: Rectangle {
                            anchors.fill: parent
                            color: Material.background
                        }
                        Rectangle {
                            color: Material.foreground
                            height: 1
                            width: parent.width-10
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                        }
                    }

                }
                ListView {
                    id: games
                    model: library.filter
                    anchors.top: searchBar.bottom
                    anchors.left: categories.right
                    anchors.right: tags.left
                    height: contentHeight
                    anchors.topMargin: 10
        //             keyNavigationEnabled: true
                    // focus: true
//                     clip:true
//                     interactive: false

                    delegate: Component {
                        id: delegateComponent
                        Rectangle {
                            
                            height: 60
                            width: parent.width
                            color: Material.background
//                             color: Material.color(Material.Grey, Material.Shade800)
                            Rectangle {
                                id: gameIcon
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
//                                 anchors.margins: 5
                                width: parent.height
                                height: parent.height
                                
                                color: tr
//                                 radius: 10
                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    fillMode: Image.PreserveAspectFit
                                    source: iconLarge
                                }
                            }
                            Text {
                                id: gameName
                                anchors.left: gameIcon.right
                                text: name
                                font.pixelSize: 18
                                leftPadding: 10
                                topPadding: 5
                                color: Material.foreground
                            }
                            Text {
                                anchors.left: gameIcon.right
                                anchors.top: gameName.bottom
                                text: installed ? 'Installed' : 'Not Installed'
                                font.pixelSize: 14
                                leftPadding: 10
                                topPadding: 5
                                color: Material.foreground
                            }
                            Rectangle {
                                width: parent.width
                                height: 2
                                anchors.bottom: parent.bottom
                                color: Material.primary
                                opacity: 0.2
                            }
                        }
                    }
                }
                Column { 
                    visible: false
                    id: tags
                    anchors.top: selectedTags.bottom
                    anchors.right: parent.right
                    
                    Text {
                        color: Material.foreground
                        text: 'Filter by Tag'
                        width: parent.width
                        height: gameSearch.height
//                         font.pixelSize: 24
                    }

                    ListView {
                        height: 200
                        width: 200
                        id: tagsList
                        clip:true
                        ScrollBar.vertical: ScrollBar { }
                        boundsBehavior: Flickable.StopAtBounds
                        
                        model: ListModel{
                            ListElement { name:'Action'}
                            ListElement { name:'Adventure'}
                            ListElement { name:'Arcade'}
                            ListElement { name:'Board'}
                            ListElement { name:'Blocks'}
                            ListElement { name:'Card'}
                            ListElement { name:'Kids'}
                            ListElement { name:'Logic'}
                            ListElement { name:'RolePlaying'}
                            ListElement { name:'Shooter'}
                            ListElement { name:'Simulation'}
                            ListElement { name:'Sports'}
                            ListElement { name:'Strategy'}
                        }
                        
                        delegate: Component {
                            id: delegateCategory
                            Rectangle { 
                                height: 40
                                width: parent.width
                                color: Material.background
                                CheckBox{
                                text: name
                                }
                            }
                        }
                    }
                

                }
            }
        }
    }
}
