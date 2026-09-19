import QtQuick
import QtQuick.Layouts
import qs.services

// Bloco de "central de controle": ícone + título + subtítulo; clique alterna,
// seta (opcional) abre o painel detalhado.
StateLayer {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool checked: false
    property bool hasDetails: false
    signal toggled
    signal detailsRequested

    implicitHeight: 58
    implicitWidth: 180
    radius: Theme.radius.large
    baseColor: checked ? Theme.primaryContainer : Theme.cardBg
    stateColor: checked ? Theme.primaryContainerFg : Theme.surfaceFg
    onClicked: mouse => {
        if (mouse.button === Qt.RightButton && hasDetails)
            root.detailsRequested();
        else
            root.toggled();
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: root.hasDetails ? 4 : 12
        spacing: 10

        Rectangle {
            Layout.preferredWidth: 34
            Layout.preferredHeight: 34
            radius: 17
            color: root.checked ? Theme.primary : Theme.alpha(Theme.surfaceContainerHighest, 0.9)
            Behavior on color { ColorAnimation { duration: Theme.anim.normal } }
            MIcon {
                anchors.centerIn: parent
                icon: root.icon
                size: 19
                fill: root.checked ? 1 : 0
                color: root.checked ? Theme.primaryFg : Theme.surfaceVariantFg
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Txt {
                Layout.fillWidth: true
                text: root.title
                font.pixelSize: Theme.font.normal
                font.weight: Font.DemiBold
                elide: Text.ElideRight
                color: root.checked ? Theme.primaryContainerFg : Theme.surfaceFg
            }
            Txt {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.subtitle
                font.pixelSize: Theme.font.small
                elide: Text.ElideRight
                color: root.checked ? Theme.alpha(Theme.primaryContainerFg, 0.8) : Theme.surfaceVariantFg
            }
        }

        StateLayer {
            visible: root.hasDetails
            Layout.preferredWidth: 30
            Layout.fillHeight: true
            Layout.topMargin: 6
            Layout.bottomMargin: 6
            radius: Theme.radius.normal
            stateColor: root.checked ? Theme.primaryContainerFg : Theme.surfaceFg
            onClicked: root.detailsRequested()
            MIcon {
                anchors.centerIn: parent
                icon: "chevron_right"
                size: 20
                color: root.checked ? Theme.primaryContainerFg : Theme.surfaceVariantFg
            }
        }
    }
}
