import QtQuick
import qs.services

// Cartão de agrupamento de controles (estilo painéis do KDE/CachyOS).
Rectangle {
    property real padding: 12
    default property alias content: inner.data
    readonly property alias contentItem: inner

    radius: Theme.radius.large
    color: Theme.cardBg
    border.width: 1
    border.color: Theme.alpha(Theme.outlineVariant, 0.35)
    implicitHeight: inner.childrenRect.height + padding * 2
    implicitWidth: 200

    Behavior on color {
        ColorAnimation { duration: Theme.anim.normal }
    }

    Item {
        id: inner
        anchors.fill: parent
        anchors.margins: parent.padding
    }
}
