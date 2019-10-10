import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Athenaeum 1.0

Popup {
    property string source: ''

    onAboutToShow: {
        fullscreenImage.source = source
    }
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
            close()
        }
    }
    background: Image {
        id: fullscreenImage
        fillMode: Image.PreserveAspectFit
        anchors.centerIn: parent
        width: sourceSize.width > parent.width ? parent.width : sourceSize.width
        height: parent.height
    }
}
