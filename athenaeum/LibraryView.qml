import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Athenaeum 1.0

Page {
    header: NavigationBar {
        activeView: 'library'
    }
    /* Search Bar */
    TextField {
        id: searchField
        leftPadding: 10
        rightPadding: 10
        anchors.top: parent.top
        anchors.bottom: filterCombo.top
        width: listView.width
        // background: Rectangle {
        //     anchors.fill: parent
        //     color: Material.background
        // }
        color: Material.foreground
        placeholderText: qsTr('Search %L1 Games...').arg(library.filter.length)
        onTextChanged: {
            library.searchValue = text
            window.search()
        }
        Keys.onEscapePressed: {
            text = ''
        }
    }
    /* Game List */
    ComboBox {
        id: filterCombo
        width: listView.width
        anchors.top: searchField.bottom
        onModelChanged: {
            currentIndex = getFilterIndex(library.filterValue)
        }
        currentIndex: getFilterIndex(library.filterValue)
        function getFilterIndex(key) {
            switch(key) {
                case 'installed':
                    return 1;
                case 'recent':
                    return 2;
                case 'new':
                    return 3;
                case 'has_updates':
                    return 4;
                case 'processing':
                    return 5;
                default:
                    return 0;
            }
        }
        model: [
            qsTr('All Games (%L1)').arg(library.games.length),
            qsTr('Installed (%L1)').arg(library.installedCount),
            qsTr('Recent (%L1)').arg(library.recentCount),
            qsTr('New (%L1)').arg(library.newCount),
            qsTr('Has Updates (%L1)').arg(library.hasUpdatesCount),
            qsTr('Processing (%L1)').arg(library.processingCount)
        ]
        validator: IntValidator {
            top: 5
            bottom: 0
        }
        onActivated: {
            library.filterValue = getFilterKey(index)
            window.filter()
            searchField.text = ''
            function getFilterKey(index) {
                switch(index) {
                    case 1:
                        return 'installed';
                    case 2:
                        return 'recent';
                    case 3:
                        return 'new';
                    case 4:
                        return 'has_updates';
                    case 5:
                        return 'processing';
                    default:
                        return 'all';
                }
            }
        }
    }
    ListView {
        id: listView
        anchors.top: filterCombo.bottom
        anchors.bottom: parent.bottom
        model: library.filter
        width: 200
        ScrollBar.vertical: ScrollBar { }
        boundsBehavior: Flickable.StopAtBounds
        keyNavigationEnabled: true
        // focus: true
        clip:true

        onModelChanged: {
            currentIndex = library.getIndexForCurrentGame()
        }

        delegate: Component {
            id: delegateComponent
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 35
                id: rect
                border.color: ListView.isCurrentItem || itemMouseArea.containsMouse ? Material.accent : tr
                border.width: 1
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        listView.currentIndex = index
                        window.indexUpdated(index)
                        listView.forceActiveFocus()
                    }
                    id: itemMouseArea
                    hoverEnabled: true
                }
                // color: ListView.isCurrentItem ? Material.accent : itemMouseArea.containsMouse ? Material.accent : Material.background
                color: tr
                Rectangle {
                    id: gameIcon
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: 1
                    width: parent.height
                    height: parent.height
                    color: tr
                    Image {
                        anchors.fill: parent
                        anchors.margins: 5
                        fillMode: Image.PreserveAspectFit
                        source: iconSmall
                    }
                }
                Text {
                    // color: parent.ListView.isCurrentItem ? Material.background : itemMouseArea.containsMouse ? Material.background : Material.foreground
                    color: Material.foreground
                    clip: true
                    width: parent.width
                    anchors.left: gameIcon.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    text: name
                    anchors.topMargin: 5
                    anchors.rightMargin: 5
                    anchors.bottomMargin: 5
                    verticalAlignment: Text.AlignVCenter
                }
                BusyIndicator {
                    visible: true
                    height: parent.height
                    width: parent.height
                    id: gameProcessing
                    anchors.right: parent.right
                    running: processing
                }
                Rectangle {
                    visible: false
                    height: parent.height
                    width: parent.height
                    anchors.right: parent.right
                    color: tr
                    Rectangle {
                        width: childrenRect.width
                        height: childrenRect.height
                        anchors.centerIn: parent
                        //color: sel
                        radius: 3
                        Text {
                            text: qsTr('New')
                            font.pixelSize: 12
                            padding: 3
                            //color: tc
                        }
                    }
                }
            }
        }
    }
    /* Game Detail Pane */
    Rectangle {
        anchors.left: listView.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: Material.background
        Flickable {
            anchors.fill: parent
            contentHeight: col.height
            contentWidth: parent.width
            ScrollBar.vertical: ScrollBar { }
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
                    height: childrenRect.height

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
                            source: library.currentGame.iconLarge
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
                        text: library.currentGame.name


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
                        text: library.currentGame.summary

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
                        spacing: 5
                        leftPadding: 20
                        topPadding: 10
                        Button {
                            visible: !library.currentGame.installed
                            enabled: !library.currentGame.processing
                            onClicked: {
                                window.installGame(library.currentGame.id)
                            }
                            icon.source: 'icons/download.svg'
                            text: qsTr('Install')
                        }
                        Button {
                            id: playButton
                            visible:  library.currentGame.installed
                            enabled: !library.currentGame.playing
                            onClicked: {
                                window.playGame(library.currentGame.id)
                            }
                            highlighted: true
//                             background.color= 'lightgreen'
                            icon.source: 'icons/play.svg'
                            text: qsTr('Play')

                        }
                        Button {
                            visible: library.currentGame.hasUpdate && library.currentGame.installed
                            enabled: !library.currentGame.playing && !library.currentGame.processing
                            onClicked: {
                                window.updateGame(library.currentGame.id)
                            }
                            text: qsTr('Update')
                        }
                        Button {
                            text: qsTr('Uninstall')
                            icon.source: 'icons/trash.svg'
                            visible: library.currentGame.installed
                            enabled: !library.currentGame.processing
                            MouseArea {
                                id: uninstallMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    uninstallPopup.open()
                                }
                            }
                            Popup {
                                id: uninstallPopup
                                parent: stackView
                                x: Math.round((parent.width - width) / 2)
                                y: Math.round((parent.height - height) / 2)
                                modal: true
                                dim: true
                                focus: true
                                contentItem: Column {
                                    spacing: 20
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        color: Material.foreground
                                        font.pixelSize: 20
                                        text: qsTr('Are you sure?')
                                    }
                                    Row {
                                        spacing: 20
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        Button {
                                            onClicked: {
                                                window.uninstallGame(library.currentGame.id)
                                                uninstallPopup.close()
                                            }
                                            text: qsTr('Yes')
                                        }
                                        Button {
                                            text: qsTr('Cancel')
                                            onClicked: {
                                                uninstallPopup.close()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        Button {
                            visible:  playButton.visible
                            onClicked: {
                                enter(gameView, library.currentGame.id)
                            }
                            icon.source: 'icons/browse.svg'
                            text: qsTr('View In Store')
                        }
//                         Button {
//                             visible:  playButton.visible
//                             onClicked: {
//                                 enter(gameView, library.currentGame.id)
//                             }
//                             icon.source: 'icons/link.svg'
//                             text: qsTr('Links')
//                         }
                    }
                }


                /* Logs */
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.rightMargin: 40
                    anchors.leftMargin: 40
                    color: "black"
                    height: 160
                    visible: library.currentGame.error || library.currentGame.processing || (settings.alwaysShowLogs && library.currentGame.installed)

                    Flickable {
                        id: testFlick
                        anchors.fill: parent

                        // ScrollBar.vertical: ScrollBar {
                        //     policy: ScrollBar.AlwaysOn }
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        TextArea {
                            id: ta
                            onContentHeightChanged: {
                                testFlick.contentY = (contentHeight <= 150 ? 0 : contentHeight - 150)
                            }
                            color: "white"
                            readOnly: true
                            text: library.currentGame.log
                            background: Rectangle {
                                anchors.fill: parent
                                color: "black"
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
                    Column {
                        width: parent.width - 250
                        height: contentHeight || 20
                        spacing: 10
                    Text {
                        id: releaseHeading
//                         visible: library.currentGame.releases.length

//                         width: parent.width
                        color: Material.foreground
                        font.pixelSize: 24
                        text: qsTr('Releases')
                        wrapMode: Text.WrapAnywhere
                    }
                    Text {
                        visible: !library.currentGame.releases.length
                        text: qsTr('No release information available.')
                        font.italic: true
                        color: Material.foreground
                    }
                    ListView {
                        visible: library.currentGame.releases.length
                        model: library.currentGame.releases
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
                    
                    Column {
                        width: 250
                        spacing: 10
                    Text {
                        color: Material.foreground
                        font.pixelSize: 24
                        text: qsTr('Hours Played')
                        wrapMode: Text.WrapAnywhere
                    }
                    Text {
                        color: Material.foreground
                        font.pixelSize: 16
                        text: qsTr('14 Hours')
                        wrapMode: Text.WrapAnywhere
                    }
                    Text {
                        color: Material.foreground
                        font.pixelSize: 24
                        text: qsTr('Developer')
                        wrapMode: Text.WrapAnywhere
                    }
                    Text {
                        color: Material.foreground
                        font.pixelSize: 16
                        text: library.currentGame.developerName
                        wrapMode: Text.WrapAnywhere
                    }
                    Text {
                        color: Material.foreground
                        font.pixelSize: 24
                        text: qsTr('License')
                        wrapMode: Text.WrapAnywhere
                    }
                    Text {
                        color: Material.foreground
                        font.pixelSize: 16
                        text: library.currentGame.license
                        wrapMode: Text.WrapAnywhere
                    }
                        
                    Text {
                        color: Material.foreground
                        font.pixelSize: 24
                        text: qsTr('Links')
                        wrapMode: Text.WrapAnywhere
                    }
                    ListView {
                        model: library.currentGame.urls
    //                     anchors.horizontalCenter: parent.horizontalCenter
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
                            Component.onCompleted: {
                                if (type === 'donation') {
                                    icon.color = '#00000000'
                                }
                                contentItem.font.capitalization = Font.MixedCase
                            }
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
//                             background: Rectangle {
//                                 anchors.fill: parent
//                                 color: tr
//                             }
                        }
                    }
                    }
                }

//                     Grid {
//                         id: lists
//                         bottomPadding: 40
//                         anchors.left: parent.left
//                         anchors.right: parent.right
//                         anchors.rightMargin: 40
//                         anchors.leftMargin: 40
//                         anchors.horizontalCenter: parent.horizontalCenter
//                         columns: 4
//                         spacing: 40
//                         Column {
//                             Text {
//                                 visible: library.currentGame.developerName
//                                 color: Material.foreground
//                                 font.pixelSize: 16
//                                 text: qsTr('Developer')
//                             }
//                             Text {
//                                 visible: library.currentGame.developerName
//                                 color: Material.foreground
//                                 font.pixelSize: 12
//                                 text: library.currentGame.developerName
//                             }
//                         }
//                         Column {
//                             Text {
//                                 visible: library.currentGame.license
//                                 color: Material.foreground
//                                 font.pixelSize: 16
//                                 text: qsTr('License')
//                             }
//                             Text {
//                                 visible: library.currentGame.license
//                                 color: Material.foreground
//                                 font.pixelSize: 12
//                                 text: library.currentGame.license
//                             }
//                         }
//                         Column {
//                             Text {
//                                 color: Material.foreground
//                                 font.pixelSize: 16
//                                 text: qsTr('Categories')
//                             }
//                             ListView {
//                                 model: library.currentGame.categories
//                                 height: contentHeight
//                                 width: parent.width
//                                 id: categoriesList
//                                 delegate: 
//                                     Text {
//                                         color: Material.foreground
//                                         font.pixelSize: 12
//                                         text: library.currentGame.categories[index]
//                                     }
//                                 
//                             }
//                         }
//                     }
                
            }
        }
    }
    Connections {
        target: library
        function getMessage(action) {
            switch(action) {
                case 'install':
                    return qsTr('Installed successfully.');
                case 'uninstall':
                    return qsTr('Uninstalled successfully.');
                case 'update':
                    return qsTr('Updated successfully.');
                case 'error':
                    return qsTr('An error occurred.');
            }
        }
        onDisplayNotification: {
            if (settings.notificationsEnabled) {
                window.notify(library.games[index].name, getMessage(action), library.games[index].iconLarge)
            }
        }
    }
}
