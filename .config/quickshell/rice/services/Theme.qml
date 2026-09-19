pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Tema do rice: cores geradas pelo matugen a partir do wallpaper
// (~/.local/state/rice/colors.json, reescrito pelo apply-theme.sh) + tokens de design.
// O arquivo é observado: trocar o wallpaper muda a paleta ao vivo, com transição suave.
Singleton {
    id: root

    readonly property string colorsFile: Quickshell.env("HOME") + "/.local/state/rice/colors.json"
    property bool loaded: false
    property string mode: "dark"
    readonly property bool dark: mode !== "light"
    property string wallpaper: ""

    // ── Paleta Material 3 (valores iniciais = fallback escuro neutro) ──────────
    property color background: "#131313"
    property color surface: "#131313"
    property color surfaceDim: "#131313"
    property color surfaceBright: "#393939"
    property color surfaceContainerLowest: "#0e0e0e"
    property color surfaceContainerLow: "#1b1b1b"
    property color surfaceContainer: "#1f1f1f"
    property color surfaceContainerHigh: "#2a2a2a"
    property color surfaceContainerHighest: "#353535"
    property color surfaceVariant: "#474747"
    property color surfaceFg: "#e2e2e2"
    property color surfaceVariantFg: "#c6c6c6"
    property color outline: "#919191"
    property color outlineVariant: "#474747"
    property color primary: "#ffffff"
    property color primaryFg: "#1b1b1b"
    property color primaryContainer: "#d4d4d4"
    property color primaryContainerFg: "#000000"
    property color secondary: "#c6c6c6"
    property color secondaryFg: "#1b1b1b"
    property color secondaryContainer: "#474747"
    property color secondaryContainerFg: "#e2e2e2"
    property color tertiary: "#e2e2e2"
    property color tertiaryFg: "#1b1b1b"
    property color tertiaryContainer: "#919191"
    property color tertiaryContainerFg: "#000000"
    property color error: "#ffb4ab"
    property color errorFg: "#690005"
    property color errorContainer: "#93000a"
    property color errorContainerFg: "#ffdad6"
    property color inverseSurface: "#e2e2e2"
    property color inverseOnSurface: "#303030"
    property color shadow: "#000000"
    property color scrim: "#000000"

    // Cores semânticas harmonizadas com o wallpaper
    property color red: "#e06c75"
    property color green: "#98c379"
    property color yellow: "#e5c07b"
    property color blue: "#61afef"
    property color magenta: "#c678dd"
    property color cyan: "#56b6c2"
    property color orange: "#d19a66"

    readonly property int colorAnim: 700
    Behavior on background { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on surface { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on surfaceDim { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on surfaceBright { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on surfaceContainerLowest { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on surfaceContainerLow { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on surfaceContainer { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on surfaceContainerHigh { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on surfaceContainerHighest { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on surfaceVariant { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on surfaceFg { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on surfaceVariantFg { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on outline { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on outlineVariant { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on primary { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on primaryFg { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on primaryContainer { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on primaryContainerFg { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on secondary { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on secondaryFg { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on secondaryContainer { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on secondaryContainerFg { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on tertiary { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on tertiaryFg { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on tertiaryContainer { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on tertiaryContainerFg { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on error { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on errorFg { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on errorContainer { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on errorContainerFg { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on red { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on green { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on yellow { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }
    Behavior on blue { ColorAnimation { duration: root.colorAnim; easing.type: Easing.OutCubic } }

    // ── Transparência (o Hyprland borra o que fica atrás: layerrules.conf) ─────
    readonly property real barOpacity: 0.78
    readonly property real panelOpacity: 0.92
    readonly property real cardOpacity: 0.55

    // Fundos prontos com alpha
    readonly property color barBg: alpha(surfaceContainer, barOpacity)
    readonly property color panelBg: alpha(surfaceContainerLow, panelOpacity)
    readonly property color cardBg: alpha(surfaceContainerHigh, cardOpacity)
    readonly property color borderColor: alpha(outlineVariant, 0.55)

    // ── Tipografia ─────────────────────────────────────────────────────────────
    readonly property QtObject font: QtObject {
        readonly property string sans: "Inter"
        readonly property string mono: "JetBrainsMono Nerd Font"
        readonly property string icon: "Material Symbols Rounded"
        // tamanhos em pixels
        readonly property int small: 11
        readonly property int normal: 13
        readonly property int medium: 14
        readonly property int large: 16
        readonly property int title: 20
        readonly property int huge: 40
    }

    // ── Geometria ──────────────────────────────────────────────────────────────
    readonly property QtObject radius: QtObject {
        readonly property int small: 8
        readonly property int normal: 12
        readonly property int large: 16
        readonly property int panel: 22
        readonly property int full: 999
    }
    readonly property int barHeight: 34
    readonly property int barMargin: 6
    readonly property int gap: 8
    readonly property int padding: 14

    // ── Animação ───────────────────────────────────────────────────────────────
    readonly property QtObject anim: QtObject {
        readonly property int fast: 140
        readonly property int normal: 240
        readonly property int slow: 420
    }

    // ── Helpers ────────────────────────────────────────────────────────────────
    function alpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a);
    }
    function mix(a, b, t) {
        return Qt.rgba(a.r * (1 - t) + b.r * t, a.g * (1 - t) + b.g * t, a.b * (1 - t) + b.b * t, a.a * (1 - t) + b.a * t);
    }
    // Camada de estado M3 (hover/pressed) sobre uma cor base
    function state(base, fg, level) {
        return mix(base, fg, level);
    }

    function applyJson(text) {
        let j;
        try {
            j = JSON.parse(text);
        } catch (e) {
            console.warn("Theme: colors.json inválido:", e);
            return;
        }
        const c = j.colors || {};
        const map = {
            background: "background", surface: "surface", surface_dim: "surfaceDim", surface_bright: "surfaceBright",
            surface_container_lowest: "surfaceContainerLowest", surface_container_low: "surfaceContainerLow",
            surface_container: "surfaceContainer", surface_container_high: "surfaceContainerHigh",
            surface_container_highest: "surfaceContainerHighest", surface_variant: "surfaceVariant",
            on_surface: "surfaceFg", on_surface_variant: "surfaceVariantFg", outline: "outline",
            outline_variant: "outlineVariant", primary: "primary", on_primary: "primaryFg",
            primary_container: "primaryContainer", on_primary_container: "primaryContainerFg",
            secondary: "secondary", on_secondary: "secondaryFg", secondary_container: "secondaryContainer",
            on_secondary_container: "secondaryContainerFg", tertiary: "tertiary", on_tertiary: "tertiaryFg",
            tertiary_container: "tertiaryContainer", on_tertiary_container: "tertiaryContainerFg",
            error: "error", on_error: "errorFg", error_container: "errorContainer",
            on_error_container: "errorContainerFg", inverse_surface: "inverseSurface",
            inverse_on_surface: "inverseOnSurface", shadow: "shadow", scrim: "scrim"
        };
        for (const k in map)
            if (c[k])
                root[map[k]] = c[k];
        const s = j.semantic || {};
        for (const k of ["red", "green", "yellow", "blue", "magenta", "cyan", "orange"])
            if (s[k])
                root[k] = s[k];
        root.mode = j.mode || "dark";
        root.wallpaper = j.image || "";
        root.loaded = true;
    }

    FileView {
        id: colorsView
        path: root.colorsFile
        watchChanges: true
        printErrors: false
        onFileChanged: reloadTimer.restart()
        onLoaded: root.applyJson(text())
    }
    // o matugen reescreve o arquivo; espera um instante para não ler pela metade
    Timer {
        id: reloadTimer
        interval: 80
        onTriggered: colorsView.reload()
    }
}
