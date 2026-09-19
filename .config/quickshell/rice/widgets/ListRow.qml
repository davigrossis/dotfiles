import QtQuick
import QtQuick.Layouts
import qs.services

// Linha de lista clicável (redes, dispositivos, saídas de áudio...).
StateLayer {
    id: root

    property string icon: ""
    property real iconFill: 0
    property color iconColor: highlighted ? Theme.primary : Theme.surfaceVariantFg
    property string title: ""
    property string subtitle: ""
    property bool highlighted: false
    default property alias trailing: trailingRow.data

    implicitHeight: subtitle !== "" ? 50 : 40
    implicitWidth: 300
    radius: Theme.radius.normal
    active: highlighted
    activeColor: Theme.alpha(Theme.primary, 0.14)

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 8
        spacing: 10

        MIcon {
            visible: root.icon !== ""
            Layout.preferredWidth: 24
            icon: root.icon
            size: 20
            fill: root.iconFill
            color: root.iconColor
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1
            Txt {
                Layout.fillWidth: true
                text: root.title
                elide: Text.ElideRight
                font.weight: root.highlighted ? Font.DemiBold : Font.Normal
                color: root.highlighted ? Theme.primary : Theme.surfaceFg
            }
            Txt {
                Layout.fillWidth: true
                visible: root.subtitle !== ""
                text: root.subtitle
                elide: Text.ElideRight
                dim: true
                font.pixelSize: Theme.font.small
            }
        }

        Row {
            id: trailingRow
            Layout.alignment: Qt.AlignVCenter
            spacing: 4
        }
    }
}
