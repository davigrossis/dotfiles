import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.widgets

// Barra superior de um monitor: fundo unico com grupos alinhados.
PanelWindow {
    id: bar

    required property ShellScreen modelData
    readonly property string screenName: modelData.name
    readonly property bool compact: modelData.width < 1600

    screen: modelData
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Theme.barHeight
    exclusiveZone: Ui.barVisible ? Theme.barHeight : 0
    color: "transparent"
    WlrLayershell.namespace: "rice-bar"
    WlrLayershell.layer: WlrLayer.Top

    // "Cafeína": inibe o hypridle (bloqueio/suspensão por ociosidade) enquanto ligado
    IdleInhibitor {
        window: bar
        enabled: Ui.caffeine && Quickshell.screens.length > 0 && bar.screenName === Quickshell.screens[0].name
    }

    // abre/fecha um painel ancorado no centro do item clicado
    function openPanel(name: string, item: Item): void {
        const p = item.mapToItem(null, item.width / 2, 0);
        Ui.toggle(name, bar.screenName, p.x);
    }
    function isOpen(name: string): bool {
        return Ui.panel === name && Ui.panelScreen === bar.screenName;
    }

    component BarGroup: Item {
        default property alias content: row.data
        property real hpad: 5

        implicitWidth: row.implicitWidth + hpad * 2
        implicitHeight: Theme.barHeight

        RowLayout {
            id: row
            anchors.verticalCenter: parent.verticalCenter
            x: parent.hpad
            spacing: 2
        }
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: Ui.barVisible ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: Theme.anim.normal }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: Theme.barHeight
            radius: 0
            color: Theme.barBg
            border.width: 1
            border.color: Theme.alpha(Theme.outlineVariant, 0.45)
        }

        // ── Esquerda: launcher + workspaces ──────────────────────────────────────
        BarGroup {
            id: left
            anchors.left: parent.left
            anchors.top: parent.top

            BarButton {
                id: launcher
                icon: ""
                label: ""
                implicitWidth: implicitHeight + 4
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton)
                        Ui.togglePicker();
                    else
                        Quickshell.execDetached(["sh", "-c", "rofi -show drun"]);
                }
                Txt {
                    anchors.centerIn: parent
                    text: ""
                    mono: true
                    font.pixelSize: 17
                    color: Theme.primary
                }
            }
            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 16
                color: Theme.alpha(Theme.outlineVariant, 0.8)
            }
            Workspaces {
                screenName: bar.screenName
            }
        }

        // ── Centro: relógio + mídia ─────────────────────────────────────────────
        BarGroup {
            id: center
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top

            Clock {
                id: clock
                compact: bar.compact && Media.active
                active: bar.isOpen("calendar")
                onClicked: bar.openPanel("calendar", clock)
            }
            MediaChip {
                id: media
                maxTextWidth: bar.compact ? 120 : 220
                active: bar.isOpen("media")
                onClicked: mouse => {
                    if (mouse.button === Qt.MiddleButton)
                        Media.togglePlaying();
                    else
                        bar.openPanel("media", media);
                }
            }
        }

        // ── Direita: stats e status ─────────────────────────────────────────────
        BarGroup {
            id: right
            anchors.right: parent.right
            anchors.top: parent.top

            SysStats {
                id: stats
                compact: bar.compact
                active: bar.isOpen("system")
                onClicked: bar.openPanel("system", stats)
            }
            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 16
                color: Theme.alpha(Theme.outlineVariant, 0.8)
            }

            BarButton {
                id: wifiBtn
                icon: Net.icon
                iconFill: 1
                active: bar.isOpen("wifi")
                onClicked: bar.openPanel("wifi", wifiBtn)
            }
            BarButton {
                id: btBtn
                visible: Bt.available
                icon: Bt.icon
                iconFill: Bt.connected.length > 0 ? 1 : 0
                active: bar.isOpen("bluetooth")
                onClicked: bar.openPanel("bluetooth", btBtn)
            }
            BarButton {
                id: volBtn
                icon: Audio.icon
                iconFill: 1
                label: bar.compact ? "" : Math.round(Audio.volume * 100) + "%"
                labelColor: Audio.muted ? Theme.surfaceVariantFg : Theme.surfaceFg
                active: bar.isOpen("audio")
                onClicked: mouse => {
                    if (mouse.button === Qt.MiddleButton)
                        Audio.toggleMute();
                    else
                        bar.openPanel("audio", volBtn);
                }
                onWheel: wheel => {
                    const d = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : -wheel.angleDelta.x;
                    Audio.changeVolume(d > 0 ? 0.05 : -0.05);
                }
            }
            BarButton {
                id: batBtn
                visible: Sys.hasBattery
                icon: Sys.batteryIcon
                iconFill: 1
                iconColor: !Sys.charging && Sys.batteryPct <= 0.15 ? Theme.error : Sys.charging ? Theme.green : Theme.surfaceFg
                label: Math.round(Sys.batteryPct * 100) + "%"
                active: bar.isOpen("system")
                onClicked: bar.openPanel("system", batBtn)
            }
            BarButton {
                id: ccBtn
                icon: "tune"
                active: bar.isOpen("control")
                onClicked: bar.openPanel("control", ccBtn)
            }
            BarButton {
                id: notifBtn
                icon: Notifs.dnd ? "notifications_off" : Notifs.unread > 0 ? "notifications_unread" : "notifications"
                iconFill: Notifs.unread > 0 ? 1 : 0
                badge: Notifs.unread > 0 && !Notifs.dnd
                active: bar.isOpen("notifications")
                onClicked: mouse => {
                    if (mouse.button === Qt.MiddleButton)
                        Notifs.dnd = !Notifs.dnd;
                    else
                        bar.openPanel("notifications", notifBtn);
                }
            }
            BarButton {
                id: powerBtn
                icon: "power_settings_new"
                iconColor: bar.isOpen("power") ? Theme.primary : Theme.error
                active: bar.isOpen("power")
                onClicked: bar.openPanel("power", powerBtn)
            }
        }
    }
}
