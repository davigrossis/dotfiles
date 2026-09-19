import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.widgets

// OSD de volume/brilho (teclas XF86, rolagem na barra, wpctl...). Não intercepta cliques.
Scope {
    id: root

    property string kind: "volume"
    property bool shown: false
    property bool armed: false

    function show(k: string): void {
        if (!root.armed)
            return;
        // com o painel de som/central aberto o slider já está visível
        if (Ui.panel === "audio" || Ui.panel === "control")
            return;
        root.kind = k;
        root.shown = true;
        hideTimer.restart();
    }

    Timer {
        interval: 3000
        running: true
        onTriggered: root.armed = true
    }
    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.shown = false
    }

    Connections {
        target: Audio.sink ? Audio.sink.audio : null
        function onVolumesChanged() {
            root.show("volume");
        }
        function onMutedChanged() {
            root.show("volume");
        }
    }
    Connections {
        target: Audio.source ? Audio.source.audio : null
        function onMutedChanged() {
            root.show("mic");
        }
    }
    Connections {
        target: Brightness
        function onChangedExternally() {
            root.show("brightness");
        }
    }

    PanelWindow {
        id: win

        screen: {
            const name = Ui.focusedScreen();
            return Quickshell.screens.find(s => s.name === name) ?? Quickshell.screens[0];
        }
        anchors.bottom: true
        margins.bottom: 72
        implicitWidth: 320
        implicitHeight: 56
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        visible: root.shown || card.opacity > 0.01
        mask: Region {}
        WlrLayershell.namespace: "rice-osd"
        WlrLayershell.layer: WlrLayer.Overlay

        readonly property real level: root.kind === "brightness" ? Brightness.value : root.kind === "mic" ? Audio.micVolume : Audio.volume
        readonly property bool isMuted: root.kind === "volume" ? Audio.muted : root.kind === "mic" ? Audio.micMuted : false
        readonly property string icon: root.kind === "brightness" ? "light_mode" : root.kind === "mic" ? Audio.micIcon : Audio.icon

        Rectangle {
            id: card
            anchors.fill: parent
            radius: height / 2
            color: Theme.alpha(Theme.surfaceContainer, 0.92)
            border.width: 1
            border.color: Theme.borderColor
            opacity: root.shown ? 1 : 0
            scale: root.shown ? 1 : 0.92
            Behavior on opacity {
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }
            Behavior on scale {
                NumberAnimation { duration: 220; easing.type: Easing.OutBack }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 20
                spacing: 14

                MIcon {
                    icon: win.icon
                    size: 22
                    fill: 1
                    color: win.isMuted ? Theme.surfaceVariantFg : Theme.primary
                }
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 8
                    radius: 4
                    color: Theme.alpha(Theme.surfaceContainerHighest, 0.95)
                    Rectangle {
                        height: parent.height
                        radius: 4
                        width: parent.width * Math.max(0, Math.min(1, win.level))
                        color: win.isMuted ? Theme.outline : Theme.primary
                        Behavior on width {
                            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                        }
                    }
                }
                Txt {
                    Layout.preferredWidth: 38
                    horizontalAlignment: Text.AlignRight
                    text: win.isMuted ? "mudo" : Math.round(win.level * 100) + "%"
                    mono: true
                    font.weight: Font.DemiBold
                }
            }
        }
    }
}
