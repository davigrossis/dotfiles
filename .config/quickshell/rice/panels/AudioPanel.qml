import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.widgets

// Painel de som (PipeWire): volume/mudo de saída e entrada, troca do dispositivo padrão
// e mixer por aplicativo.
PanelBase {
    id: root

    panelWidth: 404

    function deviceIcon(n, isSink: bool): string {
        const s = ((n && (n.description || "")) + " " + (n && (n.name || ""))).toLowerCase();
        if (!isSink)
            return s.includes("headset") || s.includes("usb") ? "headset_mic" : "mic";
        if (s.includes("hdmi") || s.includes("displayport"))
            return "tv";
        if (s.includes("headphone") || s.includes("headset") || s.includes("usb") || s.includes("bluez"))
            return "headphones";
        return "speaker";
    }

    PanelHeader {
        icon: Audio.icon
        title: "Som"
        subtitle: Audio.nodeName(Audio.sink)
    }

    Flickable {
        id: flick
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(body.implicitHeight, root.maxHeight - 120)
        contentHeight: body.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height

        ColumnLayout {
            id: body
            width: flick.width
            spacing: 10

            // ── Saída ────────────────────────────────────────────────────────
            Card {
                Layout.fillWidth: true
                ColumnLayout {
                    width: parent.width
                    spacing: 6
                    SectionTitle {
                        text: "Saída"
                        Layout.topMargin: 0
                    }
                    RSlider {
                        Layout.fillWidth: true
                        icon: Audio.icon
                        value: Audio.volume
                        muted: Audio.muted
                        onMoved: v => Audio.setVolume(v)
                        onIconClicked: Audio.toggleMute()
                    }
                    Repeater {
                        model: Audio.sinks
                        delegate: ListRow {
                            id: sinkRow
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 38
                            icon: root.deviceIcon(modelData, true)
                            iconFill: highlighted ? 1 : 0
                            title: Audio.nodeName(modelData)
                            highlighted: Audio.sink !== null && modelData.id === Audio.sink.id
                            onClicked: Audio.setDefaultSink(modelData)
                            MIcon {
                                visible: sinkRow.highlighted
                                anchors.verticalCenter: parent.verticalCenter
                                icon: "check"
                                size: 18
                                color: Theme.primary
                            }
                        }
                    }
                }
            }

            // ── Entrada ──────────────────────────────────────────────────────
            Card {
                Layout.fillWidth: true
                visible: Audio.sources.length > 0
                ColumnLayout {
                    width: parent.width
                    spacing: 6
                    SectionTitle {
                        text: "Entrada"
                        Layout.topMargin: 0
                    }
                    RSlider {
                        Layout.fillWidth: true
                        icon: Audio.micIcon
                        value: Audio.micVolume
                        muted: Audio.micMuted
                        onMoved: v => Audio.setMicVolume(v)
                        onIconClicked: Audio.toggleMicMute()
                    }
                    Repeater {
                        model: Audio.sources
                        delegate: ListRow {
                            id: srcRow
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 38
                            icon: root.deviceIcon(modelData, false)
                            iconFill: highlighted ? 1 : 0
                            title: Audio.nodeName(modelData)
                            highlighted: Audio.source !== null && modelData.id === Audio.source.id
                            onClicked: Audio.setDefaultSource(modelData)
                            MIcon {
                                visible: srcRow.highlighted
                                anchors.verticalCenter: parent.verticalCenter
                                icon: "check"
                                size: 18
                                color: Theme.primary
                            }
                        }
                    }
                }
            }

            // ── Aplicativos ──────────────────────────────────────────────────
            Card {
                Layout.fillWidth: true
                ColumnLayout {
                    width: parent.width
                    spacing: 8
                    SectionTitle {
                        text: "Aplicativos"
                        Layout.topMargin: 0
                    }
                    Txt {
                        visible: Audio.streams.length === 0
                        text: "Nenhum aplicativo tocando áudio"
                        dim: true
                        font.pixelSize: Theme.font.small
                    }
                    Repeater {
                        model: Audio.streams
                        delegate: RowLayout {
                            id: app
                            required property var modelData
                            Layout.fillWidth: true
                            spacing: 10

                            IconImage {
                                Layout.preferredWidth: 26
                                Layout.preferredHeight: 26
                                source: Quickshell.iconPath(Audio.streamIcon(app.modelData), "audio-x-generic")
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 3
                                RowLayout {
                                    Layout.fillWidth: true
                                    Txt {
                                        text: Audio.streamName(app.modelData)
                                        font.weight: Font.DemiBold
                                        font.pixelSize: Theme.font.small + 1
                                    }
                                    Txt {
                                        Layout.fillWidth: true
                                        text: Audio.streamDetail(app.modelData)
                                        dim: true
                                        elide: Text.ElideRight
                                        font.pixelSize: Theme.font.small
                                    }
                                }
                                RSlider {
                                    Layout.fillWidth: true
                                    implicitHeight: 24
                                    icon: app.modelData.audio && app.modelData.audio.muted ? "volume_off" : "volume_up"
                                    value: app.modelData.audio ? app.modelData.audio.volume : 0
                                    muted: app.modelData.audio ? app.modelData.audio.muted : false
                                    onMoved: v => Audio.setStreamVolume(app.modelData, v)
                                    onIconClicked: Audio.toggleStreamMute(app.modelData)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    PillButton {
        Layout.alignment: Qt.AlignRight
        compact: true
        variant: "outline"
        icon: "tune"
        text: "Mixer avançado"
        onClicked: {
            Ui.close();
            Quickshell.execDetached(["pavucontrol"]);
        }
    }
}
