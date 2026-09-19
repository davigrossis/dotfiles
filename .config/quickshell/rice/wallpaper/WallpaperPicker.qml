import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.services
import qs.widgets

// Seletor de wallpapers (estilo Omarchy): grade de miniaturas + preview grande.
// Setas/Tab navegam, digitar filtra, Enter aplica e fecha, Shift+Enter aplica e continua,
// Esc limpa o filtro/fecha. Clique seleciona, duplo clique aplica.
// Aplicar = "waypaper --wallpaper" (mesmo backend awww + apply-theme.sh pelo post_command).
PanelWindow {
    id: win

    property bool shown: Ui.pickerOpen
    property string filter: ""
    readonly property var shownItems: Wallpapers.items.filter(i => filter === "" || i.name.toLowerCase().includes(filter.toLowerCase()))
    readonly property var selected: grid.currentIndex >= 0 && grid.currentIndex < shownItems.length ? shownItems[grid.currentIndex] : null

    screen: {
        const s = Quickshell.screens.find(x => x.name === Ui.pickerScreen);
        return s ?? Quickshell.screens[0];
    }
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: shown || backdrop.opacity > 0.01
    WlrLayershell.namespace: "rice-picker"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    onShownChanged: {
        if (shown) {
            filter = "";
            Wallpapers.rescan();
            selectCurrent();
            grid.forceActiveFocus();
        }
    }

    function selectCurrent(): void {
        const i = shownItems.findIndex(x => x.path === Wallpapers.current);
        grid.currentIndex = i >= 0 ? i : 0;
        grid.positionViewAtIndex(grid.currentIndex, GridView.Contain);
    }
    function apply(close: bool): void {
        if (!selected)
            return;
        Wallpapers.apply(selected.path);
        if (close)
            Ui.pickerOpen = false;
    }

    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Theme.alpha(Theme.scrim, 0.42)
        opacity: win.shown ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: Ui.pickerOpen = false
        }
    }

    Rectangle {
        id: card
        width: Math.min(1180, win.width - 80)
        height: Math.min(700, win.height - 90)
        anchors.centerIn: parent
        radius: 26
        color: Theme.alpha(Theme.surfaceContainerLow, 0.94)
        border.width: 1
        border.color: Theme.borderColor
        opacity: win.shown ? 1 : 0
        scale: win.shown ? 1 : 0.95
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
        }
        MouseArea {
            anchors.fill: parent
        }   // engole cliques dentro do cartão

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            // ── Cabeçalho ───────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: 20
                    color: Theme.alpha(Theme.primary, 0.16)
                    MIcon {
                        anchors.centerIn: parent
                        icon: "wallpaper"
                        fill: 1
                        size: 22
                        color: Theme.primary
                    }
                }
                ColumnLayout {
                    spacing: 0
                    Txt {
                        text: "Wallpapers"
                        font.pixelSize: Theme.font.title
                        font.weight: Font.Bold
                    }
                    Txt {
                        text: Wallpapers.items.length + " imagens · " + Wallpapers.folder.replace(Quickshell.env("HOME"), "~") + (Wallpapers.generating ? " · gerando miniaturas…" : "")
                        dim: true
                        font.pixelSize: Theme.font.small
                    }
                }
                Item {
                    Layout.fillWidth: true
                }
                Rectangle {
                    Layout.preferredWidth: 240
                    Layout.preferredHeight: 38
                    radius: 19
                    color: Theme.alpha(Theme.surfaceContainerHighest, 0.9)
                    border.width: 1
                    border.color: win.filter !== "" ? Theme.primary : Theme.outlineVariant
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8
                        MIcon {
                            icon: "search"
                            size: 18
                            color: Theme.surfaceVariantFg
                        }
                        Txt {
                            Layout.fillWidth: true
                            text: win.filter !== "" ? win.filter : "Digite para filtrar…"
                            dim: win.filter === ""
                            elide: Text.ElideLeft
                        }
                    }
                }
                IconButton {
                    icon: "close"
                    onClicked: Ui.pickerOpen = false
                }
            }

            // ── Corpo: preview + grade ──────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 18

                ColumnLayout {
                    readonly property int w: Math.round((card.width - 36) * 0.56)
                    Layout.preferredWidth: w
                    Layout.maximumWidth: w
                    Layout.minimumWidth: w
                    Layout.fillWidth: false
                    Layout.fillHeight: true
                    spacing: 12

                    ClippingRectangle {
                        id: preview
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.round(width * 9 / 16)
                        radius: 18
                        color: Theme.surfaceContainerHigh

                        Image {
                            // miniatura já carregada fica por baixo enquanto a prévia grande carrega
                            anchors.fill: parent
                            source: win.selected ? Wallpapers.thumbFor(win.selected.path) : ""
                            fillMode: Image.PreserveAspectCrop
                            sourceSize.width: 480
                            sourceSize.height: 270
                            asynchronous: true
                        }
                        Image {
                            id: big
                            property bool fallback: false
                            anchors.fill: parent
                            source: win.selected ? (fallback ? "file://" + win.selected.path : Wallpapers.previewFor(win.selected.path)) : ""
                            fillMode: Image.PreserveAspectCrop
                            sourceSize.width: 1280
                            sourceSize.height: 720
                            asynchronous: true
                            opacity: status === Image.Ready ? 1 : 0
                            Behavior on opacity {
                                NumberAnimation { duration: 180 }
                            }
                            onStatusChanged: if (status === Image.Error && !fallback)
                                fallback = true
                            Connections {
                                target: win
                                function onSelectedChanged() {
                                    big.fallback = false;
                                }
                            }
                        }
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: 64
                            gradient: Gradient {
                                GradientStop {
                                    position: 0
                                    color: "transparent"
                                }
                                GradientStop {
                                    position: 1
                                    color: Qt.rgba(0, 0, 0, 0.62)
                                }
                            }
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 14
                                Text {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignBottom
                                    text: win.selected ? win.selected.name : ""
                                    color: "white"
                                    font.family: Theme.font.sans
                                    font.pixelSize: Theme.font.medium
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideMiddle
                                }
                                Rectangle {
                                    visible: win.selected !== null && win.selected.path === Wallpapers.current
                                    Layout.alignment: Qt.AlignBottom
                                    implicitWidth: curTxt.implicitWidth + 18
                                    implicitHeight: 24
                                    radius: 12
                                    color: Theme.primary
                                    Txt {
                                        id: curTxt
                                        anchors.centerIn: parent
                                        text: "ATUAL"
                                        font.pixelSize: Theme.font.small - 1
                                        font.weight: Font.Bold
                                        color: Theme.primaryFg
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        PillButton {
                            variant: "filled"
                            icon: "check"
                            text: Wallpapers.applying !== "" ? "Aplicando…" : "Aplicar"
                            onClicked: win.apply(true)
                        }
                        PillButton {
                            variant: "tonal"
                            icon: "visibility"
                            text: "Aplicar e continuar"
                            onClicked: win.apply(false)
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    Txt {
                        Layout.fillWidth: true
                        text: "↑ ↓ ← →  navegar   ·   Enter  aplicar   ·   Shift+Enter  aplicar sem fechar   ·   digite para filtrar   ·   Esc  fechar"
                        dim: true
                        wrapMode: Text.Wrap
                        font.pixelSize: Theme.font.small
                    }
                    Item {
                        Layout.fillHeight: true
                    }
                }

                GridView {
                    id: grid

                    Txt {
                        anchors.centerIn: parent
                        visible: grid.count === 0
                        text: win.filter !== "" ? "Nenhum wallpaper com \"" + win.filter + "\"  ·  Backspace apaga" : "Nenhuma imagem na pasta"
                        dim: true
                    }
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumWidth: 280
                    implicitWidth: 400
                    clip: true
                    focus: true
                    readonly property int cols: width > 520 ? 3 : 2
                    cellWidth: Math.floor(width / cols)
                    cellHeight: Math.round(cellWidth * 9 / 16) + 10
                    boundsBehavior: Flickable.StopAtBounds
                    keyNavigationEnabled: true
                    highlightMoveDuration: 120
                    model: ScriptModel {
                        values: win.shownItems
                        objectProp: "path"
                    }

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            if (win.filter !== "")
                                win.filter = "";
                            else
                                Ui.pickerOpen = false;
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            win.apply(!(event.modifiers & Qt.ShiftModifier));
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Backspace) {
                            win.filter = win.filter.slice(0, -1);
                            grid.currentIndex = 0;
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Tab) {
                            grid.moveCurrentIndexRight();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Backtab) {
                            grid.moveCurrentIndexLeft();
                            event.accepted = true;
                        } else if (event.text !== "" && event.text >= " " && !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))) {
                            win.filter += event.text;
                            grid.currentIndex = 0;
                            event.accepted = true;
                        }
                    }

                    delegate: Item {
                        id: cell
                        required property var modelData
                        required property int index
                        readonly property bool isSel: GridView.isCurrentItem
                        readonly property bool isCur: modelData.path === Wallpapers.current
                        width: grid.cellWidth
                        height: grid.cellHeight

                        ClippingRectangle {
                            id: thumbBox
                            anchors.fill: parent
                            anchors.margins: 5
                            radius: 14
                            color: Theme.surfaceContainerHigh
                            scale: cell.isSel ? 1 : (hover.containsMouse ? 0.98 : 0.95)
                            Behavior on scale {
                                NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
                            }

                            Image {
                                id: thumb
                                property bool fallback: false
                                anchors.fill: parent
                                source: fallback ? "file://" + cell.modelData.path : Wallpapers.thumbFor(cell.modelData.path)
                                fillMode: Image.PreserveAspectCrop
                                sourceSize.width: 480
                                sourceSize.height: 270
                                asynchronous: true
                                cache: true
                                onStatusChanged: if (status === Image.Error && !fallback)
                                    fallback = true
                                Connections {
                                    target: Wallpapers
                                    function onThumbsVersionChanged() {
                                        thumb.fallback = false;
                                    }
                                }
                            }
                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                radius: 14
                                border.width: cell.isSel ? 3 : 0
                                border.color: Theme.primary
                            }
                            Rectangle {
                                visible: cell.isCur
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.margins: 8
                                width: 24
                                height: 24
                                radius: 12
                                color: Theme.primary
                                MIcon {
                                    anchors.centerIn: parent
                                    icon: "check"
                                    size: 16
                                    weight: 700
                                    color: Theme.primaryFg
                                }
                            }
                        }

                        MouseArea {
                            id: hover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                grid.currentIndex = cell.index;
                                grid.forceActiveFocus();
                            }
                            onDoubleClicked: {
                                grid.currentIndex = cell.index;
                                win.apply(true);
                            }
                        }
                    }
                }
            }
        }
    }
}
