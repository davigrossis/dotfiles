import QtQuick
import QtQuick.Layouts
import qs.services

// Campo de texto (ex.: senha de Wi-Fi) com botão de mostrar/ocultar.
Rectangle {
    id: root

    property alias text: input.text
    property string placeholder: ""
    property bool password: false
    property bool revealed: false
    signal accepted
    function focusInput() {
        input.forceActiveFocus();
    }

    implicitHeight: 38
    implicitWidth: 240
    radius: Theme.radius.normal
    color: Theme.alpha(Theme.surfaceContainerHighest, 0.9)
    border.width: input.activeFocus ? 2 : 1
    border.color: input.activeFocus ? Theme.primary : Theme.outlineVariant

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 4
        spacing: 4

        TextInput {
            id: input
            Layout.fillWidth: true
            clip: true
            color: Theme.surfaceFg
            selectionColor: Theme.primary
            selectedTextColor: Theme.primaryFg
            font.family: Theme.font.sans
            font.pixelSize: Theme.font.normal
            echoMode: root.password && !root.revealed ? TextInput.Password : TextInput.Normal
            verticalAlignment: TextInput.AlignVCenter
            onAccepted: root.accepted()
            Keys.onEscapePressed: event => {
                event.accepted = false;
            }

            Txt {
                anchors.fill: parent
                visible: input.text === ""
                text: root.placeholder
                dim: true
            }
        }

        IconButton {
            visible: root.password
            implicitWidth: 30
            implicitHeight: 30
            icon: root.revealed ? "visibility_off" : "visibility"
            iconSize: 18
            onClicked: root.revealed = !root.revealed
        }
    }
}
