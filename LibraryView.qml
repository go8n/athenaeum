import QtQuick 2.7
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.4
import QtQuick.Layouts 1.11
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

    background: Rectangle {
        anchors.fill: parent
        color: bg
    }
    header: ToolBar {
        id: toolBar
        RowLayout {
            spacing: 0
            anchors.fill: parent
            TextField {
                id: searchField
                placeholderText: 'Search...'
                Layout.fillHeight: true
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
            Label {
                background: Rectangle {
                    anchors.fill: parent
                    color: fg
                }
                color: tc
                text: "Library"
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
                        text: "Settings"
                        onTriggered: stackView.push(settingsView)
                    }
                    MenuItem {
                        text: "Update All"
                        onTriggered: window.updateAll()
                    }
                    MenuItem {
                        text: "Exit"
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
        Keys.onDownPressed: {
            console.log(listView.currentIndex)
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
                        window.indexUpdated(index)
                        listView.currentIndex = index
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
                    color: "transparent"
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
                    text: name
                    anchors.topMargin: 5
                    anchors.rightMargin: 5
                    anchors.bottomMargin: 5
                    verticalAlignment: Text.AlignVCenter
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
                spacing: 20
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
                            // Rectangle {
                            //     anchors.fill: parent
                            //     color: 'green'
                            // }
                        }

                        Text {
                            id: gameSummary
                            anchors.top: gameTitle.bottom
                            anchors.left: gameLogo.right
                            anchors.right: parent.right

                            // Rectangle {
                            //     anchors.fill: parent
                            //     color: 'orange'
                            // }
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
                        // }
                        Row {
                            anchors.top: gameSummary.bottom
                            anchors.left: gameLogo.right
                            anchors.right: parent.right
                            spacing: 5
                            leftPadding: 20
                            topPadding: 10
                            Button {
                                text: 'Install'
                                visible: !library.currentGame.installed
                                enabled: !library.currentGame.processing
                                onClicked: {
                                    window.installGame(library.currentGame.id)
                                }

                            }
                            Button {
                                text: 'Play'
                                visible:  library.currentGame.installed
                                enabled: !library.currentGame.playing
                                onClicked: {
                                    window.playGame(library.currentGame.id)
                                }
                                background: Rectangle {
                                    implicitWidth: 100
                                    implicitHeight: 40
                                    color: library.currentGame.playing ? 'lightgreen' : 'lightblue'
                                }
                            }
                            Button {
                                text: 'Uninstall'
                                visible: library.currentGame.installed
                                enabled: !library.currentGame.processing
                                MouseArea {
                                    id: uninstallMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        window.uninstallGame(library.currentGame.id)
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
                // }
                /* Logs */
                ScrollView {
                    width: parent.width
                    height: 150
                    visible: library.currentGame.processing
                    TextArea {
                        anchors.fill: parent
                        color: tc
                        readOnly: true
                        text: library.currentGame.log
                        background: Rectangle {
                            anchors.fill: parent
                            color: fg
                        }
                    }
                }
                /* Screenshots */
                Column {
                    width: parent.width
                    clip: true
                    Rectangle {
                        visible: library.currentGame.screenshots.length
                        width: parent.width
                        // height: childrenRect.height > 300 ? 300 : childrenRect.height
                        height: 300
                        color: fg
                        Image {
                            anchors.leftMargin: 40
                            anchors.rightMargin: 40
                            // anchors.top: parent.top
                            // anchors.bottom: parent.bottom
                            id: largeView
                            fillMode: Image.PreserveAspectFit
                            // width: parent.width
                            anchors.fill: parent
                            source: visible ? library.currentGame.screenshots[carousel.currentIndex].sourceUrl : ''
                            MouseArea {
                                anchors.centerIn: parent
                                width: parent.paintedWidth
                                height: parent.paintedHeight
                                onClicked: {
                                    fullscreenPreview.open()
                                }
                                // hoverEnabled: true
                                // id: thumbMouseArea
                            }
                        }
                        Popup {
                            id: fullscreenPreview
                            parent: Overlay.overlay
                            x: Math.round((window.width - width) / 2)
                            y: Math.round((window.height - height) / 2)

                            width: window.width
                            height: window.height
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
                                source: largeView.source
                            }
                        }
                    }
                    ListView {
                        anchors.horizontalCenter: parent.horizontalCenter
                        id: carousel
                        clip: true
                        width: contentWidth
                        height: 50
                        visible: library.currentGame.screenshots.length
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
                /* Description */
                Column {
                    visible: library.currentGame.description
                    // width: parent.width
                    Text {
                        leftPadding: 40
                        rightPadding: 40
                        topPadding: 20
                        bottomPadding: 20
                        width: col.width
                        color: tc
                        font.pixelSize: 24
                        text: 'Description'

                        wrapMode: Text.WrapAnywhere
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 1
                            color: ac
                            anchors.leftMargin: 40
                            anchors.rightMargin: 40
                            anchors.bottomMargin: 10

                        }
                    }
                    Text {
                        leftPadding: 40
                        rightPadding: 40
                        topPadding: 0
                        bottomPadding: 10
                        width: col.width
                        color: tc
                        textFormat: Text.RichText
                        font.pixelSize: 16
                        text: library.currentGame.description
                        wrapMode: Text.WordWrap
                    }
                }
                /* Developer */
                Column {
                    visible: library.currentGame.developerName
                    Text {
                        leftPadding: 40
                        rightPadding: 40
                        topPadding: 20
                        bottomPadding: 20
                        width: col.width
                        color: tc
                        font.pixelSize: 24
                        text: 'Developer'

                        wrapMode: Text.WrapAnywhere
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 1
                            color: ac
                            anchors.leftMargin: 40
                            anchors.rightMargin: 40
                            anchors.bottomMargin: 10

                        }
                    }
                    Text {
                        leftPadding: 40
                        rightPadding: 40
                        topPadding: 0
                        bottomPadding: 10
                        width: col.width
                        color: tc
                        textFormat: Text.PlainText
                        font.pixelSize: 16
                        text: library.currentGame.developerName
                        wrapMode: Text.WordWrap
                    }
                }


                Grid {
                    columns: 2
                    width: parent.width
                    bottomPadding: 10
                    Column {
                        width: parent.width/2
                        Text {
                            leftPadding: 40
                            rightPadding: 40
                            topPadding: 20
                            bottomPadding: 20
                            width: col.width/2
                            color: tc
                            font.pixelSize: 24
                            text: 'Links'
                            wrapMode: Text.WrapAnywhere
                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 1
                                color: ac
                                anchors.leftMargin: 40
                                anchors.rightMargin: 40
                                anchors.bottomMargin: 10

                            }
                        }
                        ListView {
                            model: library.currentGame.urls
                            width: parent.width
                            height: contentHeight
                            delegate: Column {
                                width: parent.width
                                Text {
                                    leftPadding: 40
                                    rightPadding: 40
                                    topPadding: 5
                                    width: col.width
                                    color: hl
                                    font.pixelSize: 16
                                    text: '<html><style type="text/css">* { color:'+tc+'; text-decoration: none; }</style><a href="' + url + '">' + type + '</a></html>'
                                    textFormat: Text.RichText
                                    wrapMode: Text.WrapAnywhere
                                    onLinkActivated: Qt.openUrlExternally(link)
                                }
                            }
                        }
                    }
                    Column {
                        width: parent.width/2
                        Text {
                            leftPadding: 40
                            rightPadding: 40
                            topPadding: 20
                            bottomPadding: 20
                            width: col.width/2
                            color: tc
                            font.pixelSize: 24
                            text: 'Categories'
                            wrapMode: Text.WrapAnywhere
                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 1
                                color: ac
                                anchors.leftMargin: 40
                                anchors.rightMargin: 40
                                anchors.bottomMargin: 10

                            }
                        }
                        ListView {
                            model: library.currentGame.categories
                            width: parent.width
                            height: contentHeight
                            delegate: Column {
                                width: parent.width
                                Text {
                                    leftPadding: 40
                                    rightPadding: 40
                                    topPadding: 5
                                    width: col.width
                                    color: tc
                                    font.pixelSize: 16
                                    text: library.currentGame.categories[index]
                                    wrapMode: Text.WrapAnywhere
                                }
                            }
                        }
                    }
                }
                // Rectangle {
                //
                //     color: 'red'
                //
                // }
                // Rectangle {
                //     width: parent.width
                //     height:50
                //     Text{
                //         anchors.fill: parent
                //         font.pixelSize: 48
                //         text: 'ylloooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooongggjhssssssssss'
                //         wrapMode: Text.WrapAnywhere
                //     }
                //     color: 'lightblue'
                // }
                /* Releases */
                Column {
                    visible: library.currentGame.releases.length
                    Text {
                        leftPadding: 40
                        rightPadding: 40
                        topPadding: 20
                        bottomPadding: 20
                        width: col.width
                        color: tc
                        font.pixelSize: 24
                        text: 'Releases'
                        textFormat: Text.RichText
                        wrapMode: Text.WrapAnywhere
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 1
                            color: ac
                            anchors.leftMargin: 40
                            anchors.rightMargin: 40
                            anchors.bottomMargin: 10

                        }
                    }
                    ListView {
                        // clip: true
                        // visible: library.currentGame.releases.length
                        model: library.currentGame.releases
                        width: parent.width
                        height: contentHeight
                        spacing: 10
                        // anchors.centerIn: parent
                        // boundsBehavior: Flickable.StopAtBounds
                        delegate: Column {
                            width: parent.width
                            // height: contentHeight
                            function formatTimestamp(ts) {
                                var t = new Date( 0 );
                                t.setSeconds(ts)
                                return  t.toDateString()
                            }

                            Row {
                                width: parent.width
                                spacing: 10
                                Text {
                                    leftPadding: 40
                                    color: tc
                                    font.pixelSize: 20
                                    text: 'Version ' + version
                                }
                                Text {
                                    rightPadding: 40
                                    color: tc
                                    font.pixelSize: 20
                                    text: formatTimestamp(timestamp)
                                }
                            }
                            Text {
                                leftPadding: 40
                                rightPadding: 40
                                topPadding: 10
                                bottomPadding: 10
                                width: col.width
                                color: tc
                                font.pixelSize: 16
                                text: description
                                wrapMode: Text.WrapAnywhere
                            }
                        }
                    }
                }
            }
        }
    }
}
