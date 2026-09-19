//@ pragma UseQApplication
// Rice do Hyprland em Quickshell — ponto de entrada.  Rodar: qs -c rice
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.services
import qs.bar
import qs.panels
import qs.notifications
import qs.osd
import qs.wallpaper

ShellRoot {
    // Uma barra + um host de painéis por monitor
    Variants {
        model: Quickshell.screens
        delegate: Scope {
            id: scope
            required property ShellScreen modelData
            Bar {
                id: bar
                modelData: scope.modelData
            }
            PanelHost {
                modelData: scope.modelData
                barWindow: bar
            }
        }
    }

    NotificationPopups {}
    Osd {}
    WallpaperPicker {}

    // ── Atalhos globais (binds em ~/.config/hypr/rice/rice.conf: "global, quickshell:<nome>")
    GlobalShortcut {
        name: "wallpaper"
        description: "Seletor de wallpapers"
        onPressed: Ui.togglePicker()
    }
    GlobalShortcut {
        name: "notifications"
        description: "Central de notificações"
        onPressed: Ui.toggle("notifications", "", -1)
    }
    GlobalShortcut {
        name: "control"
        description: "Central de controle"
        onPressed: Ui.toggle("control", "", -1)
    }
    GlobalShortcut {
        name: "power"
        description: "Menu de energia"
        onPressed: Ui.toggle("power", "", -1)
    }

    // ── IPC:  qs -c rice ipc call rice <função> [args]
    IpcHandler {
        target: "rice"

        function toggle(panel: string): void {
            Ui.toggle(panel, "", -1);
        }
        function open(panel: string): void {
            Ui.open(panel, "", -1);
        }
        function close(): void {
            Ui.close();
            Ui.pickerOpen = false;
        }
        function picker(): void {
            Ui.togglePicker();
        }
        function dnd(): void {
            Notifs.dnd = !Notifs.dnd;
        }
        function clearNotifications(): void {
            Notifs.clearAll();
        }
        function notifications(): string {
            return JSON.stringify(Notifs.list.map(n => ({
                        app: n.appName,
                        summary: n.summary,
                        popup: Notifs.popups.includes(n)
                    })));
        }
        function status(): string {
            return JSON.stringify({
                panel: Ui.panel,
                panelScreen: Ui.panelScreen,
                picker: Ui.pickerOpen,
                dnd: Notifs.dnd,
                notifications: Notifs.count,
                popups: Notifs.popups.length,
                vdeskMode: Desktops.vdeskMode,
                wifi: Net.ssid,
                wifiEnabled: Net.wifiEnabled,
                networks: Net.networks.length,
                bluetooth: Bt.enabled,
                btDevices: Bt.devices.length,
                volume: Math.round(Audio.volume * 100),
                muted: Audio.muted,
                sinks: Audio.sinks.length,
                streams: Audio.streams.length,
                battery: Math.round(Sys.batteryPct * 100),
                cpu: Math.round(Sys.cpu * 100),
                themeMode: Theme.mode,
                primary: String(Theme.primary),
                wallpaper: Wallpapers.current,
                wallpapers: Wallpapers.items.length
            });
        }
    }
}
