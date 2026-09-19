pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

// Bluetooth via BlueZ (módulo nativo Quickshell.Bluetooth, D-Bus).
Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter ? adapter.enabled : false
    readonly property bool discovering: adapter ? adapter.discovering : false
    readonly property var devices: adapter ? adapter.devices.values : []

    readonly property var connected: devices.filter(d => d.connected)
    readonly property var paired: devices.filter(d => d.paired || d.bonded).sort((a, b) => (b.connected - a.connected) || deviceName(a).localeCompare(deviceName(b)))
    readonly property var discovered: devices.filter(d => !d.paired && !d.bonded && d.deviceName && d.deviceName.length > 0)

    readonly property string icon: !enabled ? "bluetooth_disabled" : connected.length > 0 ? "bluetooth_connected" : discovering ? "bluetooth_searching" : "bluetooth"
    readonly property string statusText: !available ? "Indisponível" : !enabled ? "Desligado" : connected.length === 1 ? deviceName(connected[0]) : connected.length > 1 ? connected.length + " conectados" : "Ligado"

    function deviceName(d): string {
        if (!d)
            return "";
        return d.name || d.deviceName || d.address;
    }
    function deviceIcon(d): string {
        const i = (d && d.icon) || "";
        if (i.includes("headset"))
            return "headset_mic";
        if (i.includes("headphone") || i.includes("audio"))
            return "headphones";
        if (i.includes("mouse"))
            return "mouse";
        if (i.includes("keyboard"))
            return "keyboard";
        if (i.includes("phone"))
            return "smartphone";
        if (i.includes("computer"))
            return "computer";
        if (i.includes("gaming") || i.includes("joystick"))
            return "sports_esports";
        if (i.includes("watch"))
            return "watch";
        if (i.includes("tv") || i.includes("video"))
            return "tv";
        return "bluetooth";
    }
    function stateText(d): string {
        if (!d)
            return "";
        if (d.state === BluetoothDeviceState.Connecting)
            return "Conectando…";
        if (d.state === BluetoothDeviceState.Disconnecting)
            return "Desconectando…";
        if (d.pairing)
            return "Pareando…";
        let s = d.connected ? "Conectado" : (d.paired || d.bonded) ? "Pareado" : "Disponível";
        if (d.batteryAvailable)
            s += " · " + Math.round(d.battery * 100) + "%";
        return s;
    }

    function setEnabled(on: bool): void {
        if (adapter)
            adapter.enabled = on;
    }
    function setDiscovering(on: bool): void {
        if (adapter && adapter.enabled)
            adapter.discovering = on;
    }
    function activate(d): void {
        if (!d)
            return;
        if (d.connected) {
            d.disconnect();
        } else if (d.paired || d.bonded) {
            d.connect();
        } else {
            // dispositivo novo: parear, confiar e conectar
            d.trusted = true;
            d.pair();
        }
    }
    function forget(d): void {
        if (d)
            d.forget();
    }

    // após parear um dispositivo novo, conecta automaticamente
    Instantiator {
        model: root.devices
        delegate: Connections {
            required property var modelData
            target: modelData
            function onPairedChanged() {
                if (modelData.paired && !modelData.connected)
                    modelData.connect();
            }
        }
    }
}
