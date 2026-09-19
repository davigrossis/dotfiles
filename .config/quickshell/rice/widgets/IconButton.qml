import QtQuick
import qs.services

// Botão redondo só com ícone.
StateLayer {
    id: root

    property string icon: ""
    property real iconSize: 20
    property color iconColor: active ? Theme.primary : Theme.surfaceFg
    property bool filled: false
    property string tooltip: ""

    implicitWidth: 34
    implicitHeight: 34
    radius: Theme.radius.full

    MIcon {
        anchors.centerIn: parent
        icon: root.icon
        size: root.iconSize
        color: root.disabled ? Theme.alpha(Theme.surfaceFg, 0.38) : root.iconColor
        fill: root.filled || root.active ? 1 : 0
    }
}
