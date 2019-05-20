import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Athenaeum 1.0

ApplicationWindow {
    id: window
    signal indexUpdated(int index)
    signal installGame(string id)
    signal uninstallGame(string id)
    signal updateGame(string id)
    signal playGame(string id)
    signal searchGames()
    signal filter()
    signal sort(string sort)
    signal updateAll()
    signal checkAll()
    signal notify(string name, string message, string icon)
    signal resetDatabase()

    width: 1000
    height: 700
    visible: true

    property int theme: settings.theme == 'Dark' ? Material.Dark : settings.theme == 'Light' ? Material.Light: Material.System
    property color tr: 'transparent'
    Material.theme: theme
    Material.accent: Material.LightBlue
    Material.primary: Material.Grey
    
    property var stack: []
    property int stackIndex: 0
    
    property int browseView: 0
    property int gameView: 1
    property int searchView: 2
    property int libraryView: 3
    property int settingsView: 4
    
    function debounce(func, wait, immediate) {
        var timeout

        return function executedFunction() {
            var context = this
            var args = arguments
                
            var later = function() {
                timeout = null
                if (!immediate) func.apply(context, args)
            }

            var callNow = immediate && !timeout
            
            clearTimeout(timeout)

            timeout = setTimeout(later, wait)
            
            if (callNow) func.apply(context, args)
        }
    }
    
    function changeView(view, details) {
        if (details) {
            switch (view) {
                case gameView:
                    gameViewId.game = library.getGameById(details)
                    break;
            
                case searchView:
                    searchViewId.searchValue = details
                    break;
                    
                case libraryView:
                    window.indexUpdated(library.findById(details))
                    break;
            }
        }
        
        stackView.currentIndex = view
    }
    
    function enter(view, details) {
        stack.splice(stackIndex + 1, stack.length - stackIndex - 1, [view, details])
        stackIndex = stack.length - 1
        
        changeView(view, details)
    }
   
    function backward() {
        stackIndex = stackIndex - 1
        changeView(stack[stackIndex][0], stack[stackIndex][1])
    }

    function forward() {
        stackIndex = stackIndex + 1
        changeView(stack[stackIndex][0], stack[stackIndex][1])
    }

    StackLayout {
        id: stackView
        anchors.fill: parent
        visible: !loader.loading
        Component.onCompleted: {
            enter(browseView, null)
        }
        BrowseView {}
        GameView { id: gameViewId }
        SearchView { id: searchViewId }
        LibraryView {}
        SettingsView {}
    }

    Rectangle {
        anchors.fill: parent
        color: Material.background
        visible: loader.loading

        BusyIndicator {
            id: loadingIndicator
            anchors.centerIn: parent
            running: loader.loading && !loader.error
        }

        Text {
            id: loadingMessage
            anchors.top: loadingIndicator.bottom
            text: loader.message
            color: Material.foreground
            width: parent.width
            topPadding: 10
            horizontalAlignment: Text.AlignHCenter
        }

        /* Logs */
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 40
            anchors.leftMargin: 40
            anchors.bottom: parent.bottom
            color: Material.background
            height: 160

            Flickable {
                id: testFlick
                anchors.fill: parent

                clip: true
                boundsBehavior: Flickable.StopAtBounds

                TextArea {
                    id: ta
                    onContentHeightChanged: {
                        testFlick.contentY = (contentHeight <= 150 ? 0 : contentHeight - 150)
                    }
                    color: Material.foreground
                    readOnly: true
                    text: loader.log
                    background: Rectangle {
                        anchors.fill: parent
                        color: Material.background
                    }
                }
            }
        }
    }
}
