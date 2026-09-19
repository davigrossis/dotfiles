import QtQuick
import qs.services

// Ícone da fonte Material Symbols Rounded (ligaduras: icon: "wifi").
// "fill" anima entre contorno (0) e preenchido (1).
Text {
    id: root

    property string icon: ""
    property real size: 18
    property real fill: 0
    property int weight: 400

    text: icon
    color: Theme.surfaceFg
    font.family: Theme.font.icon
    font.pixelSize: size
    font.variableAxes: ({
            "FILL": root.fill,
            "wght": root.weight,
            "opsz": Math.max(20, Math.min(48, root.size))
        })
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    renderType: Text.QtRendering

    Behavior on fill {
        NumberAnimation { duration: Theme.anim.normal; easing.type: Easing.OutCubic }
    }
    Behavior on color {
        ColorAnimation { duration: Theme.anim.fast }
    }
}
