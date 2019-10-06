import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Athenaeum 1.0

Page {
    header: NavigationBar {
        activeView: 'library'
    }
    LibraryListView {
        visible: library.view === 'list'
    }
    LibraryGridView {
        visible: library.view === 'grid'
    }
}
