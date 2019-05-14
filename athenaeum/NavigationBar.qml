import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Athenaeum 1.0

ToolBar {
    id: toolBar
    property string activeView
    Rectangle {
        anchors.fill: parent
        color: Material.background
    }

    RowLayout {
        ToolButton {
            icon.source: 'icons/left.svg'
            enabled: stackIndex > 0
            onClicked: {
                backward()
            }
        }
        ToolButton {
            icon.source: 'icons/right.svg'
            enabled: stack.length - 1 > stackIndex
            onClicked: {
                forward()
            }
        }
        ToolButton {
            highlighted: activeView === 'browse' || activeView === 'game' || activeView === 'search'
            text: qsTr('Browse')
            icon.source: 'icons/browse.svg'
            onClicked: {
                if (activeView !== 'browse') {
                    enter(browseView, null)
                }
            }
        }
        ToolSeparator {}
        ToolButton {
            highlighted: activeView === 'library'
            text: qsTr('Library')
            icon.source: 'icons/library.svg'
            onClicked: {
                if (!highlighted){
                    enter(libraryView, null)
                }
            }
        }
        ToolSeparator {}
        ToolButton {
            highlighted: activeView === 'settings'
            text: qsTr('Settings')
            icon.source: 'icons/settings.svg'
            onClicked: {
                if (!highlighted) {
                    enter(settingsView, null)
                }
            }
        }
    }
    
    RowLayout {
        visible: activeView === 'library'
        anchors.right: menuButton.left
        ToolButton {
            id: tableButton
            icon.source: 'icons/table.svg'
            onClicked: {
                visible = false
            }
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Show games in a table view.")
        }
        ToolButton {
            id: listButton
            icon.source: 'icons/list.svg'
            onClicked: {
                visible = false
            }
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Show games in a list view.")
        }
    }
    RowLayout {
        visible: activeView === 'settings'
        anchors.right: menuButton.left
        ToolButton {
            icon.source: 'icons/reset.svg'
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Reset settings to defaults.")
        }
    }

    ToolButton {
        visible: activeView === 'browse' || activeView === 'game' || activeView === 'search'
        icon.source: 'icons/search.svg'
        anchors.right: searchField.left
        onClicked: {
            searchFieldShow1.start()
            searchFieldShow2.start()
            searchField.focus = true
        }
    }
    TextField {
        id: searchField
        visible: true
        width: 0
        opacity: 0
        NumberAnimation { id: searchFieldShow1; target: searchField; property: 'width'; to: 200; duration: 250 }
        NumberAnimation { id: searchFieldShow2; target: searchField; property: 'opacity'; to: 1; duration: 250 }
        NumberAnimation { id: searchFieldHide1; target: searchField; property: 'width'; to: 0; duration: 250 }
        NumberAnimation { id: searchFieldHide2; target: searchField; property: 'opacity'; to: 0; duration: 250 }
        onFocusChanged: {
            if (!focus) {
                searchFieldHide1.start()
                searchFieldHide2.start()
            }
        }
        placeholderText: qsTr('Search')
        anchors.right: menuButton.left
        color: Material.foreground
        
        onAccepted: {
            enter(searchView, null)
        }
        
        onTextChanged: {
            library.searchValue = text
            window.search()
            if(!resultsDropDown.opened) {
                resultsDropDown.open()
            }
        }
        Keys.onEscapePressed: {
            text = ''
            focus = false
        }
        
        Menu {
            focus: false
            id: resultsDropDown
            y: toolBar.height
            height: resultsList.contentHeight

            ListView {
                id: resultsList
//                 anchors.fill: parent
                model: library.filter
                boundsBehavior: Flickable.StopAtBounds
                keyNavigationEnabled: true
                height: contentHeight
                clip:true
                delegate: Row {
                    Image {
                        source: iconSmall
                    }
                    Text {
                        text: name
                        color: Material.foreground
                    }
                }

            }
        }
    }

    ToolButton {
        id: menuButton
        anchors.right: parent.right
        icon.source: 'icons/menu.svg'
        onClicked: menu.open()
        Menu {
            id: menu
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
                onTriggered: library.processingCount > 0 ? confirmExit.open() : Qt.quit()
                Popup {
                    id: confirmExit
                    x: Math.round((parent.width - width) / 2)
                    y: Math.round((parent.height - height) / 2)
                    parent: stackView
                    dim: true
                    modal: true
                    contentItem: Column {
                        spacing: 20
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Material.foreground
                            font.pixelSize: 20
                            text: qsTr('You have operations pending.')
                        }
                        Row {
                            spacing: 20
                            anchors.horizontalCenter: parent.horizontalCenter
                            Button {
                                text: qsTr('Close Anyway')
                                onClicked: {
                                    Qt.quit()
                                }
                            }
                            Button {
                                text: qsTr('Cancel')
                                onClicked: {
                                    confirmExit.close()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
