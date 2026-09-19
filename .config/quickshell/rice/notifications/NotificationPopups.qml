import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

// Popups de notificação no canto superior direito do monitor em foco.
PanelWindow {
    id: win

    readonly property var targetScreen: {
        const name = Ui.focusedScreen();
        return Quickshell.screens.find(s => s.name === name) ?? Quickshell.screens[0];
    }

    screen: targetScreen
    anchors {
        top: true
        right: true
    }
    margins {
        top: Theme.barHeight + Theme.barMargin + 8
        right: Theme.barMargin + 2
    }
    implicitWidth: 392
    implicitHeight: Math.max(1, list.contentHeight + 4)
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: Notifs.popups.length > 0 || list.count > 0
    WlrLayershell.namespace: "rice-notifications"
    WlrLayershell.layer: WlrLayer.Overlay

    ListView {
        id: list
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        spacing: 8
        interactive: false
        model: ScriptModel {
            values: Notifs.popups
        }
        delegate: NotificationCard {
            required property var modelData
            notif: modelData
            popup: true
            width: list.width
        }
        add: Transition {
            ParallelAnimation {
                NumberAnimation { property: "x"; from: 420; to: 0; duration: 340; easing.type: Easing.OutCubic }
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 240 }
            }
        }
        remove: Transition {
            ParallelAnimation {
                NumberAnimation { property: "x"; to: 420; duration: 240; easing.type: Easing.InCubic }
                NumberAnimation { property: "opacity"; to: 0; duration: 200 }
            }
        }
        displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 280; easing.type: Easing.OutCubic }
        }
    }
}
