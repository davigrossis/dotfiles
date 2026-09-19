import QtQuick
import QtQuick.Layouts
import qs.services

// Cabeçalho de painel: ícone + título (+ subtítulo) e controles à direita.
RowLayout {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    default property alias trailing: trailingRow.data

    spacing: 10
    Layout.fillWidth: true

    Rectangle {
        visible: root.icon !== ""
        Layout.preferredWidth: 36
        Layout.preferredHeight: 36
        radius: 18
        color: Theme.alpha(Theme.primary, 0.16)
        MIcon {
            anchors.centerIn: parent
            icon: root.icon
            size: 20
            fill: 1
            color: Theme.primary
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 0
        Txt {
            text: root.title
            font.pixelSize: Theme.font.large
            font.weight: Font.Bold
        }
        Txt {
            visible: root.subtitle !== ""
            Layout.fillWidth: true
            text: root.subtitle
            dim: true
            font.pixelSize: Theme.font.small
            elide: Text.ElideRight
        }
    }

    Row {
        id: trailingRow
        Layout.alignment: Qt.AlignVCenter
        spacing: 6
    }
}
