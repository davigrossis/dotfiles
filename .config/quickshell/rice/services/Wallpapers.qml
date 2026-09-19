pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Wallpapers: pasta e wallpaper atual vêm do Waypaper (~/.config/waypaper/config.ini),
// que é a fonte de verdade. Aplicar = "waypaper --wallpaper <arq>" (mesmo backend awww +
// post_command apply-theme.sh). Miniaturas em ~/.cache/rice/wallpapers (rice-thumbs.sh).
Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string cacheDir: home + "/.cache/rice/wallpapers"
    property string folder: ""
    property string current: ""
    property var items: []
    property bool generating: false
    property int thumbsVersion: 0
    property string applying: ""

    function expand(p: string): string {
        return p.startsWith("~") ? root.home + p.slice(1) : p;
    }
    function thumbFor(path: string): string {
        return "file://" + root.cacheDir + "/" + Qt.md5(path) + "-thumb.jpg";
    }
    function previewFor(path: string): string {
        return "file://" + root.cacheDir + "/" + Qt.md5(path) + "-preview.jpg";
    }

    function parseConfig(t: string): void {
        const f = t.match(/^folder = (.*)$/m);
        const w = t.match(/^wallpaper = (.*)$/m);
        root.current = w ? root.expand(w[1].trim()) : "";
        const nf = f ? root.expand(f[1].trim()) : "";
        if (nf !== root.folder) {
            root.folder = nf;
            root.rescan();
        }
        if (root.applying !== "" && root.applying === root.current)
            root.applying = "";
    }

    FileView {
        id: cfg
        path: root.home + "/.config/waypaper/config.ini"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.parseConfig(text())
    }

    Process {
        id: lister
        command: ["find", "-L", root.folder, "-maxdepth", "1", "-type", "f", "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.png", "-o", "-iname", "*.webp", "-o", "-iname", "*.bmp", "-o", "-iname", "*.gif", "-o", "-iname", "*.jxl", ")"]
        stdout: StdioCollector {
            onStreamFinished: {
                const paths = text.split("\n").filter(x => x.length > 0);
                paths.sort((a, b) => a.toLowerCase().localeCompare(b.toLowerCase()));
                root.items = paths.map(p => ({
                            path: p,
                            name: p.split("/").pop()
                        }));
                root.generateThumbs();
            }
        }
    }

    Process {
        id: thumbGen
        command: [root.home + "/.config/scripts/rice-thumbs.sh", root.folder]
        onExited: {
            root.generating = false;
            root.thumbsVersion++;
        }
    }

    function rescan(): void {
        if (root.folder === "")
            return;
        lister.running = false;
        lister.running = true;
    }
    function generateThumbs(): void {
        if (!thumbGen.running) {
            root.generating = true;
            thumbGen.running = true;
        }
    }
    function apply(path: string): void {
        root.applying = path;
        // awww direto (mesmas transições do config do Waypaper) + um único apply-theme.sh
        Quickshell.execDetached([root.home + "/.config/scripts/rice-wallpaper.sh", "set", path]);
    }
}
