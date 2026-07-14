import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T

import QGroundControl.FactSystem
import QGroundControl.Palette
import QGroundControl.Controls
import QGroundControl.ScreenTools

T.ComboBox {
    id:             control
    padding:        ScreenTools.comboBoxPadding
    spacing:        ScreenTools.defaultFontPixelWidth
    font.pointSize: ScreenTools.defaultFontPointSize
    font.family:    ScreenTools.normalFontFamily
    implicitWidth:  Math.max(background ? background.implicitWidth : 0,
                             contentItem.implicitWidth + leftPadding + rightPadding + padding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             Math.max(contentItem.implicitHeight, indicator ? indicator.implicitHeight : 0) + topPadding + bottomPadding)
    leftPadding:    padding + (!control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
    rightPadding:   padding + (control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width)

    property Fact   fact: Fact { }
    property bool   _showBorder: qgcPal.globalTheme === QGCPalette.Light

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    model: fact.bitmaskStrings

    currentIndex: -1

    delegate: ItemDelegate {
        width: control.width
        height: Math.round(popupItemMetrics.height * 2)

        property string _text: modelData

        TextMetrics {
            id:     popupItemMetrics
            font:   control.font
            text:   _text
        }

        contentItem: Row {
            spacing: ScreenTools.defaultFontPixelWidth / 2

            Rectangle {
                width:                  ScreenTools.implicitCheckBoxHeight
                height:                 width
                anchors.verticalCenter: parent.verticalCenter
                border.color:           qgcPal.text
                border.width:           1
                radius:                 ScreenTools.buttonBorderRadius
                color:                  qgcPal.window

                QGCColoredImage {
                    anchors.centerIn:   parent
                    width:              parent.width * 0.75
                    height:             width
                    source:             "/qmlimages/checkbox-check.svg"
                    color:              qgcPal.text
                    mipmap:             true
                    fillMode:           Image.PreserveAspectFit
                    sourceSize.height:  height
                    visible:            fact.value & fact.bitmaskValues[index]
                }
            }

            Text {
                text:                   _text
                font:                   control.font
                color:                  qgcPal.buttonText
                verticalAlignment:      Text.AlignVCenter
            }
        }

        background: Rectangle {
            color: qgcPal.button
        }

        highlighted: control.highlightedIndex === index

        MouseArea {
            anchors.fill: parent
            onClicked: (mouse) => {
                mouse.accepted = true
                var bv = fact.bitmaskValues[index]
                if (fact.value & bv) {
                    fact.value = fact.value & ~bv
                } else {
                    fact.value = fact.value | bv
                }
            }
        }
    }

    indicator: QGCColoredImage {
        anchors.rightMargin:    control.padding
        anchors.right:          parent.right
        anchors.verticalCenter: parent.verticalCenter
        height:                 ScreenTools.defaultFontPixelWidth
        width:                  height
        source:                 "/qmlimages/arrow-down.png"
        color:                  qgcPal.buttonText
    }

    contentItem: QGCLabel {
        anchors.verticalCenter: parent.verticalCenter
        text:                   fact.selectedBitmaskStrings.join(", ")
        font:                   control.font
        color:                  qgcPal.buttonText
        elide:                  Text.ElideRight
    }

    background: Rectangle {
        color:          qgcPal.button
        border.color:   qgcPal.buttonBorder
        border.width:   _showBorder ? 1 : 0
        radius:         ScreenTools.buttonBorderRadius
    }

    popup: T.Popup {
        y:      control.height
        width:  control.width
        height: Math.min(contentItem.implicitHeight, control.Window.height - topMargin - bottomMargin)
        topMargin:      6
        bottomMargin:   6

        contentItem: ListView {
            clip:                   true
            implicitHeight:         contentHeight
            model:                  control.delegateModel
            currentIndex:           control.highlightedIndex
            highlightMoveDuration:  0

            Rectangle {
                z:              10
                width:          parent.width
                height:         parent.height
                color:          "transparent"
                border.color:   qgcPal.text
            }

            T.ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            color: qgcPal.window
        }
    }
}
