import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.services

// Janela (layer "rice-panel") que exibe o painel aberto neste monitor, logo abaixo do
// botão da barra que o abriu. Fecha com clique fora (HyprlandFocusGrab) ou Esc.
PanelWindow {
    id: host

    required property ShellScreen modelData
    required property var barWindow
    readonly property string screenName: modelData.name
    readonly property bool wanted: Ui.panel !== "" && Ui.panelScreen === screenName
    property string current: ""
    property bool shown: false
    readonly property real maxPanelHeight: modelData.height - (Theme.barHeight + Theme.barMargin + 18)

    screen: modelData
    anchors {
        top: true
        left: true
    }
    margins {
        top: Theme.barHeight + Theme.barMargin + 6
        left: xPos
    }
    implicitWidth: Math.max(1, frame.implicitWidth)
    implicitHeight: Math.max(1, frame.implicitHeight)
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: shown || frame.opacity > 0.01
    WlrLayershell.namespace: "rice-panel"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    function sync(): void {
        if (host.wanted) {
            host.current = Ui.panel;
            host.shown = true;
        } else {
            host.shown = false;
        }
    }
    onWantedChanged: sync()
    Connections {
        target: Ui
        function onPanelChanged() {
            host.sync();
        }
    }

    readonly property int xPos: {
        const w = implicitWidth;
        let cx = Ui.panelAnchorX;
        if (cx < 0)
            cx = (current === "calendar" || current === "media") ? modelData.width / 2 : modelData.width - 190;
        return Math.round(Math.max(Theme.barMargin + 2, Math.min(modelData.width - w - Theme.barMargin - 2, cx - w / 2)));
    }

    HyprlandFocusGrab {
        active: host.shown
        windows: [host, host.barWindow]
        onCleared: Ui.close()
    }

    Item {
        id: frame
        implicitWidth: loader.item ? loader.item.implicitWidth : 0
        implicitHeight: loader.item ? loader.item.implicitHeight : 0
        width: parent.width
        height: parent.height
        opacity: host.shown ? 1 : 0
        property real dy: host.shown ? 0 : -12
        property real sc: host.shown ? 1 : 0.97
        transform: [
            Scale {
                origin.x: frame.width / 2
                origin.y: 0
                xScale: frame.sc
                yScale: frame.sc
            },
            Translate {
                y: frame.dy
            }
        ]
        Behavior on opacity {
            NumberAnimation { duration: host.shown ? 170 : 120; easing.type: Easing.OutCubic }
        }
        Behavior on dy {
            NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
        }
        Behavior on sc {
            NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
        }

        Rectangle {
            anchors.fill: parent
            radius: Theme.radius.panel
            color: Theme.panelBg
            border.width: 1
            border.color: Theme.borderColor
        }

        Loader {
            id: loader
            anchors.fill: parent
            focus: true
            active: host.current !== ""
            Keys.onEscapePressed: Ui.close()
            sourceComponent: {
                switch (host.current) {
                case "control":
                    return controlComp;
                case "wifi":
                    return wifiComp;
                case "bluetooth":
                    return btComp;
                case "audio":
                    return audioComp;
                case "notifications":
                    return notifComp;
                case "calendar":
                    return calendarComp;
                case "power":
                    return powerComp;
                case "system":
                    return systemComp;
                case "media":
                    return mediaComp;
                default:
                    return null;
                }
            }
            onLoaded: item.forceActiveFocus()
        }
    }

    Component {
        id: controlComp
        ControlCenter {
            maxHeight: host.maxPanelHeight
            screenName: host.screenName
        }
    }
    Component {
        id: wifiComp
        WifiPanel {
            maxHeight: host.maxPanelHeight
        }
    }
    Component {
        id: btComp
        BluetoothPanel {
            maxHeight: host.maxPanelHeight
        }
    }
    Component {
        id: audioComp
        AudioPanel {
            maxHeight: host.maxPanelHeight
        }
    }
    Component {
        id: notifComp
        NotificationCenter {
            maxHeight: host.maxPanelHeight
        }
    }
    Component {
        id: calendarComp
        CalendarPanel {
            maxHeight: host.maxPanelHeight
        }
    }
    Component {
        id: powerComp
        PowerMenu {
            maxHeight: host.maxPanelHeight
        }
    }
    Component {
        id: systemComp
        SystemPanel {
            maxHeight: host.maxPanelHeight
        }
    }
    Component {
        id: mediaComp
        MediaPanel {
            maxHeight: host.maxPanelHeight
        }
    }
}
