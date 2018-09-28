import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Athenaeum 1.0

Page {
    id: libraryView

    property color bg : '#202228'
    property color sel: '#4d84c7'
    property color hl: '#314661'
    property color fg: '#2d3139'
    property color tc: '#caccd1'
    property color ac: '#808186'
    property color dg: '#e0e0e0'
    property color bl: '#0b0b0b'
    property color tr: 'transparent'

    background: Rectangle {
        anchors.fill: parent
        color: bg
    }
    header: ToolBar {
        id: toolBar
        RowLayout {
            spacing: 0
            anchors.fill: parent
            Rectangle {
                width: listView.width
                Layout.fillHeight: true
                TextField {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: dropDown. left
                    anchors.bottom: parent.bottom
                    // anchors.fill: parent
                    background: Rectangle {
                        anchors.fill: parent
                        color: bg
                    }
                    color: tc
                    id: searchField
                    placeholderText: qsTr('Search %L1 Games...').arg(library.games.length)

                    onTextChanged: {
                        window.search(text)
                    }
                    onAccepted: {
                        window.indexUpdated(0)
                    }
                    Keys.onEscapePressed: {
                        text = ''
                    }
                }
                ToolButton {
                    id: dropDown
                    anchors.right: parent.right
                    contentItem: Text {
                            text: qsTr("⌄")
                            color: tc
                            horizontalAlignment: Text.AlignHCenter
                    }
                    background: Rectangle {
                        anchors.fill: parent
                        color: hl
                        implicitHeight: 40
                    }
                    onClicked: sortMenu.open()
                    Menu {
                        id: sortMenu
                        MenuItem {
                            text: qsTr('All Games')
                            onTriggered: {
                                window.filter('all')
                                searchField.text = ''
                            }
                        }
                        MenuItem {
                            text: qsTr('Installed')
                            onTriggered: {
                                window.filter('installed')
                                searchField.text = ''
                            }
                        }
                        MenuItem {
                            text: qsTr('Recent')
                            onTriggered: {
                                window.filter('recent')
                                searchField.text = ''
                            }
                        }
                        MenuItem {
                            text: qsTr('New')
                            onTriggered: {
                                window.filter('new')
                                searchField.text = ''
                            }
                        }
                        MenuItem {
                            text: qsTr('Has Updates')
                            onTriggered: {
                                window.filter('update')
                                searchField.text = ''
                            }
                        }
                        MenuSeparator { }
                        MenuItem {
                            text: qsTr('Sort A-Z')
                            onTriggered: window.sort('az')
                        }
                        MenuItem {
                            text: qsTr('Sort Z-A')
                            onTriggered: window.sort('za')
                        }
                    }
                }

            }
            Label {
                background: Rectangle {
                    anchors.fill: parent
                    color: fg
                }
                color: tc
                text: qsTr('Library')
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            ToolButton {
                contentItem: Text {
                        text: qsTr("⋮")
                        color: tc
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    anchors.fill: parent
                    color: fg
                    implicitWidth: 40
                    implicitHeight: 40
                }
                Layout.fillHeight: true
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
                        onTriggered: Qt.quit()
                    }
                }
            }
        }
    }
    /* Game List */
    ListView {
        id: listView
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        model: library.filter
        width: 200
        ScrollBar.vertical: ScrollBar { }
        boundsBehavior: Flickable.StopAtBounds
        keyNavigationEnabled: true
        focus: true
        onCurrentItemChanged:{
            window.indexUpdated(listView.currentIndex)
        }

        header: Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: 25
            color: fg
            Text {
                function formatFilterName(filter) {
                    switch(filter) {
                        case 'installed':
                            return qsTr('Installed');
                        case 'recent':
                            return qsTr('Recent');
                        case 'new':
                            return qsTr('New');
                        case 'update':
                            return qsTr('Has Update');
                        default:
                            return qsTr('All Games');
                    }
                }
                anchors.centerIn: parent
                color: tc
                text: formatFilterName(library.filterValue)
            }
        }

        delegate: Component {
            id: delegateComponent
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 35
                id: rect
                border.color: bg
                border.width: 1
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        listView.currentIndex = index
                        listView.forceActiveFocus()
                    }
                    id: itemMouseArea
                    hoverEnabled: true
                }
                color: ListView.isCurrentItem ? sel : itemMouseArea.containsMouse ? hl : fg
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
                    color: tc
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
                    visible: false
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
                        color: sel
                        radius: 3
                        Text {
                            text: qsTr('New')
                            font.pixelSize: 12
                            padding: 3
                            color: tc
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
        color: bg
        ScrollView {
            anchors.fill: parent
            contentHeight: col.height
            contentWidth: parent.width
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

                    color: bg
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

                        color: fg
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

                        color: tc
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

                        color: tc
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
                            text: qsTr('Install')
                            visible: !library.currentGame.installed
                            enabled: !library.currentGame.processing
                            onClicked: {
                                window.installGame(library.currentGame.id)
                            }
                            Component.onCompleted: {
                                try {
                                    icon.source = Qt.resolvedUrl('icons/download.svg');
                                    icon.height = 16;
                                    icon.width = 16;
                                } catch (e) {
                                    // ignore
                                }
                            }
                        }
                        Button {
                            text: qsTr('Play')
                            visible:  library.currentGame.installed
                            enabled: !library.currentGame.playing
                            onClicked: {
                                window.playGame(library.currentGame.id)
                            }
                            Component.onCompleted: {
                                try {
                                    icon.source = Qt.resolvedUrl('icons/caret-right.svg');
                                    icon.height = 16;
                                    icon.width = 16;
                                } catch (e) {
                                    // ignore
                                }
                            }
                            background: Rectangle {
                                implicitWidth: 100
                                implicitHeight: 40
                                color: library.currentGame.playing ? 'lightgreen' : 'lightblue'
                            }
                        }
                        Button {
                            text: qsTr('Update');
                            visible: library.currentGame.hasUpdate && library.currentGame.installed
                            enabled: !library.currentGame.playing && !library.currentGame.processing
                            Component.onCompleted: {
                                try {
                                    icon.source = Qt.resolvedUrl('icons/refresh.svg');
                                    icon.height = 16;
                                    icon.width = 16;
                                } catch (e) {
                                    // ignore
                                }
                            }
                            onClicked: {
                                window.updateGame(library.currentGame.id)
                            }
                            background: Rectangle {
                                id: bgRect
                                implicitWidth: 100
                                implicitHeight: 40
                                color: dg
                            }
                        }
                        Button {
                            text: qsTr('Uninstall')
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
                                // parent: Overlay.overlay
                                parent: stackView
                                background: Rectangle {
                                    anchors.fill: parent
                                    color: fg
                                }
                                x: Math.round((parent.width - width) / 2)
                                y: Math.round((parent.height - height) / 2)
                                modal: true
                                dim: true
                                focus: true
                                contentItem: Column {
                                    id: uninstallDialog
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        color: tc
                                        font.pixelSize: 20
                                        text: qsTr('Are you sure?')
                                    }
                                    Row {
                                        topPadding: 20
                                        spacing: 20
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        Button {
                                            text: qsTr('Yes')
                                            onClicked: {
                                                window.uninstallGame(library.currentGame.id)
                                                uninstallPopup.close()
                                            }
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
                            background: Rectangle {
                                implicitWidth: 100
                                implicitHeight: 40
                                color: uninstallMouseArea.containsMouse ? 'lightcoral' : dg
                            }
                        }
                    }
                }
                /* Logs */
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.rightMargin: 40
                    anchors.leftMargin: 40
                    color: bl
                    height: 150
                    visible: library.currentGame.processing

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
                            color: tc
                            readOnly: true
                            text: library.currentGame.log
                        }
                    }
                }
                /* Screenshots */
                Column {
                    width: parent.width
                    clip: true
                    Rectangle {
                        visible: library.currentGame.screenshots.length
                        // width: parent.width
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: 40
                        anchors.leftMargin: 40
                        clip: true
                        // height: childrenRect.height > 300 ? 300 : childrenRect.height
                        height: 300 + carousel.height
                        color: bl
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
                            source:  visible ? (library.currentGame.screenshots[carousel.currentIndex] ? library.currentGame.screenshots[carousel.currentIndex].thumbUrl : '') : ''
                            opacity: 0.6
                        }
                        Image {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            id: largeView
                            fillMode: Image.PreserveAspectFit
                            // width: parent.width
                            // anchors.fill:
                            height: 300
                            source: visible ? (library.currentGame.screenshots[carousel.currentIndex] ? library.currentGame.screenshots[carousel.currentIndex].sourceUrl : '') : ''
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
                                fillMode: Image.PreserveAspectFit
                                anchors.centerIn: parent
                                width: sourceSize.width > parent.width ? parent.width : sourceSize.width
                                // width: parent.width
                                // height: parent.height
                                source: largeView.source
                            }
                        }
                        Rectangle {
                            width: parent.width
                            height: 50
                            anchors.bottom: parent.bottom
                            opacity: 0.7
                            color: bl
                            ListView {
                                anchors.horizontalCenter: parent.horizontalCenter

                                id: carousel
                                clip: true
                                width: contentWidth
                                height: parent.height

                                model: library.currentGame.screenshots
                                orientation: ListView.Horizontal
                                spacing: 5
                                boundsBehavior: Flickable.StopAtBounds
                                // ScrollBar.horizontal: ScrollBar { }
                                delegate: Rectangle {
                                    height: parent.height
                                    width: 100
                                    color: fg
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
                                    border.color: ListView.isCurrentItem ? sel : thumbMouseArea.containsMouse ? hl : fg
                                }
                            }
                        }
                    }
                }
                /* Body */
                Grid {
                    id: bodyGrid
                    columns: 2
                    width: parent.width
                    Column {

                        id: desc

                        width: parent.width - miscInfo.width
                        anchors.bottomMargin: 40
                        // anchors.left: parent.left
                        // anchors.right: miscInfo.left

                        /* Description */
                        Rectangle {
                            visible: library.currentGame.description
                            width: parent.width
                            height: descHeading.height
                            color: tr
                            Rectangle {
                                anchors.fill: parent
                                color: fg
                                anchors.leftMargin: 40
                                anchors.rightMargin: 40
                                anchors.bottomMargin: 10
                            }
                            Text {
                                id: descHeading
                                leftPadding: 50
                                rightPadding: 40
                                topPadding: 10
                                bottomPadding: 20
                                width: parent.width
                                color: tc
                                font.pixelSize: 24
                                text: qsTr('Description')
                                wrapMode: Text.WrapAnywhere
                            }
                        }
                        Text {
                            visible: library.currentGame.description
                            leftPadding: 50
                            rightPadding: 40
                            topPadding: 0
                            bottomPadding: 10
                            width: parent.width
                            color: tc
                            textFormat: Text.RichText
                            font.pixelSize: 16
                            text: library.currentGame.description
                            wrapMode: Text.WordWrap
                        }
                        /* Releases */
                        Rectangle {
                            visible: library.currentGame.releases.length
                            width: parent.width
                            height: releaseHeading.height
                            color: tr
                            Rectangle {
                                anchors.fill: parent
                                color: fg
                                anchors.leftMargin: 40
                                anchors.rightMargin: 40
                                anchors.bottomMargin: 10
                            }
                            Text {
                                id: releaseHeading
                                leftPadding: 50
                                rightPadding: 40
                                topPadding: 10
                                bottomPadding: 20
                                width: parent.width
                                color: tc
                                font.pixelSize: 24
                                text: qsTr('Releases')
                                wrapMode: Text.WrapAnywhere
                            }
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
                                    leftPadding: 50
                                    Text {
                                        color: tc
                                        font.pixelSize: 20
                                        text: qsTr('Version %1').arg(version)
                                        wrapMode: Text.WrapAnywhere
                                    }
                                    Text {
                                        color: tc
                                        font.pixelSize: 20
                                        text: formatTimestamp(timestamp)
                                        wrapMode: Text.WrapAnywhere
                                    }
                                }
                                Text {
                                    leftPadding: 50
                                    rightPadding: 40
                                    topPadding: 10
                                    bottomPadding: 10
                                    width: parent.width
                                    color: tc
                                    font.pixelSize: 16
                                    text: description
                                    wrapMode: Text.WrapAnywhere
                                }
                            }
                        }
                    }
                    /* Links and Categories */
                    Rectangle {
                        width: 200
                        id: miscInfo
                        color: tr
                        // height:  Math.max(libraryView.height - bodyGrid.y - 35 , Math.max(desc.height, lists.height))
                        height: lists.height
                        Rectangle {
                            anchors.fill: parent
                            color: fg
                            anchors.rightMargin: 40
                            anchors.bottomMargin: 40
                        }
                        Column {
                            id: lists
                            width: parent.width
                            bottomPadding: 40
                            // anchors.left: desc.right
                            // anchors.right: parent.right
                            Text {
                                visible: library.currentGame.developerName
                                leftPadding: 10
                                rightPadding: 50
                                topPadding: 10
                                bottomPadding: 10
                                width: parent.width
                                color: sel
                                font.pixelSize: 16
                                text: qsTr('Developer')
                                wrapMode: Text.WrapAnywhere
                                Rectangle {
                                    anchors.right: parent.right
                                    anchors.left: parent.left
                                    anchors.bottom: parent.bottom
                                    height: 1
                                    color: tr
                                    border.color: hl
                                    anchors.rightMargin: 40
                                }
                            }
                            Text {
                                visible: library.currentGame.developerName
                                leftPadding: 10
                                rightPadding: 50
                                topPadding: 5
                                bottomPadding: 5
                                width: parent.width
                                color: tc
                                font.pixelSize: 12
                                text: library.currentGame.developerName
                                wrapMode: Text.WordWrap
                            }
                            Text {
                                visible: library.currentGame.license
                                leftPadding: 10
                                rightPadding: 50
                                topPadding: 10
                                bottomPadding: 10
                                width: parent.width
                                color: sel
                                font.pixelSize: 16
                                text: qsTr('License')
                                wrapMode: Text.WrapAnywhere
                                Rectangle {
                                    anchors.right: parent.right
                                    anchors.left: parent.left
                                    anchors.bottom: parent.bottom
                                    height:1
                                    color: tr
                                    border.color: hl
                                    anchors.rightMargin: 40
                                }
                            }
                            Text {
                                visible: library.currentGame.license
                                leftPadding: 10
                                rightPadding: 50
                                topPadding: 5
                                bottomPadding: 5
                                width: parent.width
                                color: tc
                                font.pixelSize: 12
                                text: library.currentGame.license
                                wrapMode: Text.WordWrap
                            }
                            Text {
                                leftPadding: 10
                                rightPadding: 50
                                topPadding: 10
                                bottomPadding: 10
                                width: parent.width
                                color: sel
                                font.pixelSize: 16
                                text: qsTr('Links')
                                wrapMode: Text.WrapAnywhere
                                Rectangle {
                                    anchors.right: parent.right
                                    anchors.left: parent.left
                                    anchors.bottom: parent.bottom
                                    height:1
                                    color: tr
                                    border.color: hl
                                    anchors.rightMargin: 40
                                }
                            }
                            ListView {
                                model: library.currentGame.urls
                                width: parent.width
                                height: contentHeight
                                id: linksList
                                delegate: Column {
                                    width: parent.width
                                    Button {
                                        leftPadding: 10
                                        rightPadding: 50
                                        topPadding: 5
                                        // bottomPadding: index+1 < linksList.count ? 0 : 5
                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                Qt.openUrlExternally(url)
                                            }
                                        }
                                        contentItem: Row {
                                            Image {
                                                width: 14
                                                source: 'icons/' + icon
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            Text {
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
                                                leftPadding: 5
                                                font.pixelSize: 12
                                                text: getTitle(type)
                                                color: tc
                                            }
                                        }
                                        background: Rectangle {
                                            anchors.fill: parent
                                            color: fg
                                        }
                                    }
                                }
                            }
                            Text {
                                leftPadding: 10
                                rightPadding: 50
                                topPadding: 10
                                bottomPadding: 10
                                width: parent.width
                                color: sel
                                font.pixelSize: 16
                                text: qsTr('Categories')
                                wrapMode: Text.WrapAnywhere
                                Rectangle {
                                    anchors.right: parent.right
                                    anchors.left: parent.left
                                    anchors.bottom: parent.bottom
                                    height:1
                                    color: tr
                                    border.color: hl
                                    anchors.rightMargin: 40
                                }
                            }
                            ListView {
                                model: library.currentGame.categories
                                width: parent.width
                                height: contentHeight
                                id: categoriesList
                                delegate: Column {
                                    width: parent.width
                                    Text {
                                        leftPadding: 10
                                        rightPadding: 50
                                        topPadding: 5
                                        bottomPadding: index+1 < categoriesList.count ? 0 : 5
                                        width: parent.width
                                        color: tc
                                        font.pixelSize: 12
                                        text: library.currentGame.categories[index]
                                        wrapMode: Text.WrapAnywhere
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
