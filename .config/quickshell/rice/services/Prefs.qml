pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Preferências do rice: modo claro/escuro e esquema do matugen (lidos pelo apply-theme.sh)
// e luz noturna (hyprsunset).
Singleton {
    id: root

    readonly property string stateDir: Quickshell.env("HOME") + "/.local/state/rice"
    property string mode: "dark"
    property string scheme: "auto"
    property string effectiveScheme: ""
    property bool nightLight: false
    property int nightTemp: 4500

    readonly property var schemes: [
        { key: "auto", label: "Auto" },
        { key: "scheme-tonal-spot", label: "Tonal" },
        { key: "scheme-vibrant", label: "Vibrante" },
        { key: "scheme-content", label: "Fiel" },
        { key: "scheme-monochrome", label: "Mono" }
    ]

    FileView {
        path: root.stateDir + "/theme.env"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            const t = text();
            const m = t.match(/^RICE_MODE=(\S+)/m);
            const s = t.match(/^RICE_SCHEME=(\S+)/m);
            if (m)
                root.mode = m[1];
            if (s)
                root.scheme = s[1];
        }
    }
    FileView {
        path: root.stateDir + "/theme-effective"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            const s = text().match(/^scheme=(\S+)/m);
            root.effectiveScheme = s ? s[1] : "";
        }
    }

    Process {
        id: applyProc
        property string m: "dark"
        property string s: "auto"
        command: ["sh", "-c", "printf 'RICE_MODE=%s\\nRICE_SCHEME=%s\\n' \"$1\" \"$2\" > \"$3/theme.env\" && exec \"$HOME/.config/scripts/apply-theme.sh\"", "sh", m, s, root.stateDir]
    }
    function setTheme(mode: string, scheme: string): void {
        root.mode = mode;
        root.scheme = scheme;
        applyProc.m = mode;
        applyProc.s = scheme;
        applyProc.running = false;
        applyProc.running = true;
    }

    // ── Luz noturna ────────────────────────────────────────────────────────────
    Process {
        id: nlCheck
        running: true
        command: ["pgrep", "-x", "hyprsunset"]
        onExited: code => root.nightLight = code === 0
    }
    function toggleNightLight(): void {
        if (root.nightLight)
            Quickshell.execDetached(["pkill", "-x", "hyprsunset"]);
        else
            Quickshell.execDetached(["hyprsunset", "-t", String(root.nightTemp)]);
        root.nightLight = !root.nightLight;
    }
}
