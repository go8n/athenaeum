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
        function hideSearchBar() {
            text = ''
            searchFieldHide1.start()
            searchFieldHide2.start()
        }
        onFocusChanged: {
            if (!focus) {
                hideSearchBar()
            }
        }
        placeholderText: qsTr('Search')
        anchors.right: menuButton.left
        color: Material.foreground
        
        onAccepted: {
            resultsDropDown.close()
            enter(searchView, text)
            hideSearchBar()
        }
        
        onTextChanged: {
            search.searchValue = text
            if(!resultsDropDown.opened) {
                resultsDropDown.open()
            }
        }
        Keys.onEscapePressed: {
            focus = false
        }
        
        Menu {
            focus: false
            id: resultsDropDown
            y: toolBar.height
            height: resultsList.contentHeight
            topPadding: 0
            bottomPadding: 0

            ListView {
                id: resultsList
                model: search.resultsShort
                boundsBehavior: Flickable.StopAtBounds
                keyNavigationEnabled: true
                height: contentHeight
                delegate: ToolButton {
                    icon.source: iconSmall
                    icon.color: '#00000000'
                    text: name
                    rightPadding: parent.width
                    font.capitalization: Font.MixedCase
                    onClicked: {
                        resultsDropDown.close()
                        enter(gameView, id)
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
