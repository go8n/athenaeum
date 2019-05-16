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
        contentHeight: mainCol.height
        contentWidth: parent.width
        ScrollBar.vertical: ScrollBar { }
        boundsBehavior: Flickable.StopAtBounds
        Column {
            padding: 5
            spacing: 10
            id: leftCol
            width: 200
            height: contentHeight
            anchors.left: parent.left
            Text {
                font.pixelSize: 24
                text: 'Filters'
                color: Material.foreground
            }
        }
        Column {
            padding: 5
//             spacing: 10
            id: mainCol
            anchors.left: leftCol.right
            anchors.right: rightCol.left
            height: searchResults.height + sh.height
            TextField {
                id: sh
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
            ListView {
                model: library.filter
                id: searchResults
                width: parent.width
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
        }
        Column {
            padding: 5
            spacing: 10
            id: rightCol
            width: 200
            height: contentHeight
            anchors.right: parent.right
            Text {
                font.pixelSize: 24
                text: 'Tags'
                color: Material.foreground
            }
        }
    }
}
