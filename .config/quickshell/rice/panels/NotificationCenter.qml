import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.widgets
import qs.notifications

// Central de notificações: histórico, dispensar/limpar e modo Não Perturbe.
PanelBase {
    id: root

    panelWidth: 404
    Component.onCompleted: Notifs.markRead()

    PanelHeader {
        icon: "notifications"
        title: "Notificações"
        subtitle: Notifs.count > 0 ? Notifs.count + (Notifs.count === 1 ? " notificação" : " notificações") : "Tudo em dia"
        PillButton {
            visible: Notifs.count > 0
            compact: true
            variant: "outline"
            icon: "clear_all"
            text: "Limpar"
            onClicked: Notifs.clearAll()
        }
    }

    Card {
        Layout.fillWidth: true
        padding: 10
        RowLayout {
            width: parent.width
            spacing: 10
            MIcon {
                icon: "do_not_disturb_on"
                size: 20
                fill: Notifs.dnd ? 1 : 0
                color: Notifs.dnd ? Theme.primary : Theme.surfaceVariantFg
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                Txt {
                    text: "Não perturbe"
                    font.weight: Font.DemiBold
                }
                Txt {
                    Layout.fillWidth: true
                    text: "Esconde os popups (urgentes ainda aparecem)"
                    dim: true
                    font.pixelSize: Theme.font.small
                    elide: Text.ElideRight
                }
            }
            RSwitch {
                checked: Notifs.dnd
                onToggled: v => Notifs.dnd = v
            }
        }
    }

    ListView {
        id: list
        visible: count > 0
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(contentHeight, root.maxHeight - 190)
        clip: true
        spacing: 8
        boundsBehavior: Flickable.StopAtBounds
        model: ScriptModel {
            values: Notifs.list
        }
        delegate: NotificationCard {
            required property var modelData
            notif: modelData
            popup: false
            width: list.width
        }
        remove: Transition {
            ParallelAnimation {
                NumberAnimation { property: "x"; to: 420; duration: 220; easing.type: Easing.InCubic }
                NumberAnimation { property: "opacity"; to: 0; duration: 200 }
            }
        }
        displaced: Transition {
            NumberAnimation { properties: "y"; duration: 240; easing.type: Easing.OutCubic }
        }
    }

    ColumnLayout {
        visible: list.count === 0
        Layout.fillWidth: true
        Layout.topMargin: 20
        Layout.bottomMargin: 24
        spacing: 8
        MIcon {
            Layout.alignment: Qt.AlignHCenter
            icon: Notifs.dnd ? "notifications_off" : "notifications_active"
            size: 48
            color: Theme.alpha(Theme.surfaceVariantFg, 0.6)
        }
        Txt {
            Layout.alignment: Qt.AlignHCenter
            text: "Nenhuma notificação"
            font.weight: Font.DemiBold
        }
        Txt {
            Layout.alignment: Qt.AlignHCenter
            text: "Você está em dia."
            dim: true
            font.pixelSize: Theme.font.small
        }
    }
}
