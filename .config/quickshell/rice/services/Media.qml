pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// Player MPRIS "ativo": o que está tocando, senão o último usado.
Singleton {
    id: root

    readonly property var players: Mpris.players.values
    property var manual: null
    property var lastPlaying: null
    readonly property var player: {
        if (manual && players.includes(manual))
            return manual;
        const playing = players.find(p => p.isPlaying);
        if (playing)
            return playing;
        if (lastPlaying && players.includes(lastPlaying))
            return lastPlaying;
        return players.length > 0 ? players[0] : null;
    }
    readonly property bool active: player !== null && (player.trackTitle || "") !== ""
    readonly property bool playing: player ? player.isPlaying : false
    readonly property string title: player ? (player.trackTitle || player.identity || "") : ""
    readonly property string artist: player ? (player.trackArtist || "") : ""

    onPlayerChanged: if (player && player.isPlaying) lastPlaying = player

    Instantiator {
        model: root.players
        delegate: Connections {
            required property var modelData
            target: modelData
            function onIsPlayingChanged() {
                if (modelData.isPlaying) {
                    root.lastPlaying = modelData;
                    root.manual = null;
                }
            }
        }
    }

    function togglePlaying(): void {
        if (player && player.canTogglePlaying)
            player.togglePlaying();
    }
    function next(): void {
        if (player && player.canGoNext)
            player.next();
    }
    function previous(): void {
        if (player && player.canGoPrevious)
            player.previous();
    }
    function fmt(secs: real): string {
        if (!secs || secs < 0 || !isFinite(secs))
            return "0:00";
        const m = Math.floor(secs / 60), s = Math.floor(secs % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }
}
