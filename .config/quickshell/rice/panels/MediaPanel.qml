import QtQuick
import QtQuick.Layouts
import qs.services
import qs.widgets

// Painel de mídia: player atual (capa, progresso, controles) e seletor de player.
PanelBase {
    id: root

    panelWidth: 380

    PanelHeader {
        icon: "music_note"
        title: "Mídia"
        subtitle: Media.players.length > 1 ? Media.players.length + " players" : (Media.player ? Media.player.identity : "Nenhum player")
    }

    MediaCard {
        Layout.fillWidth: true
        visible: Media.player !== null
    }

    Segmented {
        visible: Media.players.length > 1
        Layout.fillWidth: true
        model: Media.players.map((p, i) => ({
                    key: String(i),
                    label: p.identity || ("Player " + (i + 1))
                }))
        current: String(Media.players.indexOf(Media.player))
        onSelected: key => Media.manual = Media.players[Number(key)]
    }

    Txt {
        visible: Media.player === null
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 12
        Layout.bottomMargin: 12
        text: "Nenhum player de mídia aberto"
        dim: true
    }
}
