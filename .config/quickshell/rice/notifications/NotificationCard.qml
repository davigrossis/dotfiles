import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs.services
import qs.widgets

// Cartão de notificação (popup e central). Clique = ação padrão; botão do meio/direito
// ou "x" = dispensar. Em popup, a barrinha inferior mostra o tempo restante (pausa no hover).
Rectangle {
    id: root

    required property var notif
    property bool popup: false
    readonly property bool critical: notif !== null && notif.urgency === NotificationUrgency.Critical
    readonly property int timeoutMs: popup && notif ? Notifs.timeout(notif) : 0
    readonly property string icon: Notifs.iconSource(notif)
    readonly property bool hasImage: notif !== null && (notif.image || "") !== ""
    property real progress: 1

    implicitWidth: 380
    implicitHeight: content.implicitHeight + 24
    radius: 18
    color: popup ? Theme.alpha(Theme.surfaceContainer, 0.92) : Theme.cardBg
    border.width: 1
    border.color: critical ? Theme.error : Theme.borderColor

    NumberAnimation {
        id: life
        target: root
        property: "progress"
        from: 1
        to: 0
        duration: Math.max(1, root.timeoutMs)
        running: root.popup && root.timeoutMs > 0
        paused: running && hover.containsMouse
        onFinished: Notifs.hidePopup(root.notif)
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button !== Qt.LeftButton) {
                Notifs.dismiss(root.notif);
                return;
            }
            if (Notifs.invokeDefault(root.notif))
                Notifs.dismiss(root.notif);
            else if (root.popup)
                Notifs.hidePopup(root.notif);
        }
    }

    RowLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 12

        // imagem da notificação (avatar/capa) ou ícone do app
        Item {
            Layout.preferredWidth: 42
            Layout.preferredHeight: 42
            Layout.alignment: Qt.AlignTop

            ClippingRectangle {
                anchors.fill: parent
                radius: 12
                color: Theme.alpha(Theme.primary, 0.15)
                visible: root.hasImage
                Image {
                    anchors.fill: parent
                    source: root.hasImage ? root.notif.image : ""
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: 84
                    sourceSize.height: 84
                    asynchronous: true
                }
            }
            Rectangle {
                anchors.fill: parent
                radius: 21
                visible: !root.hasImage
                color: root.critical ? Theme.errorContainer : Theme.alpha(Theme.primary, 0.16)
                IconImage {
                    id: appIcon
                    anchors.centerIn: parent
                    implicitSize: 24
                    visible: root.icon !== "" && status === Image.Ready
                    source: root.icon
                }
                MIcon {
                    anchors.centerIn: parent
                    visible: !appIcon.visible
                    icon: root.critical ? "priority_high" : "notifications"
                    fill: 1
                    size: 22
                    color: root.critical ? Theme.errorContainerFg : Theme.primary
                }
            }
            // selo com o ícone do app quando há imagem
            Rectangle {
                visible: root.hasImage && root.icon !== ""
                width: 20
                height: 20
                radius: 10
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: -4
                anchors.bottomMargin: -4
                color: Theme.surfaceContainerHigh
                IconImage {
                    anchors.centerIn: parent
                    implicitSize: 14
                    source: root.icon
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            RowLayout {
                Layout.fillWidth: true
                spacing: 4
                Txt {
                    text: root.notif ? (root.notif.appName || "Notificação") : ""
                    font.pixelSize: Theme.font.small
                    font.weight: Font.DemiBold
                    color: root.critical ? Theme.error : Theme.primary
                    elide: Text.ElideRight
                    Layout.maximumWidth: 180
                }
                Txt {
                    text: "· " + (Notifs.tick, Notifs.ago(root.notif))
                    font.pixelSize: Theme.font.small
                    dim: true
                }
                Item {
                    Layout.fillWidth: true
                }
                IconButton {
                    implicitWidth: 24
                    implicitHeight: 24
                    icon: "close"
                    iconSize: 15
                    onClicked: Notifs.dismiss(root.notif)
                }
            }

            Txt {
                Layout.fillWidth: true
                text: root.notif ? root.notif.summary : ""
                font.pixelSize: Theme.font.normal
                font.weight: Font.DemiBold
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.notif ? Notifs.cleanBody(root.notif.body) : ""
                textFormat: Text.StyledText
                wrapMode: Text.Wrap
                maximumLineCount: root.popup ? 4 : 8
                elide: Text.ElideRight
                color: Theme.surfaceVariantFg
                linkColor: Theme.primary
                font.family: Theme.font.sans
                font.pixelSize: Theme.font.small + 1
                onLinkActivated: link => Qt.openUrlExternally(link)
            }

            Flow {
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: 6
                visible: actionRepeater.count > 0
                Repeater {
                    id: actionRepeater
                    model: root.notif ? root.notif.actions.filter(a => a.identifier !== "default" && a.text !== "") : []
                    delegate: PillButton {
                        required property var modelData
                        compact: true
                        variant: "tonal"
                        text: modelData.text
                        onClicked: {
                            modelData.invoke();
                            Notifs.hidePopup(root.notif);
                        }
                    }
                }
            }
        }
    }

    // tempo restante do popup
    Rectangle {
        visible: root.popup && root.timeoutMs > 0
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.bottomMargin: 1
        anchors.leftMargin: 14
        height: 2
        radius: 1
        width: (parent.width - 28) * root.progress
        color: Theme.alpha(Theme.primary, 0.7)
    }
}
