import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Athenaeum 1.0

Page {
    header: NavigationBar {
        activeView: 'game'
    }
    
    property Game game: Game {}
    
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
                        source: game.iconLarge
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
                    text: game.name


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
                    text: game.summary

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
                        visible: !game.installed
                        enabled: !game.processing
                        onClicked: {
                            window.addGame(game.id)
                        }
                        icon.source: 'icons/add.svg'
                        text: qsTr('Add To Library')
                          
                    }
                    Button {
                        id: playButton
                        visible: game.installed
                        enabled: !game.playing
                        highlighted: true
                        onClicked: {
                            window.playGame(game.id)
                        }
                        icon.source: 'icons/play.svg'
                        text: qsTr('Play')

                    }
                    Button {
                        visible: playButton.visible
                        enabled: !game.playing && !game.processing
                        onClicked: {
                            enter(libraryView, game.id)
                        }
                        text: qsTr('View In Library')
                        icon.source: 'icons/library.svg'
                    }
                }
            }
            /* Screenshots */
            Column {
                width: parent.width
                clip: true
                visible: game.screenshots.length
                Rectangle {
                    visible: game.screenshots.length
                    // width: parent.width
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.rightMargin: 40
                    anchors.leftMargin: 40
                    clip: true
                    // height: childrenRect.height > 300 ? 300 : childrenRect.height
                    height: 300 + carousel.height
                    color: "black"
                    BusyIndicator {
                        id: previewLoadingIndicator
                        anchors.centerIn: parent
                        running: largeView.progress != 1.0
                    }
                    Image {
                        anchors.centerIn: parent
                        width: parent.width + 100
                        height: parent.height + 100
                        fillMode: Image.PreserveAspectCrop
                        source:  visible ? (game.screenshots[carousel.currentIndex] ? game.screenshots[carousel.currentIndex].thumbUrl : '') : ''
                        opacity: 0.6
                    }
                    Image {
                        id: largeView
                        anchors.left: parent.left
                        anchors.right: parent.right
                        fillMode: Image.PreserveAspectFit
                        // width: parent.width
                        // anchors.fill:
                        height: 300
                        source: visible ? (game.screenshots[carousel.currentIndex] ? game.screenshots[carousel.currentIndex].sourceUrl : '') : ''
                        MouseArea {
                            anchors.centerIn: parent
                            width: parent.paintedWidth
                            height: parent.paintedHeight
                            onClicked: {
                                fullscreenPreview.open()
                            }
                        }
                    }
                    Popup {
                        id: fullscreenPreview
                        // parent: Overlay.overlay
                        x: Math.round((stackView.width - width) / 2)
                        y: Math.round((stackView.height - height) / 2)
                        parent: stackView
                        width: stackView.width
                        height: stackView.height
                        dim: true
                        modal: true
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                fullscreenPreview.close()
                            }
                        }
                        background: Image {
                            id: bgImage
                            fillMode: Image.PreserveAspectFit
                            anchors.centerIn: parent
                            width: sourceSize.width > parent.width ? parent.width : sourceSize.width
                            height: parent.height
                            source: largeView.source
                        }
                    }
                    Rectangle {
                        width: parent.width
                        height: 50
                        anchors.bottom: parent.bottom
                        opacity: 0.7
                        color: "black"
                        ListView {
                            id: carousel
                            anchors.horizontalCenter: parent.horizontalCenter
                            clip: true
                            width: contentWidth
                            height: parent.height

                            model: game.screenshots
                            orientation: ListView.Horizontal
                            spacing: 5
                            boundsBehavior: Flickable.StopAtBounds
                            // ScrollBar.horizontal: ScrollBar { }
                            delegate: Rectangle {
                                height: parent.height
                                width: 100
                                color: Material.background
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
                                border.color: ListView.isCurrentItem ? Material.accent : thumbMouseArea.containsMouse ? Material.foreground : Material.primary
                            }
                        }
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
                topPadding: 10
                bottomPadding: 40
                Column {
                    id: desc
                    width: parent.width - miscInfo.width
                    height: contentHeight || 20
                    spacing: 10

                    /* Description */
                    Text {
                        visible: game.description
                        id: descHeading
                        width: parent.width
                        color: Material.foreground
                        font.pixelSize: 24
                        text: qsTr('Description')
                        wrapMode: Text.WrapAnywhere
                    }
                    Text {
                        visible: !game.description
                        text: qsTr('No description available.')
                        font.italic: true
                        color: Material.foreground
                    }
                    Text {
                        visible: game.description
                        topPadding: 10
                        bottomPadding: 10
                        width: parent.width
                        color: Material.foreground
                        textFormat: Text.RichText
                        font.pixelSize: 16
                        text: game.description
                        wrapMode: Text.WordWrap
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
                        visible: !game.releases.length
                        text: qsTr('No release information available.')
                        font.italic: true
                        color: Material.foreground
                    }
                    ListView {
                        visible: game.releases.length
                        model: game.releases
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
                        visible: game.developerName
                        color: Material.foreground
                        font.pixelSize: 20
                        text: qsTr('Developer')
                        wrapMode: Text.WrapAnywhere
                    }
                    Text {
                        visible: game.developerName
                        color: Material.foreground
                        font.pixelSize: 16
                        text: game.developerName
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        visible: game.license
                        color: Material.foreground
                        font.pixelSize: 20
                        text: qsTr('License')
                        wrapMode: Text.WrapAnywhere
                    }
                    Text {
                        visible: game.license
                        color: Material.foreground
                        font.pixelSize: 16
                        text: game.license
                        width: parent.width
                        wrapMode: Text.WrapAnywhere
                    }
                            
                    Text {
                        visible: game.urls.length
                        color: Material.foreground
                        font.pixelSize: 20
                        text: qsTr('Links')
                        wrapMode: Text.WrapAnywhere
                    }
                    ListView {
                        visible: game.urls.length
                        model: game.urls
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
