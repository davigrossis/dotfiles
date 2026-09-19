import QtQuick
import QtQuick.Layouts
import qs.services

// Base de todos os painéis: largura fixa, altura limitada pela tela, coluna com margens.
Item {
    id: root

    property real maxHeight: 700
    property real panelWidth: 380
    property real spacing: 10
    default property alias content: col.data

    implicitWidth: panelWidth
    implicitHeight: Math.min(maxHeight, col.implicitHeight + Theme.padding * 2)

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: Theme.padding
        spacing: root.spacing
    }
}
