import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.widgets

// Relógio + data (pt-BR). Clique abre o calendário.
StateLayer {
    id: root

    property bool compact: false

    implicitHeight: Theme.barHeight - 8
    implicitWidth: row.implicitWidth + 20
    radius: Theme.radius.normal
    activeColor: Theme.alpha(Theme.primary, 0.18)

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 8

        Txt {
            text: Qt.formatDateTime(clock.date, "HH:mm")
            font.pixelSize: Theme.font.medium
            font.weight: Font.Bold
            font.features: ({ "tnum": 1 })
        }
        Rectangle {
            visible: !root.compact
            implicitWidth: 4
            implicitHeight: 4
            radius: 2
            color: Theme.alpha(Theme.surfaceVariantFg, 0.6)
        }
        Txt {
            visible: !root.compact
            text: clock.date.toLocaleDateString(Qt.locale(), "ddd d MMM").replace(/\./g, "")
            dim: true
            font.pixelSize: Theme.font.normal
            font.weight: Font.Medium
        }
    }
}
