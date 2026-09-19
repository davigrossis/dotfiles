import QtQuick
import QtQuick.Layouts
import qs.services
import qs.widgets

// Mídia (MPRIS) na barra: ícone animado + título. Clique abre o painel de mídia,
// botão do meio = play/pause, rolagem = próxima/anterior.
StateLayer {
    id: root

    property int maxTextWidth: 200

    visible: Media.active
    implicitHeight: Theme.barHeight - 8
    implicitWidth: row.implicitWidth + 18
    radius: Theme.radius.normal
    activeColor: Theme.alpha(Theme.primary, 0.18)
    onWheel: wheel => {
        if (wheel.angleDelta.y < 0)
            Media.next();
        else
            Media.previous();
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 7

        // "equalizador" animado enquanto toca
        Row {
            spacing: 2
            Layout.alignment: Qt.AlignVCenter
            Repeater {
                model: 3
                Rectangle {
                    required property int index
                    width: 3
                    radius: 1.5
                    anchors.bottom: parent.bottom
                    color: Theme.primary
                    height: 5
                    SequentialAnimation on height {
                        running: Media.playing
                        loops: Animation.Infinite
                        NumberAnimation { to: 13 - index * 2; duration: 300 + index * 110; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 4 + index; duration: 280 + index * 90; easing.type: Easing.InOutSine }
                    }
                }
            }
            height: 13
        }

        Txt {
            Layout.maximumWidth: root.maxTextWidth
            text: Media.title + (Media.artist !== "" ? "  ·  " + Media.artist : "")
            elide: Text.ElideRight
            font.pixelSize: Theme.font.normal
            font.weight: Font.Medium
        }
    }
}
