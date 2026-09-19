import QtQuick
import qs.services

// Texto padrão do rice (Inter, cor on_surface).
Text {
    property bool mono: false
    property bool dim: false

    color: dim ? Theme.surfaceVariantFg : Theme.surfaceFg
    font.family: mono ? Theme.font.mono : Theme.font.sans
    font.pixelSize: Theme.font.normal
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering
    textFormat: Text.PlainText

    Behavior on color {
        ColorAnimation { duration: Theme.anim.fast }
    }
}
