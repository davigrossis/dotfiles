import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import qs.services

// Medidor circular (CPU, RAM, temperatura).
Item {
    id: root

    property real value: 0          // 0..1
    property string label: ""
    property string valueText: Math.round(value * 100) + "%"
    property string icon: ""
    property color accent: Theme.primary
    property real thickness: 7

    implicitWidth: 92
    implicitHeight: 92

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: Theme.alpha(Theme.surfaceContainerHighest, 0.9)
            strokeWidth: root.thickness
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.width / 2 - root.thickness
                radiusY: root.height / 2 - root.thickness
                startAngle: 135
                sweepAngle: 270
            }
        }
        ShapePath {
            strokeColor: root.accent
            strokeWidth: root.thickness
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.width / 2 - root.thickness
                radiusY: root.height / 2 - root.thickness
                startAngle: 135
                sweepAngle: Math.max(0.5, 270 * Math.max(0, Math.min(1, root.value)))
                Behavior on sweepAngle {
                    NumberAnimation { duration: Theme.anim.slow; easing.type: Easing.OutCubic }
                }
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: -2
        MIcon {
            visible: root.icon !== ""
            Layout.alignment: Qt.AlignHCenter
            icon: root.icon
            size: 16
            color: root.accent
        }
        Txt {
            Layout.alignment: Qt.AlignHCenter
            text: root.valueText
            mono: true
            font.pixelSize: Theme.font.medium
            font.weight: Font.Bold
        }
        Txt {
            Layout.alignment: Qt.AlignHCenter
            text: root.label
            dim: true
            font.pixelSize: Theme.font.small - 1
        }
    }
}
