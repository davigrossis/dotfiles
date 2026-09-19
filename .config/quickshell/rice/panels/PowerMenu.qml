import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.widgets

// Menu de energia. Ações destrutivas pedem confirmação (segundo clique em 4 s).
PanelBase {
    id: root

    property string armed: ""
    panelWidth: 360

    readonly property var actions: [
        { key: "lock", label: "Bloquear", icon: "lock", confirm: false, cmd: ["hyprlock"] },
        { key: "suspend", label: "Suspender", icon: "bedtime", confirm: false, cmd: ["systemctl", "suspend"] },
        { key: "logout", label: "Sair", icon: "logout", confirm: true, cmd: ["hyprctl", "dispatch", "exit"] },
        { key: "reboot", label: "Reiniciar", icon: "restart_alt", confirm: true, cmd: ["systemctl", "reboot"] },
        { key: "poweroff", label: "Desligar", icon: "power_settings_new", confirm: true, cmd: ["systemctl", "poweroff"] }
    ]

    function run(a): void {
        if (a.confirm && root.armed !== a.key) {
            root.armed = a.key;
            disarm.restart();
            return;
        }
        Ui.close();
        Quickshell.execDetached(a.cmd);
    }

    Timer {
        id: disarm
        interval: 4000
        onTriggered: root.armed = ""
    }

    PanelHeader {
        icon: "power_settings_new"
        title: "Energia"
        subtitle: "Ligado há " + Sys.uptime
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 3
        rowSpacing: 8
        columnSpacing: 8

        Repeater {
            model: root.actions
            delegate: StateLayer {
                id: btn
                required property var modelData
                readonly property bool isArmed: root.armed === modelData.key
                Layout.fillWidth: true
                Layout.preferredHeight: 84
                radius: Theme.radius.large
                baseColor: isArmed ? Theme.errorContainer : Theme.cardBg
                stateColor: isArmed ? Theme.errorContainerFg : Theme.surfaceFg
                onClicked: root.run(modelData)

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 6
                    MIcon {
                        Layout.alignment: Qt.AlignHCenter
                        icon: btn.modelData.icon
                        size: 26
                        fill: btn.isArmed ? 1 : 0
                        color: btn.isArmed ? Theme.errorContainerFg : btn.modelData.key === "poweroff" ? Theme.error : Theme.surfaceFg
                    }
                    Txt {
                        Layout.alignment: Qt.AlignHCenter
                        text: btn.isArmed ? "Confirmar?" : btn.modelData.label
                        font.weight: Font.DemiBold
                        font.pixelSize: Theme.font.small + 1
                        color: btn.isArmed ? Theme.errorContainerFg : Theme.surfaceFg
                    }
                }
            }
        }
    }
}
