import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.widgets

// Painel de Wi-Fi (NetworkManager): liga/desliga o rádio, lista redes com sinal,
// conecta (pede senha para redes novas), desconecta e esquece redes salvas.
PanelBase {
    id: root

    property string expanded: ""

    panelWidth: 384
    Component.onCompleted: Net.setScanning(true)
    Component.onDestruction: Net.setScanning(false)

    PanelHeader {
        icon: Net.wifiEnabled ? "wifi" : "wifi_off"
        title: "Wi-Fi"
        subtitle: Net.statusText
        RSwitch {
            checked: Net.wifiEnabled
            onToggled: v => Net.setWifiEnabled(v)
        }
    }

    ColumnLayout {
        visible: !Net.wifiEnabled
        Layout.fillWidth: true
        Layout.topMargin: 16
        Layout.bottomMargin: 16
        spacing: 6
        MIcon {
            Layout.alignment: Qt.AlignHCenter
            icon: "wifi_off"
            size: 42
            color: Theme.surfaceVariantFg
        }
        Txt {
            Layout.alignment: Qt.AlignHCenter
            text: Net.wifiHardwareEnabled ? "O Wi-Fi está desligado" : "Wi-Fi bloqueado pelo hardware"
            dim: true
        }
    }

    // rede atual
    Card {
        visible: Net.wifiEnabled && Net.active !== null
        Layout.fillWidth: true
        padding: 10

        RowLayout {
            width: parent.width
            spacing: 10
            Rectangle {
                Layout.preferredWidth: 38
                Layout.preferredHeight: 38
                radius: 19
                color: Theme.primary
                MIcon {
                    anchors.centerIn: parent
                    icon: Net.strengthIcon(Net.strength)
                    fill: 1
                    size: 20
                    color: Theme.primaryFg
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                Txt {
                    Layout.fillWidth: true
                    text: Net.ssid
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }
                Txt {
                    Layout.fillWidth: true
                    text: "Conectado · " + Net.securityText(Net.active) + " · " + Math.round(Net.strength * 100) + "%"
                    dim: true
                    font.pixelSize: Theme.font.small
                    elide: Text.ElideRight
                }
            }
            PillButton {
                compact: true
                variant: "outline"
                text: "Desconectar"
                onClicked: Net.disconnectFrom(Net.active)
            }
        }
    }

    RowLayout {
        visible: Net.wifiEnabled
        Layout.fillWidth: true
        SectionTitle {
            text: "Redes disponíveis"
        }
        MIcon {
            icon: "refresh"
            size: 16
            color: Theme.surfaceVariantFg
            RotationAnimation on rotation {
                running: Net.scanning && root.visible
                from: 0
                to: 360
                duration: 1400
                loops: Animation.Infinite
            }
        }
    }

    ListView {
        id: list
        visible: Net.wifiEnabled
        Layout.fillWidth: true
        Layout.preferredHeight: Math.max(40, Math.min(contentHeight, 440, root.maxHeight - 250))
        clip: true
        spacing: 2
        boundsBehavior: Flickable.StopAtBounds
        model: ScriptModel {
            values: Net.sortedNetworks.filter(n => !n.connected)
        }

        delegate: ColumnLayout {
            id: entry
            required property var modelData
            width: list.width
            spacing: 4

            function submit(): void {
                if (pw.text.length > 0) {
                    Net.connectWithPassword(entry.modelData, pw.text);
                    root.expanded = "";
                }
            }

            ListRow {
                Layout.fillWidth: true
                icon: Net.strengthIcon(entry.modelData.signalStrength)
                iconFill: 1
                title: entry.modelData.name
                subtitle: entry.modelData.stateChanging ? "Conectando…" : (entry.modelData.known ? "Salva · " : "") + Net.securityText(entry.modelData) + " · " + Math.round(entry.modelData.signalStrength * 100) + "%"
                onClicked: {
                    if (entry.modelData.known || !Net.isSecure(entry.modelData))
                        Net.connectTo(entry.modelData);
                    else
                        root.expanded = root.expanded === entry.modelData.name ? "" : entry.modelData.name;
                }

                MIcon {
                    visible: Net.isSecure(entry.modelData)
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "lock"
                    size: 15
                    color: Theme.surfaceVariantFg
                }
                IconButton {
                    visible: entry.modelData.known
                    implicitWidth: 28
                    implicitHeight: 28
                    icon: "delete"
                    iconSize: 16
                    onClicked: Net.forget(entry.modelData)
                }
            }

            RowLayout {
                visible: root.expanded === entry.modelData.name
                Layout.fillWidth: true
                Layout.leftMargin: 8
                Layout.rightMargin: 4
                Layout.bottomMargin: 6
                spacing: 6
                onVisibleChanged: if (visible) pw.focusInput()

                RTextField {
                    id: pw
                    Layout.fillWidth: true
                    password: true
                    placeholder: "Senha da rede"
                    onAccepted: entry.submit()
                }
                PillButton {
                    variant: "filled"
                    compact: true
                    text: "Conectar"
                    onClicked: entry.submit()
                }
            }

            Txt {
                visible: Net.lastError !== "" && Net.lastErrorNetwork === entry.modelData.name
                Layout.leftMargin: 44
                text: Net.lastError
                color: Theme.error
                font.pixelSize: Theme.font.small
            }
        }
    }

    Txt {
        visible: Net.wifiEnabled && list.count === 0
        Layout.alignment: Qt.AlignHCenter
        text: Net.scanning ? "Procurando redes…" : "Nenhuma outra rede encontrada"
        dim: true
        font.pixelSize: Theme.font.small
    }

    PillButton {
        Layout.alignment: Qt.AlignRight
        compact: true
        variant: "outline"
        icon: "settings"
        text: "Configurações de rede"
        onClicked: {
            Ui.close();
            Quickshell.execDetached(["nm-connection-editor"]);
        }
    }
}
