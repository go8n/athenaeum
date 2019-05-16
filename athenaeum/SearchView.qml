import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Athenaeum 1.0

Page {
    header: NavigationBar {
        activeView: 'search'
    }
    
    property string search
    
    Flickable {
        anchors.fill: parent
        contentHeight: mainCol.height
        contentWidth: parent.width
        ScrollBar.vertical: ScrollBar { }
        boundsBehavior: Flickable.StopAtBounds
        Column {
            id: mainCol
            TextField {
                text: search
                placeholderText: qsTr('Search')
            }
        }
    }
}
