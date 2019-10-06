from PyQt5.QtCore import Qt, QObject, QEvent, pyqtSignal


class MouseHandler(QObject):
    forward = pyqtSignal()
    backward = pyqtSignal()

    def eventFilter(self, obj, event):
        if event.type() == QEvent.MouseButtonPress:
            if event.button() == Qt.XButton1:
                self.forward.emit()
                return True
            if event.button() == Qt.XButton2:
                self.backward.emit()
                return True

        return super().eventFilter(obj, event)