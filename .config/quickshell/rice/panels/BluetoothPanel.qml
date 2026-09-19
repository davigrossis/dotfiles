import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.widgets

// Painel de Bluetooth (BlueZ): liga/desliga, pareados (conectar/desconectar/esquecer)
// e busca de dispositivos próximos (parear + conectar).
PanelBase {
    id: root

    panelWidth: 384
    Component.onDestruction: Bt.setDiscovering(false)

    PanelHeader {
        icon: Bt.icon
        title: "Bluetooth"
        subtitle: Bt.statusText
        RSwitch {
            visible: Bt.available
            checked: Bt.enabled
            onToggled: v => Bt.setEnabled(v)
        }
    }

    ColumnLayout {
        visible: !Bt.enabled
        Layout.fillWidth: true
        Layout.topMargin: 16
        Layout.bottomMargin: 16
        spacing: 6
        MIcon {
            Layout.alignment: Qt.AlignHCenter
            icon: "bluetooth_disabled"
            size: 42
            color: Theme.surfaceVariantFg
        }
        Txt {
            Layout.alignment: Qt.AlignHCenter
            text: Bt.available ? "O Bluetooth está desligado" : "Nenhum adaptador Bluetooth"
            dim: true
        }
    }

    component DeviceRow: ListRow {
        id: row
        required property var modelData
        Layout.fillWidth: true
        icon: Bt.deviceIcon(modelData)
        iconFill: modelData.connected ? 1 : 0
        title: Bt.deviceName(modelData)
        subtitle: Bt.stateText(modelData)
        highlighted: modelData.connected
        onClicked: Bt.activate(modelData)
    }

    SectionTitle {
        visible: Bt.enabled && Bt.paired.length > 0
        text: "Meus dispositivos"
    }

    Repeater {
        model: Bt.enabled ? Bt.paired : []
        delegate: DeviceRow {
            id: pairedRow
            PillButton {
                anchors.verticalCenter: parent.verticalCenter
                compact: true
                variant: pairedRow.modelData.connected ? "outline" : "tonal"
                text: pairedRow.modelData.connected ? "Desconectar" : "Conectar"
                onClicked: Bt.activate(pairedRow.modelData)
            }
            IconButton {
                implicitWidth: 28
                implicitHeight: 28
                icon: "delete"
                iconSize: 16
                onClicked: Bt.forget(pairedRow.modelData)
            }
        }
    }

    RowLayout {
        visible: Bt.enabled
        Layout.fillWidth: true
        SectionTitle {
            text: "Dispositivos próximos"
        }
        PillButton {
            compact: true
            variant: Bt.discovering ? "filled" : "tonal"
            icon: Bt.discovering ? "bluetooth_searching" : "search"
            text: Bt.discovering ? "Parar" : "Procurar"
            onClicked: Bt.setDiscovering(!Bt.discovering)
        }
    }

    ListView {
        id: nearby
        visible: Bt.enabled
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(contentHeight, Math.max(60, root.maxHeight - 260 - Bt.paired.length * 52))
        clip: true
        spacing: 2
        boundsBehavior: Flickable.StopAtBounds
        model: ScriptModel {
            values: Bt.enabled ? Bt.discovered : []
        }
        delegate: DeviceRow {
            width: nearby.width
            MIcon {
                anchors.verticalCenter: parent.verticalCenter
                icon: "add"
                size: 18
                color: Theme.primary
            }
        }
    }

    Txt {
        visible: Bt.enabled && nearby.count === 0
        Layout.alignment: Qt.AlignHCenter
        text: Bt.discovering ? "Procurando dispositivos…" : "Clique em Procurar para parear algo novo"
        dim: true
        font.pixelSize: Theme.font.small
    }
}
