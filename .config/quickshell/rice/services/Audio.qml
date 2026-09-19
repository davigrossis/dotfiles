pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Áudio via PipeWire (nativo do Quickshell): volume/mudo de saída e entrada,
// troca de dispositivo padrão e mixer por aplicativo.
Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property bool ready: sink !== null && sink.audio !== null

    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real micVolume: source?.audio?.volume ?? 0
    readonly property bool micMuted: source?.audio?.muted ?? false

    readonly property var allNodes: Pipewire.nodes.values
    readonly property var sinks: allNodes.filter(n => !n.isStream && mediaClass(n).startsWith("Audio/Sink"))
    readonly property var sources: allNodes.filter(n => !n.isStream && mediaClass(n).startsWith("Audio/Source"))
    // fluxos de reprodução dos aplicativos (mixer por app)
    readonly property var streams: allNodes.filter(n => n.isStream && mediaClass(n) === "Stream/Output/Audio")

    // "bind" em todos os nós para ter volume/propriedades disponíveis
    PwObjectTracker {
        objects: root.allNodes
    }

    function mediaClass(n): string {
        return (n && n.properties) ? (n.properties["media.class"] || "") : "";
    }
    function nodeName(n): string {
        if (!n)
            return "";
        return n.description || n.nickname || n.name || "Dispositivo";
    }
    function streamName(n): string {
        if (!n)
            return "";
        const p = n.properties || {};
        return p["application.name"] || n.description || n.name || "Aplicativo";
    }
    function streamDetail(n): string {
        const p = (n && n.properties) || {};
        return p["media.name"] || "";
    }
    function streamIcon(n): string {
        const p = (n && n.properties) || {};
        const icon = p["application.icon-name"] || "";
        if (icon !== "")
            return icon;
        const entry = DesktopEntries.heuristicLookup(p["application.process.binary"] || p["application.name"] || "");
        return entry ? entry.icon : "";
    }

    function volumeIcon(vol: real, mute: bool): string {
        if (mute || vol <= 0.001)
            return "volume_off";
        if (vol < 0.34)
            return "volume_mute";
        if (vol < 0.67)
            return "volume_down";
        return "volume_up";
    }
    readonly property string icon: volumeIcon(volume, muted)
    readonly property string micIcon: micMuted ? "mic_off" : "mic"

    function clamp(v: real): real {
        return Math.max(0, Math.min(1, v));
    }
    function setVolume(v: real): void {
        if (sink?.audio) {
            sink.audio.muted = false;
            sink.audio.volume = clamp(v);
        }
    }
    function changeVolume(delta: real): void {
        if (sink?.audio)
            setVolume(sink.audio.volume + delta);
    }
    function toggleMute(): void {
        if (sink?.audio)
            sink.audio.muted = !sink.audio.muted;
    }
    function setMicVolume(v: real): void {
        if (source?.audio) {
            source.audio.muted = false;
            source.audio.volume = clamp(v);
        }
    }
    function toggleMicMute(): void {
        if (source?.audio)
            source.audio.muted = !source.audio.muted;
    }
    function setDefaultSink(n): void {
        Pipewire.preferredDefaultAudioSink = n;
    }
    function setDefaultSource(n): void {
        Pipewire.preferredDefaultAudioSource = n;
    }
    function setStreamVolume(n, v: real): void {
        if (n?.audio) {
            n.audio.muted = false;
            n.audio.volume = clamp(v);
        }
    }
    function toggleStreamMute(n): void {
        if (n?.audio)
            n.audio.muted = !n.audio.muted;
    }
}
