import QtQuick
import qs.services

// Slider "pílula" (estilo quick settings): trilho grosso, preenchimento na cor primária e
// ícone dentro do trilho. Arrastar, clicar ou rolar o mouse ajusta; clicar no ícone
// emite iconClicked (ex.: mudo).
Item {
    id: root

    property real value: 0
    property real from: 0
    property real to: 1
    property real step: 0.05
    property string icon: ""
    property bool muted: false
    property bool showValue: true
    property string valueText: Math.round(ratio * 100) + "%"
    signal moved(real value)
    signal iconClicked

    readonly property bool dragging: area.pressed
    property real dragValue: 0
    readonly property real shown: dragging ? dragValue : value
    readonly property real ratio: Math.max(0, Math.min(1, (shown - from) / (to - from)))

    implicitWidth: 220
    implicitHeight: 30

    function valueAt(x) {
        const r = Math.max(0, Math.min(1, x / width));
        return from + r * (to - from);
    }
    function clamp(v) {
        return Math.max(from, Math.min(to, v));
    }

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: Theme.alpha(Theme.surfaceContainerHighest, 0.95)
    }

    Rectangle {
        id: fillBar
        height: parent.height
        radius: height / 2
        width: Math.max(height, root.ratio * parent.width)
        color: root.muted ? Theme.alpha(Theme.surfaceFg, 0.35) : Theme.primary
        Behavior on width {
            enabled: !root.dragging
            NumberAnimation { duration: Theme.anim.fast; easing.type: Easing.OutCubic }
        }
        Behavior on color { ColorAnimation { duration: Theme.anim.fast } }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        preventStealing: true
        onPressed: mouse => {
            root.dragValue = root.valueAt(mouse.x);
            root.moved(root.dragValue);
        }
        onPositionChanged: mouse => {
            if (pressed) {
                root.dragValue = root.valueAt(mouse.x);
                root.moved(root.dragValue);
            }
        }
        onWheel: wheel => {
            const d = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : -wheel.angleDelta.x;
            root.moved(root.clamp(root.value + (d > 0 ? root.step : -root.step)));
        }
    }

    // ícone clicável (mudo) dentro do trilho
    MouseArea {
        id: iconArea
        visible: root.icon !== ""
        width: root.height + 4
        height: root.height
        cursorShape: Qt.PointingHandCursor
        onClicked: root.iconClicked()
        MIcon {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 2
            icon: root.icon
            size: 18
            fill: 1
            color: root.ratio * root.width > root.height * 0.9 ? (root.muted ? Theme.surface : Theme.primaryFg) : Theme.surfaceFg
        }
    }

    Txt {
        visible: root.showValue
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        text: root.valueText
        font.pixelSize: Theme.font.small
        font.weight: Font.DemiBold
        color: root.ratio > 0.86 ? (root.muted ? Theme.surface : Theme.primaryFg) : Theme.surfaceVariantFg
    }
}
