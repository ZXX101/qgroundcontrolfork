import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl.FactSystem
import QGroundControl.Palette
import QGroundControl.Controls
import QGroundControl.ScreenTools

Item {
    id: root

    property Fact fact: Fact { }

    implicitWidth: buttonRow.implicitWidth + buttonBackground.border.width * 2
    implicitHeight: ScreenTools.implicitComboBoxHeight

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    Rectangle {
        id: buttonBackground
        anchors.fill: parent
        color: qgcPal.button
        border.color: qgcPal.globalTheme === QGCPalette.Light ? qgcPal.buttonBorder : qgcPal.button
        border.width: qgcPal.globalTheme === QGCPalette.Light ? 1 : 0
        radius: ScreenTools.buttonBorderRadius

        RowLayout {
            id: buttonRow
            anchors.fill: parent
            anchors.leftMargin: ScreenTools.defaultFontPixelWidth / 2
            anchors.rightMargin: ScreenTools.defaultFontPixelWidth / 2
            spacing: ScreenTools.defaultFontPixelWidth / 2

            QGCLabel {
                Layout.fillWidth: true
                text: fact.selectedBitmaskStrings.join(", ")
                elide: Text.ElideRight
                color: qgcPal.buttonText
            }

            QGCColoredImage {
                Layout.alignment: Qt.AlignVCenter
                height: ScreenTools.defaultFontPixelWidth
                width: height
                source: "/qmlimages/arrow-down.png"
                color: qgcPal.buttonText
            }
        }

        QGCMouseArea {
            anchors.fill: parent
            onClicked: {
                if (popup.visible) {
                    popup.close()
                } else {
                    popup.open()
                }
            }
        }
    }

    Popup {
        id: popup
        parent: Overlay.overlay
        x: root.mapToGlobal(0, 0).x
        y: root.mapToGlobal(0, buttonBackground.height).y
        width: Math.max(root.width, popupContent.implicitWidth + padding * 2)
        padding: ScreenTools.defaultFontPixelWidth / 2
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: qgcPal.window
            border.color: qgcPal.text
            border.width: 1
            radius: ScreenTools.buttonBorderRadius
        }

        contentItem: Column {
            id: popupContent
            spacing: 0

            Repeater {
                model: fact.bitmaskStrings

                delegate: QGCCheckBox {
                    width: popupContent.width
                    text: modelData
                    checked: fact.value & fact.bitmaskValues[index]

                    onClicked: {
                        if (checked) {
                            fact.value = fact.value | fact.bitmaskValues[index]
                        } else {
                            fact.value = fact.value & ~fact.bitmaskValues[index]
                        }
                    }
                }
            }
        }
    }
}
