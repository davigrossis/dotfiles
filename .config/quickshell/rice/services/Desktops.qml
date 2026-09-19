pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// Áreas de trabalho da barra.
// - Se o plugin hyprland-virtual-desktops estiver carregado ("hyprctl printstate -j" responde
//   JSON), mostra os DESKTOPS VIRTUAIS (unificados entre monitores) e navega com os
//   dispatchers do plugin (vdesk / nextdesk / prevdesk).
// - Caso contrário (situação atual deste sistema: plugin não instalado), mostra os workspaces
//   do Hyprland de cada monitor e usa "workspace N", exatamente como seus binds SUPER+N.
Singleton {
    id: root

    property bool vdeskMode: false
    property var vdesks: []
    property int focusedVdesk: 1

    function parseState(text: string): void {
        let j = null;
        try {
            j = JSON.parse(text);
        } catch (e) {
            j = null;
        }
        if (!Array.isArray(j) || j.length === 0) {
            root.vdeskMode = false;
            root.vdesks = [];
            return;
        }
        const list = j.map((d, i) => ({
                    id: Number(d.id ?? i + 1),
                    name: String(d.name ?? d.id ?? i + 1),
                    focused: !!(d.focused ?? d.active),
                    populated: !!(d.populated ?? ((d.windows ?? 0) > 0)),
                    windows: Number(d.windows ?? 0)
                }));
        list.sort((a, b) => a.id - b.id);
        root.vdesks = list;
        const f = list.find(d => d.focused);
        if (f)
            root.focusedVdesk = f.id;
        root.vdeskMode = true;
    }

    function refresh(): void {
        if (!probe.running)
            probe.running = true;
    }

    Process {
        id: probe
        command: ["hyprctl", "-j", "printstate"]
        stdout: StdioCollector {
            onStreamFinished: root.parseState(text)
        }
    }

    Component.onCompleted: refresh()

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            const n = event.name;
            if (n.startsWith("vdesk") || n === "configreloaded" || n === "pluginloaded" || n === "pluginunloaded")
                root.refresh();
            else if (root.vdeskMode && (n === "openwindow" || n === "closewindow" || n === "movewindow" || n === "workspace"))
                root.refresh();
        }
    }

    // modo workspaces: lista do monitor (persistentes + existentes), ignorando especiais
    function workspacesFor(monitorName: string): var {
        return Hyprland.workspaces.values.filter(w => w.id > 0 && w.monitor && w.monitor.name === monitorName).sort((a, b) => a.id - b.id);
    }

    function activate(id: int): void {
        if (root.vdeskMode)
            Hyprland.dispatch("vdesk " + id);
        else
            Hyprland.dispatch("workspace " + id);
    }
    function next(): void {
        Hyprland.dispatch(root.vdeskMode ? "nextdesk" : "workspace e+1");
    }
    function prev(): void {
        Hyprland.dispatch(root.vdeskMode ? "prevdesk" : "workspace e-1");
    }
}
