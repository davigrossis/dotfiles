import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.widgets

// Cartão de mídia (MPRIS): capa, título/artista, progresso (com seek) e controles.
Card {
    id: root

    property bool compact: false
    readonly property var player: Media.player
    property real pos: 0

    padding: 12

    // a posição MPRIS não emite mudança contínua; atualiza enquanto visível
    Timer {
        interval: 500
        running: root.visible && root.player !== null && Media.playing
        repeat: true
        triggeredOnStart: true
        onTriggered: root.pos = root.player ? root.player.position : 0
    }
    Connections {
        target: root.player
        function onPositionChanged() {
            root.pos = root.player.position;
        }
        function onPostTrackChanged() {
            root.pos = 0;
        }
    }

    ColumnLayout {
        width: parent.width
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ClippingRectangle {
                Layout.preferredWidth: root.compact ? 56 : 88
                Layout.preferredHeight: root.compact ? 56 : 88
                radius: Theme.radius.normal
                color: Theme.alpha(Theme.primary, 0.15)
                Image {
                    id: art
                    anchors.fill: parent
                    source: root.player ? (root.player.trackArtUrl || "") : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    sourceSize.width: 176
                    sourceSize.height: 176
                }
                MIcon {
                    anchors.centerIn: parent
                    visible: art.status !== Image.Ready
                    icon: "music_note"
                    size: root.compact ? 26 : 38
                    color: Theme.primary
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Txt {
                    Layout.fillWidth: true
                    text: Media.title || "Nada tocando"
                    font.weight: Font.Bold
                    font.pixelSize: root.compact ? Theme.font.normal : Theme.font.medium
                    elide: Text.ElideRight
                }
                Txt {
                    Layout.fillWidth: true
                    text: Media.artist
                    visible: text !== ""
                    dim: true
                    elide: Text.ElideRight
                }
                Txt {
                    Layout.fillWidth: true
                    visible: !root.compact && root.player !== null && (root.player.trackAlbum || "") !== ""
                    text: root.player ? (root.player.trackAlbum || "") : ""
                    dim: true
                    font.pixelSize: Theme.font.small
                    elide: Text.ElideRight
                }
                Txt {
                    Layout.fillWidth: true
                    text: root.player ? root.player.identity : ""
                    color: Theme.primary
                    font.pixelSize: Theme.font.small
                    font.weight: Font.DemiBold
                }
            }

            RowLayout {
                visible: root.compact
                spacing: 0
                IconButton {
                    icon: "skip_previous"
                    disabled: !root.player || !root.player.canGoPrevious
                    onClicked: Media.previous()
                }
                IconButton {
                    icon: Media.playing ? "pause" : "play_arrow"
                    filled: true
                    iconColor: Theme.primary
                    onClicked: Media.togglePlaying()
                }
                IconButton {
                    icon: "skip_next"
                    disabled: !root.player || !root.player.canGoNext
                    onClicked: Media.next()
                }
            }
        }

        // progresso
        ColumnLayout {
            visible: !root.compact && root.player !== null && root.player.lengthSupported && root.player.length > 0
            Layout.fillWidth: true
            spacing: 2
            RSlider {
                Layout.fillWidth: true
                implicitHeight: 10
                showValue: false
                from: 0
                to: root.player && root.player.length > 0 ? root.player.length : 1
                value: root.pos
                onMoved: v => {
                    if (root.player && root.player.canSeek) {
                        root.player.position = v;
                        root.pos = v;
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Txt {
                    text: Media.fmt(root.pos)
                    mono: true
                    dim: true
                    font.pixelSize: Theme.font.small
                }
                Item {
                    Layout.fillWidth: true
                }
                Txt {
                    text: root.player ? Media.fmt(root.player.length) : ""
                    mono: true
                    dim: true
                    font.pixelSize: Theme.font.small
                }
            }
        }

        RowLayout {
            visible: !root.compact
            Layout.alignment: Qt.AlignHCenter
            spacing: 14
            IconButton {
                icon: "skip_previous"
                iconSize: 26
                implicitWidth: 44
                implicitHeight: 44
                disabled: !root.player || !root.player.canGoPrevious
                onClicked: Media.previous()
            }
            StateLayer {
                implicitWidth: 56
                implicitHeight: 56
                radius: 28
                baseColor: Theme.primary
                stateColor: Theme.primaryFg
                onClicked: Media.togglePlaying()
                MIcon {
                    anchors.centerIn: parent
                    icon: Media.playing ? "pause" : "play_arrow"
                    size: 30
                    fill: 1
                    color: Theme.primaryFg
                }
            }
            IconButton {
                icon: "skip_next"
                iconSize: 26
                implicitWidth: 44
                implicitHeight: 44
                disabled: !root.player || !root.player.canGoNext
                onClicked: Media.next()
            }
        }
    }
}
