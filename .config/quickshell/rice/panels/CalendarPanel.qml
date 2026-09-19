import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.widgets

// Relógio grande + calendário do mês (pt-BR, semana começando no domingo).
PanelBase {
    id: root

    panelWidth: 340

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    property int viewYear: clock.date.getFullYear()
    property int viewMonth: clock.date.getMonth()
    readonly property var today: clock.date

    function shift(delta: int): void {
        let m = viewMonth + delta, y = viewYear;
        while (m < 0) {
            m += 12;
            y--;
        }
        while (m > 11) {
            m -= 12;
            y++;
        }
        viewMonth = m;
        viewYear = y;
    }
    function resetView(): void {
        viewYear = today.getFullYear();
        viewMonth = today.getMonth();
    }
    // 42 células (6 semanas)
    readonly property var cells: {
        const first = new Date(viewYear, viewMonth, 1);
        const start = new Date(viewYear, viewMonth, 1 - first.getDay());
        const out = [];
        for (let i = 0; i < 42; i++) {
            const d = new Date(start.getFullYear(), start.getMonth(), start.getDate() + i);
            out.push({
                day: d.getDate(),
                inMonth: d.getMonth() === viewMonth,
                isToday: d.getDate() === today.getDate() && d.getMonth() === today.getMonth() && d.getFullYear() === today.getFullYear(),
                weekend: d.getDay() === 0 || d.getDay() === 6
            });
        }
        return out;
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 0
        Txt {
            text: Qt.formatDateTime(clock.date, "HH:mm")
            font.pixelSize: Theme.font.huge
            font.weight: Font.Bold
            font.features: ({ "tnum": 1 })
            color: Theme.primary
            Txt {
                anchors.left: parent.right
                anchors.leftMargin: 4
                anchors.baseline: parent.baseline
                text: Qt.formatDateTime(clock.date, "ss")
                font.pixelSize: Theme.font.large
                dim: true
                font.features: ({ "tnum": 1 })
            }
        }
        Txt {
            text: {
                const s = clock.date.toLocaleDateString(Qt.locale(), "dddd, d 'de' MMMM 'de' yyyy");
                return s.charAt(0).toUpperCase() + s.slice(1);
            }
            dim: true
            font.pixelSize: Theme.font.normal
        }
    }

    Card {
        Layout.fillWidth: true
        padding: 10

        ColumnLayout {
            width: parent.width
            spacing: 6

            RowLayout {
                Layout.fillWidth: true
                Txt {
                    Layout.fillWidth: true
                    Layout.leftMargin: 4
                    text: {
                        const s = new Date(root.viewYear, root.viewMonth, 1).toLocaleDateString(Qt.locale(), "MMMM 'de' yyyy");
                        return s.charAt(0).toUpperCase() + s.slice(1);
                    }
                    font.weight: Font.Bold
                    font.pixelSize: Theme.font.medium
                }
                PillButton {
                    visible: root.viewMonth !== root.today.getMonth() || root.viewYear !== root.today.getFullYear()
                    compact: true
                    text: "Hoje"
                    onClicked: root.resetView()
                }
                IconButton {
                    implicitWidth: 30
                    implicitHeight: 30
                    icon: "chevron_left"
                    onClicked: root.shift(-1)
                }
                IconButton {
                    implicitWidth: 30
                    implicitHeight: 30
                    icon: "chevron_right"
                    onClicked: root.shift(1)
                }
            }

            GridLayout {
                id: grid
                Layout.fillWidth: true
                columns: 7
                rowSpacing: 2
                columnSpacing: 2

                Repeater {
                    model: ["D", "S", "T", "Q", "Q", "S", "S"]
                    delegate: Txt {
                        required property string modelData
                        required property int index
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        font.pixelSize: Theme.font.small
                        font.weight: Font.Bold
                        color: index === 0 || index === 6 ? Theme.tertiary : Theme.surfaceVariantFg
                    }
                }

                Repeater {
                    model: root.cells
                    delegate: Item {
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        Rectangle {
                            anchors.centerIn: parent
                            width: 32
                            height: 32
                            radius: 16
                            color: modelData.isToday ? Theme.primary : "transparent"
                        }
                        Txt {
                            anchors.centerIn: parent
                            text: modelData.day
                            font.pixelSize: Theme.font.normal
                            font.weight: modelData.isToday ? Font.Bold : Font.Medium
                            font.features: ({ "tnum": 1 })
                            color: modelData.isToday ? Theme.primaryFg : !modelData.inMonth ? Theme.alpha(Theme.surfaceVariantFg, 0.4) : modelData.weekend ? Theme.tertiary : Theme.surfaceFg
                        }
                    }
                }
            }
        }

        WheelHandler {
            onWheel: event => root.shift(event.angleDelta.y > 0 ? -1 : 1)
        }
    }
}
