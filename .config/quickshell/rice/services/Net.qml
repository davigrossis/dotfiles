pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking

// Rede via NetworkManager (módulo nativo Quickshell.Networking, D-Bus).
// Só consome o NetworkManager existente: ligar/desligar rádio, listar, conectar/desconectar.
Singleton {
    id: root

    readonly property var devices: Networking.devices.values
    readonly property var wifiDevice: devices.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wiredDevice: devices.find(d => d.type === DeviceType.Wired && d.connected) ?? null
    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wifiHardwareEnabled: Networking.wifiHardwareEnabled
    readonly property bool ethernet: wiredDevice !== null

    readonly property var networks: wifiDevice ? wifiDevice.networks.values : []
    readonly property var active: networks.find(n => n.connected) ?? null
    readonly property string ssid: active ? active.name : ""
    readonly property real strength: active ? active.signalStrength : 0
    readonly property bool scanning: wifiDevice ? wifiDevice.scannerEnabled : false

    // conectada primeiro, depois conhecidas, depois por sinal
    readonly property var sortedNetworks: networks.filter(n => n.name && n.name.length > 0).sort((a, b) => {
        if (a.connected !== b.connected)
            return a.connected ? -1 : 1;
        if (a.known !== b.known)
            return a.known ? -1 : 1;
        return b.signalStrength - a.signalStrength;
    })

    // último erro de conexão (mostrado no painel)
    property string lastError: ""
    property string lastErrorNetwork: ""

    function strengthIcon(s: real): string {
        if (s > 0.75)
            return "signal_wifi_4_bar";
        if (s > 0.5)
            return "network_wifi_3_bar";
        if (s > 0.25)
            return "network_wifi_2_bar";
        if (s > 0.05)
            return "network_wifi_1_bar";
        return "signal_wifi_0_bar";
    }
    readonly property string icon: {
        if (ethernet && !active)
            return "lan";
        if (!wifiEnabled)
            return "signal_wifi_off";
        if (!active)
            return "signal_wifi_statusbar_not_connected";
        return strengthIcon(strength);
    }
    readonly property string statusText: {
        if (ethernet && !active)
            return "Cabeada";
        if (!wifiEnabled)
            return "Wi-Fi desligado";
        if (!active)
            return "Desconectado";
        return ssid;
    }

    function isSecure(n): bool {
        return n && n.security !== WifiSecurityType.Open && n.security !== WifiSecurityType.Unknown;
    }
    function securityText(n): string {
        if (!n)
            return "";
        switch (n.security) {
        case WifiSecurityType.Open:
            return "Aberta";
        case WifiSecurityType.Owe:
            return "Aberta (OWE)";
        case WifiSecurityType.Sae:
        case WifiSecurityType.Wpa3SuiteB192:
            return "WPA3";
        case WifiSecurityType.Wpa2Psk:
        case WifiSecurityType.WpaPsk:
            return "WPA/WPA2";
        case WifiSecurityType.Wpa2Eap:
        case WifiSecurityType.WpaEap:
            return "Empresarial (EAP)";
        default:
            return "Protegida";
        }
    }

    function setWifiEnabled(on: bool): void {
        Networking.wifiEnabled = on;
    }
    function setScanning(on: bool): void {
        if (wifiDevice)
            wifiDevice.scannerEnabled = on;
    }
    function connectTo(n): void {
        lastError = "";
        n.connect();
    }
    function connectWithPassword(n, psk: string): void {
        lastError = "";
        n.connectWithPsk(psk);
    }
    function disconnectFrom(n): void {
        n.disconnect();
    }
    function forget(n): void {
        n.forget();
    }

    function failText(reason): string {
        switch (reason) {
        case ConnectionFailReason.NoSecrets:
            return "Senha necessária ou incorreta";
        case ConnectionFailReason.WifiAuthTimeout:
            return "Tempo esgotado na autenticação";
        case ConnectionFailReason.WifiNetworkLost:
            return "Rede perdida";
        case ConnectionFailReason.WifiClientFailed:
        case ConnectionFailReason.WifiClientDisconnected:
            return "Falha ao conectar";
        default:
            return "Não foi possível conectar";
        }
    }

    Instantiator {
        model: root.networks
        delegate: Connections {
            required property var modelData
            target: modelData
            function onConnectionFailed(reason) {
                root.lastErrorNetwork = modelData.name;
                root.lastError = root.failText(reason);
            }
        }
    }
}
