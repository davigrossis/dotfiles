import QtQuick
import QtQuick.Layouts
import qs.services

// "Ilha" flutuante da barra: fundo semitransparente (com blur do Hyprland atrás).
Rectangle {
    id: root

    default property alias content: row.data
    property real hpad: 5

    implicitWidth: row.implicitWidth + hpad * 2
    implicitHeight: Theme.barHeight
    radius: Theme.radius.normal + 2
    color: Theme.barBg
    border.width: 1
    border.color: Theme.alpha(Theme.outlineVariant, 0.45)

    Behavior on implicitWidth {
        NumberAnimation { duration: Theme.anim.normal; easing.type: Easing.OutCubic }
    }

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        x: root.hpad
        spacing: 2
    }
}
