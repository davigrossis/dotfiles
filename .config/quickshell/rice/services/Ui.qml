pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

// Estado global da interface: qual painel está aberto, em qual monitor e ancorado onde.
Singleton {
    id: root

    // "" | control | wifi | bluetooth | audio | notifications | calendar | power | system | media
    property string panel: ""
    property string panelScreen: ""
    property real panelAnchorX: -1        // centro do botão que abriu (coordenada da tela)
    property bool pickerOpen: false
    property string pickerScreen: ""
    property bool barVisible: true
    property bool caffeine: false

    readonly property bool anyPanel: panel !== ""

    function focusedScreen(): string {
        const m = Hyprland.focusedMonitor;
        if (m)
            return m.name;
        return Quickshell.screens.length > 0 ? Quickshell.screens[0].name : "";
    }

    function open(name: string, screenName: string, anchorX: real): void {
        pickerOpen = false;
        panelScreen = screenName !== "" ? screenName : focusedScreen();
        panelAnchorX = anchorX;
        panel = name;
    }

    function toggle(name: string, screenName: string, anchorX: real): void {
        const scr = screenName !== "" ? screenName : focusedScreen();
        if (panel === name && panelScreen === scr)
            close();
        else
            open(name, scr, anchorX);
    }

    function close(): void {
        panel = "";
    }

    function togglePicker(): void {
        if (pickerOpen) {
            pickerOpen = false;
            return;
        }
        close();
        pickerScreen = focusedScreen();
        pickerOpen = true;
    }
}
