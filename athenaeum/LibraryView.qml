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
        Text {
            visible: !library.currentGame.id.length
            text: qsTr('Nothing seems to be here.')
            anchors.centerIn: parent
            color: Material.primary
            font.italic: true
            font.pixelSize: 14
        }
        Flickable {
            visible: library.currentGame.id.length
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
                        spacing: 10
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
                            onClicked: {
                                uninstallPopup.open()
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
                            visible: library.currentGame.processing
                            onClicked: {
                                window.cancelGame(library.currentGame.id)
                            }
                            icon.source: 'icons/close.svg'
                            text: qsTr('Cancel')
                        }
                        Button {
                            visible: library.currentGame.error
                            onClicked: {
                                resolveErrorsPopup.open()
                            }
                            Popup {
                                id: resolveErrorsPopup
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
                                        text: qsTr('Resolve Error')
                                    }
                                    Column {
                                        spacing: 10
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        Button {
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            onClicked: {
                                                window.clearErrors(library.currentGame.id)
                                                resolveErrorsPopup.close()
                                            }
                                            text: qsTr('Clear error')
                                        }
                                        Button {
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            text: qsTr('Mark as installed')
                                            onClicked: {
                                                window.markInstalled(library.currentGame.id)
                                                resolveErrorsPopup.close()
                                            }
                                        }
                                        Button {
                                            text: qsTr('Mark as uninstalled')
                                            onClicked: {
                                                window.markUninstalled(library.currentGame.id)
                                                resolveErrorsPopup.close()
                                            }
                                        }
                                        Button {
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            text: qsTr('Cancel')
                                            onClicked: {
                                                resolveErrorsPopup.close()
                                            }
                                        }
                                    }
                                }
                            }
                            Component.onCompleted: {
                                background.color = 'red'
                            }
                            icon.source: 'icons/exclamation.svg'
                        }
                        Button {
                            onClicked: {
                                enter(gameView, library.currentGame.id)
                            }
                            icon.source: 'icons/browse.svg'
                            text: qsTr('View In Store')
                        }
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
                        spacing: 10
                        Text {
                            id: releaseHeading
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
//                         Text {
//                             color: Material.foreground
//                             font.pixelSize: 20
//                             text: qsTr('Hours Played')
//                             wrapMode: Text.WrapAnywhere
//                         }
//                         Text {
//                             color: Material.foreground
//                             font.pixelSize: 16
//                             text: qsTr('14 Hours')
//                             wrapMode: Text.WrapAnywhere
//                         }
                        
                        Text {
                            visible: library.currentGame.developerName
                            color: Material.foreground
                            font.pixelSize: 20
                            text: qsTr('Developer')
                            wrapMode: Text.WrapAnywhere
                        }
                        Text {
                            visible: library.currentGame.developerName
                            color: Material.foreground
                            font.pixelSize: 16
                            text: library.currentGame.developerName
                            wrapMode: Text.WordWrap
                        }
                        
                        Text {
                            visible: library.currentGame.license
                            color: Material.foreground
                            font.pixelSize: 20
                            text: qsTr('License')
                            wrapMode: Text.WrapAnywhere
                        }
                        Text {
                            visible: library.currentGame.license
                            color: Material.foreground
                            font.pixelSize: 16
                            text: library.currentGame.license
                            wrapMode: Text.WrapAnywhere
                        }
                            
                        Text {
                            visible: library.currentGame.urls.length
                            color: Material.foreground
                            font.pixelSize: 20
                            text: qsTr('Links')
                            wrapMode: Text.WrapAnywhere
                        }
                        ListView {
                            visible: library.currentGame.urls.length
                            model: library.currentGame.urls
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
                                            icon.color = '#00000000';
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
}
