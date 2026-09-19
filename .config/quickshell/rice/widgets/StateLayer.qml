import QtQuick
import qs.services

// Área clicável com camada de estado Material (hover/pressionado/ativo) desenhada atrás
// do conteúdo. Coloque os filhos normalmente dentro dela.
MouseArea {
    id: root

    property real radius: Theme.radius.normal
    property color baseColor: "transparent"
    property color stateColor: Theme.surfaceFg
    property bool active: false
    property color activeColor: Theme.alpha(Theme.primary, 0.20)
    property bool disabled: false
    readonly property alias background: bg

    hoverEnabled: true
    enabled: !disabled
    cursorShape: disabled ? Qt.ArrowCursor : Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    Rectangle {
        id: bg
        anchors.fill: parent
        z: -1
        radius: root.radius
        color: {
            const base = root.active ? root.activeColor : root.baseColor;
            if (root.disabled)
                return base;
            if (root.pressed)
                return Theme.mix(base.a > 0 ? base : Theme.alpha(root.stateColor, 0), Theme.alpha(root.stateColor, 1), 0.16);
            if (root.containsMouse)
                return Theme.mix(base.a > 0 ? base : Theme.alpha(root.stateColor, 0), Theme.alpha(root.stateColor, 1), 0.09);
            return base;
        }
        Behavior on color {
            ColorAnimation { duration: Theme.anim.fast }
        }
    }
}
