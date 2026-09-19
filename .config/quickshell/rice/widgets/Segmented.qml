import QtQuick
import QtQuick.Layouts
import qs.services

// Botões segmentados (ex.: perfil de energia, esquema de cores).
// model: [{ key, label, icon }]
Rectangle {
    id: root

    property var model: []
    property string current: ""
    signal selected(string key)

    implicitHeight: 34
    radius: Theme.radius.full
    color: Theme.alpha(Theme.surfaceContainerHighest, 0.7)

    RowLayout {
        anchors.fill: parent
        anchors.margins: 3
        spacing: 3

        Repeater {
            model: root.model
            delegate: StateLayer {
                required property var modelData
                readonly property bool sel: root.current === modelData.key
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Theme.radius.full
                baseColor: sel ? Theme.primary : "transparent"
                stateColor: sel ? Theme.primaryFg : Theme.surfaceFg
                onClicked: root.selected(modelData.key)

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    MIcon {
                        visible: (modelData.icon || "") !== ""
                        icon: modelData.icon || ""
                        size: 16
                        fill: sel ? 1 : 0
                        color: sel ? Theme.primaryFg : Theme.surfaceVariantFg
                    }
                    Txt {
                        visible: (modelData.label || "") !== ""
                        text: modelData.label || ""
                        font.pixelSize: Theme.font.small
                        font.weight: sel ? Font.DemiBold : Font.Medium
                        color: sel ? Theme.primaryFg : Theme.surfaceVariantFg
                    }
                }
            }
        }
    }
}
