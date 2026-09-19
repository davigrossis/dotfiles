import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs.services
import qs.widgets

// Sistema: CPU/RAM/temperatura, bateria, perfil de energia e baterias de periféricos.
PanelBase {
    id: root

    panelWidth: 384
    Component.onCompleted: Sys.consumers++
    Component.onDestruction: Sys.consumers--

    PanelHeader {
        icon: "monitor_heart"
        title: "Sistema"
        subtitle: "Ligado há " + Sys.uptime
        PillButton {
            compact: true
            variant: "outline"
            icon: "open_in_new"
            text: "btop"
            onClicked: {
                Ui.close();
                Quickshell.execDetached(["kitty", "--class", "rice-btop", "-e", "btop"]);
            }
        }
    }

    Card {
        Layout.fillWidth: true
        RowLayout {
            width: parent.width
            Gauge {
                Layout.alignment: Qt.AlignHCenter
                value: Sys.cpu
                label: "CPU"
                icon: "memory"
                accent: Sys.cpu > 0.85 ? Theme.error : Theme.primary
            }
            Gauge {
                Layout.alignment: Qt.AlignHCenter
                value: Sys.mem
                label: "RAM"
                icon: "memory_alt"
                accent: Sys.mem > 0.9 ? Theme.error : Theme.secondary
            }
            Gauge {
                Layout.alignment: Qt.AlignHCenter
                value: Sys.temp / 100
                valueText: Math.round(Sys.temp) + "°C"
                label: "Temp."
                icon: "thermostat"
                accent: Sys.temp > 85 ? Theme.error : Sys.temp > 72 ? Theme.yellow : Theme.tertiary
            }
        }
    }

    Card {
        Layout.fillWidth: true
        padding: 10
        GridLayout {
            width: parent.width
            columns: 2
            columnSpacing: 12
            rowSpacing: 4
            Txt {
                text: "Memória"
                dim: true
            }
            Txt {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                text: Sys.memUsedGiB.toFixed(1) + " / " + Sys.memTotalGiB.toFixed(1) + " GiB"
                mono: true
                font.pixelSize: Theme.font.small + 1
            }
            Txt {
                visible: Sys.swapTotalGiB > 0
                text: "Swap"
                dim: true
            }
            Txt {
                visible: Sys.swapTotalGiB > 0
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                text: Sys.swapUsedGiB.toFixed(1) + " / " + Sys.swapTotalGiB.toFixed(1) + " GiB"
                mono: true
                font.pixelSize: Theme.font.small + 1
            }
        }
    }

    // ── Bateria + perfil de energia ────────────────────────────────────────────
    Card {
        Layout.fillWidth: true
        ColumnLayout {
            width: parent.width
            spacing: 10
            RowLayout {
                visible: Sys.hasBattery
                Layout.fillWidth: true
                spacing: 10
                MIcon {
                    icon: Sys.batteryIcon
                    size: 28
                    fill: 1
                    color: Sys.charging ? Theme.green : (!Sys.pluggedIdle && Sys.batteryPct <= 0.15) ? Theme.error : Theme.primary
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Txt {
                        text: "Bateria · " + Math.round(Sys.batteryPct * 100) + "%"
                        font.weight: Font.DemiBold
                    }
                    Txt {
                        Layout.fillWidth: true
                        text: Sys.batteryText + (Sys.battery && Sys.battery.healthSupported ? " · saúde " + Math.round(Sys.battery.healthPercentage) + "%" : "")
                        dim: true
                        font.pixelSize: Theme.font.small
                        elide: Text.ElideRight
                    }
                }
            }
            Txt {
                text: "Perfil de energia"
                font.weight: Font.DemiBold
            }
            Segmented {
                Layout.fillWidth: true
                current: PowerProfiles.profile === PowerProfile.PowerSaver ? "saver" : PowerProfiles.profile === PowerProfile.Performance ? "perf" : "balanced"
                model: PowerProfiles.hasPerformanceProfile ? [
                    { key: "saver", label: "Economia", icon: "eco" },
                    { key: "balanced", label: "Equilibrado", icon: "balance" },
                    { key: "perf", label: "Desempenho", icon: "speed" }
                ] : [
                    { key: "saver", label: "Economia", icon: "eco" },
                    { key: "balanced", label: "Equilibrado", icon: "balance" }
                ]
                onSelected: key => PowerProfiles.profile = key === "saver" ? PowerProfile.PowerSaver : key === "perf" ? PowerProfile.Performance : PowerProfile.Balanced
            }
        }
    }

    // ── Periféricos ────────────────────────────────────────────────────────────
    Card {
        visible: Sys.peripherals.length > 0
        Layout.fillWidth: true
        padding: 10
        ColumnLayout {
            width: parent.width
            spacing: 6
            SectionTitle {
                text: "Dispositivos"
                Layout.topMargin: 0
            }
            Repeater {
                model: Sys.peripherals
                delegate: RowLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 10
                    MIcon {
                        icon: modelData.type === UPowerDeviceType.Mouse ? "mouse" : modelData.type === UPowerDeviceType.Keyboard ? "keyboard" : (modelData.type === UPowerDeviceType.Headset || modelData.type === UPowerDeviceType.Headphones) ? "headphones" : "devices_other"
                        size: 20
                        color: Theme.surfaceVariantFg
                    }
                    Txt {
                        Layout.fillWidth: true
                        text: modelData.model || "Dispositivo"
                        elide: Text.ElideRight
                    }
                    Txt {
                        text: Math.round(modelData.percentage * 100) + "%"
                        mono: true
                        font.weight: Font.DemiBold
                        color: modelData.percentage <= 0.15 ? Theme.error : Theme.surfaceFg
                    }
                }
            }
        }
    }
}
