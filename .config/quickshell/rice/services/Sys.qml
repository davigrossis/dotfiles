pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

// Métricas do sistema: CPU, RAM, swap, temperatura, uptime e bateria (UPower).
Singleton {
    id: root

    property real cpu: 0          // 0..1
    property real mem: 0          // 0..1
    property real memUsedGiB: 0
    property real memTotalGiB: 0
    property real swap: 0
    property real swapUsedGiB: 0
    property real swapTotalGiB: 0
    property real temp: 0         // °C
    property string uptime: ""
    property var _prevCpu: null
    property int consumers: 0     // painéis abertos pedem atualização mais rápida

    // ── Bateria ───────────────────────────────────────────────────────────────
    readonly property var battery: UPower.displayDevice
    readonly property bool hasBattery: battery !== null && battery.isLaptopBattery && battery.isPresent
    readonly property real batteryPct: hasBattery ? battery.percentage : 0
    readonly property bool charging: hasBattery && battery.state === UPowerDeviceState.Charging
    readonly property bool pluggedIdle: hasBattery && battery.state === UPowerDeviceState.PendingCharge
    readonly property bool full: hasBattery && battery.state === UPowerDeviceState.FullyCharged
    readonly property bool onBattery: UPower.onBattery
    readonly property string batteryIcon: {
        if (!hasBattery || pluggedIdle)
            return "power";
        const p = batteryPct;
        if (charging || full) {
            if (p >= 0.95)
                return "battery_charging_full";
            if (p >= 0.85)
                return "battery_charging_90";
            if (p >= 0.7)
                return "battery_charging_80";
            if (p >= 0.55)
                return "battery_charging_60";
            if (p >= 0.4)
                return "battery_charging_50";
            if (p >= 0.25)
                return "battery_charging_30";
            return "battery_charging_20";
        }
        if (p >= 0.95)
            return "battery_full";
        if (p <= 0.07)
            return "battery_alert";
        return "battery_" + Math.max(0, Math.min(6, Math.floor(p * 7))) + "_bar";
    }
    function fmtTime(secs: real): string {
        if (!secs || secs <= 0)
            return "";
        const h = Math.floor(secs / 3600);
        const m = Math.round((secs % 3600) / 60);
        return h > 0 ? h + " h " + m + " min" : m + " min";
    }
    readonly property string batteryText: {
        if (!hasBattery)
            return "Sem bateria";
        if (full)
            return "Carregada";
        if (pluggedIdle)
            return "Na tomada · sem carregar";
        if (charging) {
            const t = fmtTime(battery.timeToFull);
            return t ? "Carregando · cheia em " + t : "Carregando";
        }
        const t = fmtTime(battery.timeToEmpty);
        return t ? t + " restantes" : "Na bateria";
    }
    // outros dispositivos com bateria (mouse, fones...)
    readonly property var peripherals: UPower.devices.values.filter(d => d.isPresent && !d.isLaptopBattery && d.type !== UPowerDeviceType.LinePower && d.percentage > 0)

    // ── Leituras de /proc e /sys ───────────────────────────────────────────────
    FileView {
        id: statFile
        path: "/proc/stat"
        blockLoading: true
    }
    FileView {
        id: memFile
        path: "/proc/meminfo"
        blockLoading: true
    }
    FileView {
        id: uptimeFile
        path: "/proc/uptime"
        blockLoading: true
    }
    FileView {
        id: tempFile
        path: ""
        blockLoading: true
        printErrors: false
    }

    // encontra o sensor da CPU (coretemp / k10temp / zenpower / acpitz), o índice muda entre boots
    Process {
        id: findSensor
        running: true
        command: ["sh", "-c", "for n in coretemp k10temp zenpower cpu_thermal acpitz; do for h in /sys/class/hwmon/hwmon*; do [ \"$(cat $h/name 2>/dev/null)\" = \"$n\" ] && [ -r $h/temp1_input ] && { echo $h/temp1_input; exit 0; }; done; done"]
        stdout: StdioCollector {
            onStreamFinished: tempFile.path = text.trim()
        }
    }

    function sample(): void {
        statFile.reload();
        const line = statFile.text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
        const idle = line[3] + (line[4] || 0);
        const total = line.reduce((a, b) => a + b, 0);
        if (root._prevCpu) {
            const dt = total - root._prevCpu.total;
            const di = idle - root._prevCpu.idle;
            if (dt > 0)
                root.cpu = Math.max(0, Math.min(1, 1 - di / dt));
        }
        root._prevCpu = {
            total: total,
            idle: idle
        };

        memFile.reload();
        const info = {};
        for (const l of memFile.text().split("\n")) {
            const m = l.match(/^(\w+):\s+(\d+)/);
            if (m)
                info[m[1]] = Number(m[2]);
        }
        if (info.MemTotal) {
            const used = info.MemTotal - (info.MemAvailable ?? info.MemFree);
            root.mem = used / info.MemTotal;
            root.memUsedGiB = used / 1048576;
            root.memTotalGiB = info.MemTotal / 1048576;
        }
        if (info.SwapTotal) {
            const su = info.SwapTotal - info.SwapFree;
            root.swap = su / info.SwapTotal;
            root.swapUsedGiB = su / 1048576;
            root.swapTotalGiB = info.SwapTotal / 1048576;
        }

        if (tempFile.path !== "") {
            tempFile.reload();
            const t = Number(tempFile.text().trim());
            if (t > 0)
                root.temp = t / 1000;
        }

        uptimeFile.reload();
        const up = Number(uptimeFile.text().split(" ")[0]);
        const d = Math.floor(up / 86400), h = Math.floor(up % 86400 / 3600), m = Math.floor(up % 3600 / 60);
        root.uptime = (d > 0 ? d + "d " : "") + (h > 0 ? h + "h " : "") + m + "min";
    }

    Timer {
        interval: root.consumers > 0 ? 1000 : 2500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.sample()
    }
}
