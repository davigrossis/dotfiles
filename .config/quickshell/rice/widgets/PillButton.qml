import QtQuick
import QtQuick.Layouts
import qs.services

// Botão de texto em pílula (opcionalmente com ícone). "tonal" = container secundário,
// "filled" = cor primária, senão contorno.
StateLayer {
    id: root

    property string text: ""
    property string icon: ""
    property string variant: "tonal"   // tonal | filled | outline | danger
    property bool compact: false
    readonly property color fg: variant === "filled" ? Theme.primaryFg : variant === "danger" ? Theme.errorContainerFg : variant === "tonal" ? Theme.secondaryContainerFg : Theme.surfaceFg

    implicitHeight: compact ? 30 : 36
    implicitWidth: row.implicitWidth + (compact ? 20 : 28)
    radius: Theme.radius.full
    baseColor: variant === "filled" ? Theme.primary : variant === "danger" ? Theme.errorContainer : variant === "tonal" ? Theme.secondaryContainer : "transparent"
    stateColor: fg

    Rectangle {
        visible: root.variant === "outline"
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.width: 1
        border.color: Theme.outline
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6
        MIcon {
            visible: root.icon !== ""
            icon: root.icon
            size: root.compact ? 16 : 18
            color: root.fg
        }
        Txt {
            text: root.text
            color: root.fg
            font.pixelSize: root.compact ? Theme.font.small : Theme.font.normal
            font.weight: Font.DemiBold
        }
    }
}
