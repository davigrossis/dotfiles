import QtQuick
import qs.services

// Switch estilo Material 3.
MouseArea {
    id: root

    property bool checked: false
    signal toggled(bool value)

    implicitWidth: 44
    implicitHeight: 26
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.toggled(!root.checked)

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Theme.primary : Theme.alpha(Theme.surfaceContainerHighest, 0.9)
        border.width: root.checked ? 0 : 2
        border.color: Theme.outline
        Behavior on color { ColorAnimation { duration: Theme.anim.fast } }

        Rectangle {
            id: thumb
            property real d: root.checked ? 18 : (root.pressed ? 18 : 12)
            width: d
            height: d
            radius: d / 2
            anchors.verticalCenter: parent.verticalCenter
            x: root.checked ? parent.width - width - 4 : (root.pressed ? 3 : 7)
            color: root.checked ? Theme.primaryFg : Theme.outline
            Behavior on x { NumberAnimation { duration: Theme.anim.normal; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
            Behavior on d { NumberAnimation { duration: Theme.anim.fast } }
            Behavior on color { ColorAnimation { duration: Theme.anim.fast } }
        }
    }
}
