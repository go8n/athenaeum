import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Athenaeum 1.0

Page {
    header: NavigationBar {
        activeView: 'game'
    }
    
    property string gameId
    onGameIdChanged: {
        browse.updateCurrentGame(gameId)
        similarGrid.model = browse.findSimilarGames(browse.currentGame.id)   
    }
    
    Flickable {
        anchors.fill: parent
        contentHeight: col.height
        contentWidth: parent.width
        ScrollBar.vertical: ScrollBar {}
        boundsBehavior: Flickable.StopAtBounds
        Column {
            id: col
            width: parent.width
            spacing: 40
            
            /* Header */
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: 40
                anchors.leftMargin: 40

                color: Material.background
                height: childrenRect.height + 40

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: gameTitle.left
                    // anchors.bottom: parent.bottom
                    anchors.topMargin: 40

                    width: 128
                    height: 128
                    id: gameLogo

                    color: Material.primary
                    radius: 10
                    Image {
                        id: img
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        source: browse.currentGame.iconLarge
                    }
                }
                Text {
                    id: gameTitle
                    anchors.top: parent.top
                    anchors.left: gameLogo.right
                    anchors.right: parent.right
                    anchors.topMargin: 40

                    leftPadding: 20

                    color: Material.foreground
                    text: browse.currentGame.name


                    fontSizeMode: Text.VerticalFit
                    font.pixelSize: 48
                    minimumPixelSize: 30;

                    elide: Label.ElideRight

                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WordWrap
                }
                Text {
                    id: gameSummary
                    anchors.top: gameTitle.bottom
                    anchors.left: gameLogo.right
                    anchors.right: parent.right
                    leftPadding: 20

                    color: Material.foreground
                    text: browse.currentGame.summary

                    fontSizeMode: Text.VerticalFit
                    font.pixelSize: 16
                    minimumPixelSize: 10;
                    elide: Label.ElideRight

                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WordWrap
                }
                Row {
                    anchors.top: gameSummary.bottom
                    anchors.left: gameLogo.right
                    anchors.right: parent.right
                    spacing: 10
                    leftPadding: 20
                    topPadding: 10
                    Button {
                        visible: !browse.currentGame.installed
                        enabled: !browse.currentGame.processing
                        onClicked: {
                            window.installGame(browse.currentGame.id)
                        }
                        icon.source: 'icons/download.svg'
                        text: qsTr('Install')
                          
                    }
                    Button {
                        visible: browse.currentGame.installed
                        enabled: !browse.currentGame.playing
                        highlighted: true
                        onClicked: {
                            window.playGame(browse.currentGame.id)
                        }
                        icon.source: 'icons/play.svg'
                        text: qsTr('Play')

                    }
                    Button {
                        visible: browse.currentGame.installed || browse.currentGame.processing
                        onClicked: {
                            enter(libraryView, browse.currentGame.id)
                        }
                        text: qsTr('View In Library')
                        icon.source: 'icons/library.svg'
                    }
                }
            }
            /* Screenshots */
            Column {
                width: parent.width
                visible: browse.currentGame.screenshots.length
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.rightMargin: 40
                    anchors.leftMargin: 40
                    clip: true
                    height: 350
                    color: "black"
                    
                    Image {
                        anchors.left: screenshotsList.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.top: parent.top
                        fillMode: Image.PreserveAspectCrop
                        source:  visible ? (browse.currentGame.screenshots[screenshotsList.currentIndex] ? browse.currentGame.screenshots[screenshotsList.currentIndex].thumbUrl : '') : ''
                        opacity: 0.6
                    }
                    
                    Rectangle {
                        id: screenshotsListBackground
                        width: 100
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        color: "black"
                        opacity: 0.5
                    }
                    
                    ListView {
                            id: screenshotsList
                            width: 100
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            clip: true
                            model: browse.currentGame.screenshots
                            spacing: 5
                            boundsBehavior: Flickable.StopAtBounds
                            ScrollBar.vertical: ScrollBar { }
                            delegate: Rectangle {
                                height: 60
                                width: parent.width
                                color: Material.primary
                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    fillMode: Image.PreserveAspectFit
                                    source: thumbUrl
                                    opacity: 1.0
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        screenshotsList.currentIndex = index
                                    }
                                    hoverEnabled: true
                                    id: thumbMouseArea
                                }
                                border.color: ListView.isCurrentItem ? Material.accent : thumbMouseArea.containsMouse ? Material.foreground : Material.primary
                            }
                        }
                    
                    BusyIndicator {
                        id: previewLoadingIndicator
                        anchors.centerIn: parent
                        running: largeView.progress != 1.0
                    }

                    Image {
                        id: largeView
                        anchors.left: screenshotsList.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.top: parent.top
                        fillMode: Image.PreserveAspectFit
                        source: visible ? (browse.currentGame.screenshots[screenshotsList.currentIndex] ? browse.currentGame.screenshots[screenshotsList.currentIndex].sourceUrl : '') : ''
                        MouseArea {
                            anchors.centerIn: parent
                            width: parent.paintedWidth
                            height: parent.paintedHeight
                            onClicked: {
                                fullscreenPreview.open()
                            }
                        }
                    }
                    FullscreenPreview {
                        id: fullscreenPreview
                        source: largeView.source
                    }
                }
            }
            /* Body */
            Grid {
                anchors.left: parent.left
                anchors.right: parent.right
                columns: 2
                spacing: 20
                /* Releases */
                leftPadding: 40
                rightPadding: 40
                bottomPadding: 40
                topPadding: 10
                
                Column {
                    id: desc
                    width: parent.width - miscInfo.width
                    spacing: 10

                    /* Description */
                    Text {
                        visible: browse.currentGame.description
                        id: descHeading
                        width: parent.width
                        color: Material.foreground
                        font.pixelSize: 24
                        text: qsTr('Description')
                        wrapMode: Text.WrapAnywhere
                    }
                    Text {
                        visible: !browse.currentGame.description
                        text: qsTr('No description available.')
                        font.italic: true
                        color: Material.foreground
                    }
                    Text {
                        visible: browse.currentGame.description
                        topPadding: 10
                        bottomPadding: 10
                        width: parent.width
                        color: Material.foreground
                        textFormat: Text.RichText
                        font.pixelSize: 16
                        text: browse.currentGame.description
                        wrapMode: Text.WordWrap
                    }
                    /* Similar */
                    Text {
                        id: similarHeading
                        visible: similarGrid.model ? similarGrid.model.length : false
                        width: parent.width
                        color: Material.foreground
                        font.pixelSize: 24
                        text: qsTr('Similar Games')
                        wrapMode: Text.WrapAnywhere
                    }
                    Flow {
                        id: similarFlow
                        width: parent.width
                        spacing: 10
                        Repeater {
                            id: similarGrid
                            delegate: ToolButton {
                                icon.source: similarGrid.model[index].iconSmall
                                icon.color: '#00000000'
                                text: similarGrid.model[index].name
                                font.capitalization: Font.MixedCase
                                font.pixelSize: 20
                                onClicked: {
                                    enter(gameView, similarGrid.model[index].id)
                                }
                            }
                            
                            
//                             Rectangle {
//                                 width: 220
//                                 height: 70
//                                 color: Material.color(Material.Grey, theme == Material.Dark ? Material.Shade900 : Material.Shade100)
//                                 MouseArea {
//                                     anchors.fill: parent
//                                     onClicked: {
//                                         enter(gameView, similarGrid.model[index].id)
//                                     }
//                                 }
//                                 Row {
//                                     anchors.fill: parent
//                                     spacing: 10
//                                     padding: 10
//                                     Image {
//                                         height: 50
//                                         width: 50
//                                         fillMode: Image.PreserveAspectFit
//                                         source: similarGrid.model[index].iconLarge
//                                     }
//                                     Column {
//                                         Text {
//                                             color: Material.foreground
//                                             text: similarGrid.model[index].name
//                                             font.pixelSize: 20
//                                         }
//                                     }
//                                 }
//                             }
                        }
                    }
                    /* Releases */
                    Text {
                        id: releaseHeading
                        width: parent.width
                        color: Material.foreground
                        font.pixelSize: 24
                        text: qsTr('Releases')
                        wrapMode: Text.WrapAnywhere
                    }
                    Text {
                        visible: !browse.currentGame.releases.length
                        text: qsTr('No release information available.')
                        font.italic: true
                        color: Material.foreground
                    }
                    ListView {
                        visible: browse.currentGame.releases.length
                        model: browse.currentGame.releases
                        width: parent.width
                        height: contentHeight
                        spacing: 10
                        delegate: Column {
                            width: parent.width
                            function formatTimestamp(ts) {
                                var t = new Date( 0 );
                                t.setSeconds(ts);
                                return t.toLocaleDateString();
                            }
                            Flow {
                                width: parent.width
                                spacing: 10
                                Text {
                                    color: Material.foreground
                                    font.pixelSize: 20
                                    text: qsTr('Version %1').arg(version)
                                    wrapMode: Text.WrapAnywhere
                                }
                                Text {
                                    color: Material.foreground
                                    font.pixelSize: 20
                                    text: formatTimestamp(timestamp)
                                    wrapMode: Text.WrapAnywhere
                                }
                            }
                            Text {
                                topPadding: 10
                                bottomPadding: 10
                                width: parent.width
                                color: Material.foreground
                                font.pixelSize: 16
                                font.italic: description ? false : true
                                text: description || qsTr('No release description available.')
                                wrapMode: Text.WrapAnywhere
                            }
                        }
                    }
                }
                /* Links and Categories */
                Column {
                    id: miscInfo
                    width: 250
                    spacing: 10
                    Text {
                        visible: browse.currentGame.antiFeatures.length
                        color: Material.color(Material.Red)
                        font.pixelSize: 20
                        text: qsTr('Anti-Features')
                        wrapMode: Text.WrapAnywhere
                    }
                    ListView {
                        visible: browse.currentGame.antiFeatures.length
                        model: browse.currentGame.antiFeatures
                        height: contentHeight
                        width: contentWidth
                        delegate: Text {
                            function getTitle(type) {
                                switch(type) {
                                    case 'assets':
                                        return qsTr('This game requires NonFree assets.');
                                }
                            }
                            color: Material.color(Material.Red)
                            font.pixelSize: 16
                            wrapMode: Text.WordWrap
                            text: getTitle(browse.currentGame.antiFeatures[index])
                        }
                    }
                    Text {
                        visible: browse.currentGame.developerName
                        color: Material.foreground
                        font.pixelSize: 20
                        text: qsTr('Developer')
                        wrapMode: Text.WrapAnywhere
                    }
                    Text {
                        visible: browse.currentGame.developerName
                        color: Material.foreground
                        font.pixelSize: 16
                        text: browse.currentGame.developerName
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        visible: browse.currentGame.license
                        color: Material.foreground
                        font.pixelSize: 20
                        text: qsTr('License')
                        wrapMode: Text.WrapAnywhere
                    }
                    Text {
                        visible: browse.currentGame.license
                        color: Material.foreground
                        font.pixelSize: 16
                        text: browse.currentGame.license
                        width: parent.width
                        wrapMode: Text.WrapAnywhere
                    }
                            
                    Text {
                        visible: browse.currentGame.urls.length
                        color: Material.foreground
                        font.pixelSize: 20
                        text: qsTr('Links')
                        wrapMode: Text.WrapAnywhere
                    }
                    ListView {
                        visible: browse.currentGame.urls.length
                        model: browse.currentGame.urls
                        id: linksList
                        height: contentHeight
                        width: contentWidth
                        delegate: Button {
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    Qt.openUrlExternally(url)
                                }
                            }
                            icon.source: 'icons/' + urlIcon
                            topPadding: 0
                            leftPadding: 0
                            background: Rectangle {
                                anchors.fill: parent
                                color: tr
                            }

                            icon.color: type === 'donation' ? '#00000000' : icon.color
                            font.capitalization: Font.MixedCase
                            function getTitle(type) {
                                switch(type) {
                                    case 'homepage':
                                        return qsTr('Homepage');
                                    case 'bugtracker':
                                        return qsTr('Bug Tracker');
                                    case 'help':
                                        return qsTr('Help');
                                    case 'faq':
                                        return qsTr('FAQ');
                                    case 'donation':
                                        return qsTr('Donate');
                                    case 'translate':
                                        return qsTr('Translation');
                                    case 'unknown':
                                        return qsTr('Unknown');
                                    case 'manifest':
                                        return qsTr('Manifest');
                                }
                            }
                            text: getTitle(type)
                        }
                    }
                }
            }
        }
    }
}
