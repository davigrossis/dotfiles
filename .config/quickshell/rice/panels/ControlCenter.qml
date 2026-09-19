import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs.services
import qs.widgets

// Central de controle: atalhos rápidos, sliders, mídia e aparência.
PanelBase {
    id: root

    property string screenName: ""
    panelWidth: 404

    function go(panel: string): void {
        Ui.open(panel, root.screenName, Ui.panelAnchorX);
    }

    // ── Cabeçalho ───────────────────────────────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 20
            color: Theme.primaryContainer
            Txt {
                anchors.centerIn: parent
                text: (Quickshell.env("USER") || "?").charAt(0).toUpperCase()
                font.pixelSize: Theme.font.large
                font.weight: Font.Bold
                color: Theme.primaryContainerFg
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Txt {
                text: Quickshell.env("USER") || ""
                font.pixelSize: Theme.font.medium
                font.weight: Font.Bold
            }
            Txt {
                text: "Ligado há " + Sys.uptime
                dim: true
                font.pixelSize: Theme.font.small
            }
        }
        IconButton {
            icon: "wallpaper"
            onClicked: Ui.togglePicker()
        }
        IconButton {
            icon: "lock"
            onClicked: {
                Ui.close();
                Quickshell.execDetached(["hyprlock"]);
            }
        }
        IconButton {
            icon: "power_settings_new"
            iconColor: Theme.error
            onClicked: root.go("power")
        }
    }

    // ── Atalhos ─────────────────────────────────────────────────────────────────
    GridLayout {
        Layout.fillWidth: true
        columns: 2
        columnSpacing: 8
        rowSpacing: 8

        QuickToggle {
            Layout.fillWidth: true
            icon: Net.icon
            title: "Wi-Fi"
            subtitle: Net.statusText
            checked: Net.wifiEnabled
            hasDetails: true
            onToggled: Net.setWifiEnabled(!Net.wifiEnabled)
            onDetailsRequested: root.go("wifi")
        }
        QuickToggle {
            Layout.fillWidth: true
            icon: Bt.icon
            title: "Bluetooth"
            subtitle: Bt.statusText
            checked: Bt.enabled
            hasDetails: true
            onToggled: Bt.setEnabled(!Bt.enabled)
            onDetailsRequested: root.go("bluetooth")
        }
        QuickToggle {
            Layout.fillWidth: true
            icon: Notifs.dnd ? "do_not_disturb_on" : "notifications"
            title: "Não perturbe"
            subtitle: Notifs.dnd ? "Ativado" : "Desativado"
            checked: Notifs.dnd
            hasDetails: true
            onToggled: Notifs.dnd = !Notifs.dnd
            onDetailsRequested: root.go("notifications")
        }
        QuickToggle {
            Layout.fillWidth: true
            icon: Audio.micIcon
            title: "Microfone"
            subtitle: Audio.micMuted ? "Mudo" : "Ativo"
            checked: !Audio.micMuted
            hasDetails: true
            onToggled: Audio.toggleMicMute()
            onDetailsRequested: root.go("audio")
        }
        QuickToggle {
            Layout.fillWidth: true
            icon: "nightlight"
            title: "Luz noturna"
            subtitle: Prefs.nightLight ? Prefs.nightTemp + " K" : "Desligada"
            checked: Prefs.nightLight
            onToggled: Prefs.toggleNightLight()
        }
        QuickToggle {
            Layout.fillWidth: true
            icon: "coffee"
            title: "Cafeína"
            subtitle: Ui.caffeine ? "Tela sempre ligada" : "Desligada"
            checked: Ui.caffeine
            onToggled: Ui.caffeine = !Ui.caffeine
        }
        QuickToggle {
            Layout.fillWidth: true
            readonly property int prof: PowerProfiles.profile
            icon: prof === PowerProfile.PowerSaver ? "eco" : prof === PowerProfile.Performance ? "speed" : "balance"
            title: "Energia"
            subtitle: prof === PowerProfile.PowerSaver ? "Economia" : prof === PowerProfile.Performance ? "Desempenho" : "Equilibrado"
            checked: prof !== PowerProfile.Balanced
            hasDetails: true
            onToggled: {
                if (prof === PowerProfile.PowerSaver)
                    PowerProfiles.profile = PowerProfile.Balanced;
                else if (prof === PowerProfile.Balanced && PowerProfiles.hasPerformanceProfile)
                    PowerProfiles.profile = PowerProfile.Performance;
                else
                    PowerProfiles.profile = PowerProfile.PowerSaver;
            }
            onDetailsRequested: root.go("system")
        }
        QuickToggle {
            Layout.fillWidth: true
            icon: Prefs.mode === "dark" ? "dark_mode" : "light_mode"
            title: "Modo escuro"
            subtitle: Prefs.mode === "dark" ? "Ativado" : "Desativado"
            checked: Prefs.mode === "dark"
            onToggled: Prefs.setTheme(Prefs.mode === "dark" ? "light" : "dark", Prefs.scheme)
        }
    }

    // ── Sliders ─────────────────────────────────────────────────────────────────
    Card {
        Layout.fillWidth: true

        ColumnLayout {
            width: parent.width
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                Txt {
                    text: "Volume"
                    font.weight: Font.DemiBold
                }
                Txt {
                    Layout.fillWidth: true
                    text: Audio.nodeName(Audio.sink)
                    dim: true
                    font.pixelSize: Theme.font.small
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignRight
                }
                IconButton {
                    implicitWidth: 26
                    implicitHeight: 26
                    icon: "chevron_right"
                    iconSize: 18
                    onClicked: root.go("audio")
                }
            }
            RSlider {
                Layout.fillWidth: true
                icon: Audio.icon
                value: Audio.volume
                muted: Audio.muted
                onMoved: v => Audio.setVolume(v)
                onIconClicked: Audio.toggleMute()
            }
            RSlider {
                Layout.fillWidth: true
                icon: Audio.micIcon
                value: Audio.micVolume
                muted: Audio.micMuted
                onMoved: v => Audio.setMicVolume(v)
                onIconClicked: Audio.toggleMicMute()
            }
            Txt {
                visible: Brightness.available
                text: "Brilho da tela"
                font.weight: Font.DemiBold
                Layout.topMargin: 2
            }
            RSlider {
                visible: Brightness.available
                Layout.fillWidth: true
                icon: "light_mode"
                value: Brightness.value
                from: 0.01
                onMoved: v => Brightness.set(v)
            }
        }
    }

    // ── Mídia ───────────────────────────────────────────────────────────────────
    MediaCard {
        visible: Media.active
        Layout.fillWidth: true
        compact: true
    }

    // ── Aparência ───────────────────────────────────────────────────────────────
    Card {
        Layout.fillWidth: true

        ColumnLayout {
            width: parent.width
            spacing: 8
            RowLayout {
                Layout.fillWidth: true
                MIcon {
                    icon: "palette"
                    size: 18
                    color: Theme.primary
                    fill: 1
                }
                Txt {
                    Layout.fillWidth: true
                    text: "Cores do wallpaper"
                    font.weight: Font.DemiBold
                }
                PillButton {
                    compact: true
                    icon: "wallpaper"
                    text: "Trocar"
                    onClicked: Ui.togglePicker()
                }
            }
            Segmented {
                Layout.fillWidth: true
                model: Prefs.schemes
                current: Prefs.scheme
                onSelected: key => Prefs.setTheme(Prefs.mode, key)
            }
        }
    }
}
