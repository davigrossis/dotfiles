pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Brilho da tela interna (backlight) via brightnessctl — o mesmo que seus binds XF86.
Singleton {
    id: root

    property string device: ""
    property int max: 0
    property int current: 0
    readonly property bool available: device !== "" && max > 0
    readonly property real value: available ? current / max : 0
    property real pending: -1
    signal changedExternally

    Process {
        id: detect
        running: true
        command: ["sh", "-c", "for d in /sys/class/backlight/*; do [ -r \"$d/max_brightness\" ] && { echo \"${d##*/} $(cat $d/max_brightness)\"; exit 0; }; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim().split(" ");
                if (p.length === 2) {
                    root.device = p[0];
                    root.max = Number(p[1]);
                }
            }
        }
    }

    FileView {
        id: cur
        path: root.device !== "" ? "/sys/class/backlight/" + root.device + "/brightness" : ""
        blockLoading: true
        printErrors: false
    }

    function poll(): void {
        if (!root.available)
            return;
        cur.reload();
        const v = Number(cur.text().trim());
        if (!isNaN(v) && v !== root.current) {
            const external = root.pending < 0;
            root.current = v;
            if (external)
                root.changedExternally();
        }
    }

    Timer {
        interval: 700
        running: root.available
        repeat: true
        onTriggered: root.poll()
    }

    // aplica com leve "debounce" para não disparar dezenas de processos ao arrastar
    function set(v: real): void {
        if (!root.available)
            return;
        root.pending = Math.max(0.01, Math.min(1, v));
        root.current = Math.round(root.pending * root.max);
        applyTimer.restart();
    }
    Timer {
        id: applyTimer
        interval: 60
        onTriggered: {
            if (root.pending < 0)
                return;
            Quickshell.execDetached(["brightnessctl", "-q", "-d", root.device, "set", Math.round(root.pending * 100) + "%"]);
            clearPending.restart();
        }
    }
    Timer {
        id: clearPending
        interval: 900
        onTriggered: root.pending = -1
    }
}
