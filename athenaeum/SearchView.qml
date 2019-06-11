import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Athenaeum 1.0

Page {
    header: NavigationBar {
        activeView: 'search'
    }
    
    property string searchValue
    
    Flickable {
        anchors.fill: parent
        contentHeight: rec.height
        contentWidth: contentWidth
        ScrollBar.vertical: ScrollBar { }
        boundsBehavior: Flickable.StopAtBounds
        Rectangle {
            id: rec
            width: parent.width - 300
            height: childrenRect.height
            anchors.horizontalCenter: parent.horizontalCenter
            color: tr
            TextField {
                anchors.top: parent.top
                id: searchField
                width: parent.width
                text: searchValue
                font.pixelSize: 24
                placeholderText: qsTr('Search games...')
                
                onTextChanged: {
                    search.searchValue = text
                }
                Keys.onEscapePressed: {
                    text = ''
                }
            }
            Flow {
                id: activeTags
                anchors.top: searchField.bottom
                anchors.right: filtersCol.left
                anchors.left: parent.left
                spacing: 5
                Repeater {
                    model: search.activeTags
                    Button {
                        text: name
                        icon.source: 'icons/close.svg'
                        font.capitalization: Font.MixedCase
                        topPadding: 8
                        bottomPadding: 8
                        
                        icon.color: Material.background
                        icon.width: 15
                        icon.height: 15
                        Component.onCompleted: {
                            contentItem.color = Material.background
                        }
                        background: Rectangle {
                            color: Material.accent
                            radius: 10
                        }
                        onClicked: {
                            active = false
                        }
                    }
                }
            }
            Text {
                visible: searchResults.model.length <= 0
                anchors.top: activeTags.bottom
                text: qsTr('No resoults found.')
                color: Material.primary
                font.italic: true
                font.pixelSize: 16
            }
            ListView {
                anchors.top: activeTags.bottom
                model: search.results
                id: searchResults
                anchors.left: parent.left
                anchors.right: filtersCol.left
                height: contentHeight+40
                boundsBehavior: Flickable.StopAtBounds
                delegate: Component {
                    Rectangle {
                        width: parent.width
                        height: 70
                        color: Material.color(Material.Grey, theme == Material.Dark ? Material.Shade900 : Material.Shade100)
                        border.color: Material.background
                        border.width: 2.5
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                enter(gameView, id)
                            }
                            hoverEnabled: true
                        }
                        
                        Row {
                            padding: 10
                            spacing: 10
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
            
            Column {
                anchors.top: searchField.bottom
                id: filtersCol
                anchors.right: parent.right
                width: 200
                padding: 10
                spacing: 10
                Text {
                    color: Material.foreground
                    font.pixelSize: 24
                    text: 'Sort By'
                }
                ComboBox {
                    width: parent.width
                    model: ["Relevance", "A-Z", "Z-A"]
                    onActivated: {
                        search.sortValue = currentIndex
                    }
                }
                Column {
                    width: 200
                    Text {
                        color: Material.foreground
                        font.pixelSize: 24
                        text: qsTr('Tags')
                    }
                    TextField {
                        id: tagSearch
                        width: parent.width
                        placeholderText: qsTr('Search tags...')
                        onTextChanged: {
                            search.searchTagsValue = text
                        }
                        Keys.onEscapePressed: {
                            text = ''
                        }
                    }
                    Rectangle {
                        height: 200
                        width: parent.width
                        color: Material.color(Material.Grey, theme == Material.Dark ? Material.Shade900 : Material.Shade100)
                    
                        ListView {
                            id: tags
                            anchors.fill: parent
                            clip: true
                            model: search.searchTags
                            spacing: 0
                            
                            delegate: CheckBox {
                                text: name
                                topPadding: 5
                                bottomPadding: 5
                                checked: active
                                onCheckedChanged: {
                                    active = checked
                                    search.searchQueryChanged()
                                }
                            }
                            ScrollBar.vertical: ScrollBar { 
                                policy: ScrollBar.AlwaysOn
                            }
                            boundsBehavior: Flickable.StopAtBounds
                            
                        }
                    }
                }
                Text {
                    color: Material.foreground
                    font.pixelSize: 24
                    text: 'Platform'
                }
                Rectangle {
                    height: childrenRect.height
                    width: parent.width
                    color: Material.color(Material.Grey, theme == Material.Dark ? Material.Shade900 : Material.Shade100)
                  
                    ListView {
                        id: platforms
                        height: contentHeight
                        width: parent.width
                        model: search.platforms
                        delegate: CheckBox {
                            topPadding: 5
                            bottomPadding: 5
                            text: search.platforms[index]
                            checked: true
                            enabled: false
                        }
                    }
                }
                Text {
                    color: Material.foreground
                    font.pixelSize: 24
                    text: 'Repository'
                }
                Rectangle {
                    height: childrenRect.height
                    width: parent.width
                    color: Material.color(Material.Grey, theme == Material.Dark ? Material.Shade900 : Material.Shade100)
                  
                    ListView {
                        id: repositories
                        height: contentHeight
                        width: parent.width
                        model: search.repositories
                        delegate: CheckBox {
                            topPadding: 5
                            bottomPadding: 5
                            text: search.repositories[index]
                            checked: true
                            enabled: false
                        }
                        
                    }
                }
            }
        }
    }
}
