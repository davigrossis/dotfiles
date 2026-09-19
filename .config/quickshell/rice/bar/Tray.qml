import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.services
import qs.widgets

// Bandeja do sistema (StatusNotifierItem): esquerdo = ativar, direito = menu,
// meio = ação secundária, rolagem = scroll do item.
Row {
    id: root

    spacing: 1
    visible: SystemTray.items.values.length > 0

    Repeater {
        model: SystemTray.items
        delegate: StateLayer {
            id: item
            required property SystemTrayItem modelData

            width: Theme.barHeight - 10
            height: Theme.barHeight - 10
            radius: Theme.radius.small
            anchors.verticalCenter: parent.verticalCenter

            onClicked: mouse => {
                if (mouse.button === Qt.MiddleButton) {
                    modelData.secondaryActivate();
                } else if (mouse.button === Qt.RightButton || modelData.onlyMenu) {
                    if (modelData.hasMenu)
                        menu.open();
                } else {
                    modelData.activate();
                }
            }
            onWheel: wheel => modelData.scroll(wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.angleDelta.x, wheel.angleDelta.y === 0)

            IconImage {
                anchors.centerIn: parent
                implicitSize: 17
                source: item.modelData.icon
            }

            QsMenuAnchor {
                id: menu
                menu: item.modelData.menu
                anchor.item: item
                anchor.edges: Edges.Bottom
                anchor.gravity: Edges.Bottom
                anchor.margins.top: 8
            }
        }
    }
}
