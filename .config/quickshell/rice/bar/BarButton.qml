import QtQuick
import QtQuick.Layouts
import qs.services
import qs.widgets

// Botão da barra: ícone + texto opcional, com hover e destaque quando o painel está aberto.
StateLayer {
    id: root

    property string icon: ""
    property string label: ""
    property real iconFill: 0
    property color iconColor: active ? Theme.primary : Theme.surfaceFg
    property color labelColor: Theme.surfaceFg
    property bool badge: false
    property bool labelMono: true

    implicitHeight: Theme.barHeight - 8
    implicitWidth: Math.max(implicitHeight, row.implicitWidth + 16)
    radius: Theme.radius.normal
    activeColor: Theme.alpha(Theme.primary, 0.18)

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 5

        Item {
            visible: root.icon !== ""
            implicitWidth: 20
            implicitHeight: 20
            MIcon {
                anchors.centerIn: parent
                icon: root.icon
                size: 19
                fill: root.iconFill
                color: root.iconColor
            }
            Rectangle {
                visible: root.badge
                width: 8
                height: 8
                radius: 4
                color: Theme.error
                border.width: 1.5
                border.color: Theme.surfaceContainer
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: -1
                anchors.topMargin: -1
            }
        }

        Txt {
            visible: root.label !== ""
            text: root.label
            color: root.labelColor
            mono: root.labelMono
            font.pixelSize: Theme.font.small + 1
            font.weight: Font.DemiBold
        }
    }
}
