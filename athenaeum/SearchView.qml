import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Athenaeum 1.0

Page {
    header: NavigationBar {
        activeView: 'search'
    }
    
    property string search
    
    Flickable {
        anchors.fill: parent
        contentHeight: rec.height
        contentWidth: contentWidth
        ScrollBar.vertical: ScrollBar { }
        boundsBehavior: Flickable.StopAtBounds
        Rectangle {
            id: rec
            width: parent.width - 400
            height: childrenRect.height
            anchors.horizontalCenter: parent.horizontalCenter
            color: tr
            TextField {
                anchors.top: parent.top
                id: searchField
                width: parent.width
                text: search
                font.pixelSize: 24
                placeholderText: qsTr('Search')
                
                onTextChanged: {
                    library.searchValue = text
                    window.search()
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
//                 padding: 10
                spacing: 10
                Button {
                    text: 'Action'
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
                } 
                Button {
                    text: 'Shooter'
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
                }
                Button {
                    text: 'Strategy'
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
                }
                
                
                
                
            }
            ListView {
                anchors.top: activeTags.bottom
                model: library.filter
                id: searchResults
                anchors.left: parent.left
                anchors.right: filtersCol.left
                height: contentHeight
                boundsBehavior: Flickable.StopAtBounds
                delegate: Component {
                    Rectangle {
                        width: parent.width
                        height: 70
                        color: Material.color(Material.Grey, theme == Material.Dark ? Material.Shade900 : Material.Shade100)
                        border.color: Material.background
                        border.width: 5
                        MouseArea {
                            anchors.fill: parent
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
            
            Column {
                anchors.top: searchField.bottom
                id: filtersCol
                anchors.right: parent.right
                width: 200
                padding: 10
                Text {
                    color: Material.foreground
                    font.pixelSize: 24
                    text: 'Tags'
                }
                CheckBox {
                    checked: true
                    text: qsTr("Action")
                }
                CheckBox {
                    checked: true
                    text: qsTr("Shooter")
                }
                CheckBox {
                    checked: true
                    text: qsTr("Roleplaying")
                }
                CheckBox {
                    checked: true
                    text: qsTr("Strategy")
                }
                Text {
                    color: Material.foreground
                    font.pixelSize: 24
                    text: 'Platform'
                }
                CheckBox {
                    checked: true
                    text: qsTr("GNU")
                }
                Text {
                    color: Material.foreground
                    font.pixelSize: 24
                    text: 'Repository'
                }
                CheckBox {
                    checked: true
                    text: qsTr("Flathub")
                }
            }
        }
    }
}
