import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Athenaeum 1.0

Page {
    header: NavigationBar {
        activeView: 'game'
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
                        contentItem: Text {
                            enabled: !library.currentGame.processing
                            color: Material.background
                            text: qsTr('Install')
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            implicitWidth: 100
                            implicitHeight: 40
                            color: library.currentGame.processing ? Material.color(Material.Grey, theme == Material.Dark ? Material.Shade600 : Material.Shade400) : Material.primary
                        }
                    }
                    Button {
                        visible:  library.currentGame.installed
                        enabled: !library.currentGame.playing
                        onClicked: {
                            window.playGame(library.currentGame.id)
                        }
                        contentItem: Text {
                            color: Material.background
                            text: qsTr('Play')
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            implicitWidth: 100
                            implicitHeight: 40
                            color: library.currentGame.playing ? Material.color(Material.LightGreen, Material.Shade400) : Material.accent
                        }
                    }
                    Button {
                        visible: library.currentGame.hasUpdate && library.currentGame.installed
                        enabled: !library.currentGame.playing && !library.currentGame.processing
                        onClicked: {
                            window.updateGame(library.currentGame.id)
                        }
                        contentItem: Text {
                            color: Material.background
                            text: qsTr('Update')
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            implicitWidth: 100
                            implicitHeight: 40
                            color: Material.primary
                        }
                    }
                    Button {
                        contentItem: Text {
                            color: Material.background
                            text: qsTr('Uninstall')
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
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
                                color: Material.background
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
                                    color: Material.foreground
                                    font.pixelSize: 20
                                    text: qsTr('Are you sure?')
                                }
                                Row {
                                    topPadding: 20
                                    spacing: 20
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    Button {
                                        MouseArea {
                                            id: uninstallPopupMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                window.uninstallGame(library.currentGame.id)
                                                uninstallPopup.close()
                                            }
                                        }
                                        contentItem: Text {
                                            color: Material.background
                                            text: qsTr('Yes')
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        background: Rectangle {
                                            implicitWidth: 100
                                            implicitHeight: 40
                                            color: uninstallPopupMouseArea.containsMouse ? Material.color(Material.Grey, theme == Material.Dark ? Material.Shade600 : Material.Shade400) : Material.primary
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
                                            id: cancelPopupMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                uninstallPopup.close()
                                            }
                                        }
                                        background: Rectangle {
                                            implicitWidth: 100
                                            implicitHeight: 40
                                            color: cancelPopupMouseArea.containsMouse ? Material.color(Material.Grey, theme == Material.Dark ? Material.Shade600 : Material.Shade400) : Material.primary
                                        }
                                    }
                                }
                            }
                        }
                        background: Rectangle {
                            implicitWidth: 100
                            implicitHeight: 40
                            color: uninstallMouseArea.containsMouse ? Material.color(Material.Pink) : Material.primary
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
                        source:  visible ? (library.currentGame.screenshots[carousel.currentIndex] ? library.currentGame.screenshots[carousel.currentIndex].thumbUrl : '') : ''
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

                            model: library.currentGame.screenshots
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
                id: bodyGrid
                columns: 2
                width: parent.width
                Column {
                    id: desc
                    width: parent.width - miscInfo.width
                    anchors.bottomMargin: 40

                    /* Description */
                    Text {
                        visible: library.currentGame.description
                        id: descHeading
                        width: parent.width
                        leftPadding: 50
                        rightPadding: 40
                        topPadding: 10
                        bottomPadding: 20
                        color: Material.foreground
                        font.pixelSize: 24
                        text: qsTr('Description')
                        wrapMode: Text.WrapAnywhere
                    }
                    Text {
                        visible: library.currentGame.description
                        leftPadding: 50
                        rightPadding: 40
                        topPadding: 0
                        bottomPadding: 10
                        width: parent.width
                        color: Material.foreground
                        textFormat: Text.RichText
                        font.pixelSize: 16
                        text: library.currentGame.description
                        wrapMode: Text.WordWrap
                    }
                    /* Releases */
                    Text {
                        id: releaseHeading
                        visible: library.currentGame.releases.length
                        leftPadding: 50
                        rightPadding: 40
                        topPadding: 10
                        bottomPadding: 20
                        width: parent.width
                        color: Material.foreground
                        font.pixelSize: 24
                        text: qsTr('Releases')
                        wrapMode: Text.WrapAnywhere
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
                                leftPadding: 50
                                rightPadding: 40
                                topPadding: 10
                                bottomPadding: 10
                                width: parent.width
                                color: Material.foreground
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
                            color: Material.foreground
                            font.pixelSize: 16
                            text: qsTr('Developer')
                            wrapMode: Text.WrapAnywhere
                            Rectangle {
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.bottom: parent.bottom
                                height: 1
                                color: tr
                                border.color: Material.accent
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
                            color: Material.foreground
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
                            color: Material.foreground
                            font.pixelSize: 16
                            text: qsTr('License')
                            wrapMode: Text.WrapAnywhere
                            Rectangle {
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.bottom: parent.bottom
                                height:1
                                color: tr
                                border.color: Material.accent
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
                            color: Material.foreground
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
                            color: Material.foreground
                            font.pixelSize: 16
                            text: qsTr('Links')
                            wrapMode: Text.WrapAnywhere
                            Rectangle {
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.bottom: parent.bottom
                                height:1
                                color: tr
                                border.color: Material.accent
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
                                            color: Material.foreground
                                        }
                                    }
                                    background: Rectangle {
                                        anchors.fill: parent
                                        color: tr
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
                            color: Material.foreground
                            font.pixelSize: 16
                            text: qsTr('Categories')
                            wrapMode: Text.WrapAnywhere
                            Rectangle {
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.bottom: parent.bottom
                                height:1
                                color: tr
                                border.color: Material.accent
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
                                    color: Material.foreground
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
