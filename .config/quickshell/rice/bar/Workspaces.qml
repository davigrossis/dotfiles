import QtQuick
import Quickshell
import qs.services
import qs.widgets

// Workspaces do monitor (ou desktops virtuais, se o plugin estiver carregado).
// Clique = ir para; rolagem = próximo/anterior (igual a SUPER+rolagem).
Item {
    id: root

    required property string screenName

    implicitWidth: row.implicitWidth + 4
    implicitHeight: Theme.barHeight - 8

    ScriptModel {
        id: wsModel
        objectProp: Desktops.vdeskMode ? "id" : ""
        values: Desktops.vdeskMode ? Desktops.vdesks : Desktops.workspacesFor(root.screenName)
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => {
            const d = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : -wheel.angleDelta.x;
            if (d < 0)
                Desktops.next();
            else
                Desktops.prev();
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 3

        Repeater {
            model: wsModel
            delegate: StateLayer {
                id: ws
                required property var modelData
                readonly property bool vd: Desktops.vdeskMode
                readonly property bool current: vd ? modelData.focused : modelData.active
                readonly property bool occupied: vd ? modelData.populated : (modelData.toplevels ? modelData.toplevels.values.length > 0 : false)
                readonly property bool urgent: !vd && modelData.urgent

                width: current ? 36 : 24
                height: 22
                anchors.verticalCenter: parent.verticalCenter
                radius: 11
                baseColor: current ? Theme.primary : urgent ? Theme.error : occupied ? Theme.alpha(Theme.surfaceFg, 0.12) : "transparent"
                stateColor: current ? Theme.primaryFg : Theme.surfaceFg
                onClicked: Desktops.activate(modelData.id)

                Behavior on width {
                    NumberAnimation { duration: Theme.anim.normal; easing.type: Easing.OutCubic }
                }

                Txt {
                    anchors.centerIn: parent
                    text: ws.modelData.name
                    mono: true
                    font.pixelSize: Theme.font.small + 1
                    font.weight: ws.current ? Font.Bold : Font.DemiBold
                    color: ws.current ? Theme.primaryFg : ws.urgent ? Theme.errorFg : ws.occupied ? Theme.surfaceFg : Theme.alpha(Theme.surfaceVariantFg, 0.7)
                }
            }
        }
    }
}
