import QtQuick
import QtQuick.Layouts
import qs.services

// Título pequeno de seção dentro de um painel.
Txt {
    Layout.fillWidth: true
    Layout.topMargin: 4
    font.pixelSize: Theme.font.small
    font.weight: Font.DemiBold
    font.letterSpacing: 0.6
    font.capitalization: Font.AllUppercase
    color: Theme.surfaceVariantFg
}
