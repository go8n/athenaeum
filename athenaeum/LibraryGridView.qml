import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.3
import Athenaeum 1.0

Item {
    id: libraryGridView
    anchors.fill: parent

    Rectangle {
        id: filterControls
        anchors.horizontalCenter: parent.horizontalCenter
        width: gamesGrid.width
        height: childrenRect.height
        color: tr
        /* Search Bar */
        TextField {
            id: searchField
            anchors.left: parent.left
            width: parent.width - filterCombo.width - 20
            color: Material.foreground
            placeholderText: qsTr('Search %L1 Games...').arg(library.filter.length)
            onTextChanged: {
                library.searchValue = text
            }
            Keys.onEscapePressed: {
                text = ''
            }
        }
        /* Game List */
        ComboBox {
            id: filterCombo
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.leftMargin: 10
            width: 200
            currentIndex: getFilterIndex(library.filterValue)
            
            property string filterIndex: library.filterValue
            onFilterIndexChanged: {
                currentIndex = getFilterIndex(library.filterValue)
            }
            onModelChanged: {
                currentIndex = getFilterIndex(library.filterValue)
            }
            onActivated: {
                library.filterValue = getFilterKey(index)
                searchField.text = ''
            }
            function getFilterIndex(key) {
                switch(key) {
                    case 'installed':
                        return 0;
                    case 'recent':
                        return 1;
                    case 'has_updates':
                        return 2;
                    case 'processing':
                        return 3;
                }
            }
            function getFilterKey(index) {
                switch(index) {
                    case 0:
                        return 'installed';
                    case 1:
                        return 'recent';
                    case 2:
                        return 'has_updates';
                    case 3:
                        return 'processing';
                }
            }
        
            model: [
                qsTr('Installed (%L1)').arg(library.installedCount),
                qsTr('Recent (%L1)').arg(library.recentCount),
                qsTr('Has Updates (%L1)').arg(library.hasUpdatesCount),
                qsTr('Processing (%L1)').arg(library.processingCount)
            ]
            validator: IntValidator {
                top: 4
                bottom: 0
            }
        }
    }

    Flickable {
        anchors.top: filterControls.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        contentHeight: gamesGrid.height
        contentWidth: parent.width
        ScrollBar.vertical: ScrollBar { }
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        GridView {
            id: gamesGrid
            model: library.filter
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.floor(parent.width / cellWidth) * cellWidth
            height: contentHeight
            anchors.rightMargin: 0
            property int padding: 10

            cellWidth: 460 + padding
            cellHeight: 215 + padding
            delegate: Rectangle {
                color: Material.color(Material.Grey, theme == Material.Dark ? Material.Shade900 : Material.Shade100)
                width: 460
                height: 215
                Image {
                    id: gameImage
                    visible: screenshots.length
                    source: screenshots[0] ? screenshots[0].thumbUrl : ''
                    width: 460
                    height: 215
                }
                 FastBlur {
                    visible: gameImage.visible
                    anchors.fill: gameImage
                    source: gameImage
                    radius: 20
                }
                Text {
                    id: gameName
                    anchors.centerIn: parent
                    text: name
                    color: 'white'
                    font.pixelSize: 34
                    font.bold: true
                }
                DropShadow {
                    anchors.fill: gameName
                    horizontalOffset: 3
                    verticalOffset: 3
                    radius: 6.0
                    samples: 16
                    color: "#80000000"
                    source: gameName
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    Row {
                        id: buttonRow
                        spacing: 10
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: parent.containsMouse
                        Button {
                            visible: installed
                            enabled: !playing
                            onClicked: {
                                window.playGame(id)
                            }
                            highlighted: true
                            icon.source: 'icons/play.svg'
                            text: qsTr('Play')
                        }
                        Button {
                            onClicked: {
                                enter(gameView, id)
                            }
                            icon.source: 'icons/browse.svg'
                            text: qsTr('View In Store')
                        }
                    }
                }
            }
        }
    }
        // Flow {
        //     id: gamesFlow
        //     spacing: 10
        //     anchors.centerIn: parent
        //     // anchors.horizontalCenter: parent.horizontalCenter
        //     width: parent.width - 40

        //     Repeater {
        //         model: library.filter
        //         delegate: Rectangle {
        //             color: Material.color(Material.Grey, theme == Material.Dark ? Material.Shade900 : Material.Shade100)
        //             width: 460
        //             height: 215
        //             MouseArea {
        //                 anchors.fill: parent
        //                 onClicked: {
                            
        //                 }
        //             }
        //             Text {
        //                 anchors.fill: parent
        //                 text: name
        //             }
        //         }
        //     }
        // }
    
}