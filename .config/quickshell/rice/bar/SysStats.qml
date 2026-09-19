import QtQuick
import QtQuick.Layouts
import qs.services
import qs.widgets

// CPU / RAM / temperatura compactos. Clique abre o painel do sistema.
StateLayer {
    id: root

    property bool compact: false

    implicitHeight: Theme.barHeight - 8
    implicitWidth: row.implicitWidth + 16
    radius: Theme.radius.normal
    activeColor: Theme.alpha(Theme.primary, 0.18)

    component Stat: RowLayout {
        property string icon
        property string value
        property color tint: Theme.surfaceFg
        spacing: 3
        MIcon {
            icon: parent.icon
            size: 16
            color: parent.tint
        }
        Txt {
            text: parent.value
            mono: true
            font.pixelSize: Theme.font.small + 1
            font.weight: Font.DemiBold
            color: parent.tint
        }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 10

        Stat {
            icon: "memory"
            value: Math.round(Sys.cpu * 100) + "%"
            tint: Sys.cpu > 0.85 ? Theme.error : Theme.surfaceFg
        }
        Stat {
            icon: "memory_alt"
            value: Math.round(Sys.mem * 100) + "%"
            tint: Sys.mem > 0.9 ? Theme.error : Theme.surfaceFg
        }
        Stat {
            visible: !root.compact && Sys.temp > 0
            icon: "thermostat"
            value: Math.round(Sys.temp) + "°"
            tint: Sys.temp > 85 ? Theme.error : Sys.temp > 72 ? Theme.yellow : Theme.surfaceFg
        }
    }
}
