/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.ScreenTools

Rectangle {
    id:         _root
    color:      qgcPal.toolbarBackground
    width:      ScreenTools.defaultFontPixelWidth * 8
    height:     Math.min(parent.height, column.height + ScreenTools.defaultFontPixelWidth * 2)
    radius:     ScreenTools.defaultFontPixelWidth / 2

    signal waypointClicked
    signal roiClicked
    signal vehicleClicked
    signal fenceClicked

    ColumnLayout {
        id:                     column
        anchors.margins:        ScreenTools.defaultFontPixelWidth
        anchors.left:           parent.left
        anchors.right:          parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing:                ScreenTools.defaultFontPixelWidth / 2

        QGCLabel {
            text:           qsTr("Mission")
            font.bold:      true
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth:   true
        }

        Rectangle {
            Layout.fillWidth:   true
            height:              1
            color:               qgcPal.windowShade
        }

        Rectangle {
            id:                 waypointButton
            width:              parent.width
            height:             width
            radius:             ScreenTools.defaultFontPixelWidth / 2
            color:              (waypointMA.pressed || waypointMA.containsMouse) ?
                                    qgcPal.buttonHighlight : qgcPal.toolbarBackground

            Column {
                anchors.centerIn:   parent
                spacing:            ScreenTools.defaultFontPixelHeight * 0.1

                QGCLabel {
                    text:           "WP"
                    font.pointSize: ScreenTools.defaultFontPixelSize * 1.5
                    font.bold:      true
                    color:          (waypointMA.pressed || waypointMA.containsMouse) ?
                                    qgcPal.buttonHighlightText : qgcPal.buttonText
                    anchors.horizontalCenter:   parent.horizontalCenter
                }

                QGCLabel {
                    text:                       qsTr("Waypoint")
                    font.pointSize:             ScreenTools.smallFontPointSize
                    color:                      (waypointMA.pressed || waypointMA.containsMouse) ?
                                                qgcPal.buttonHighlightText : qgcPal.buttonText
                    anchors.horizontalCenter:   parent.horizontalCenter
                }
            }

            QGCMouseArea {
                id:         waypointMA
                fillItem:   parent
                onClicked:  waypointClicked()
            }
        }

        Rectangle {
            id:                 roiButton
            width:              parent.width
            height:             width
            radius:             ScreenTools.defaultFontPixelWidth / 2
            color:              (roiMA.pressed || roiMA.containsMouse) ?
                                    qgcPal.buttonHighlight : qgcPal.toolbarBackground

            Column {
                anchors.centerIn:   parent
                spacing:            ScreenTools.defaultFontPixelHeight * 0.1

                QGCLabel {
                    text:           "ROI"
                    font.pointSize: ScreenTools.defaultFontPixelSize * 1.5
                    font.bold:      true
                    color:          (roiMA.pressed || roiMA.containsMouse) ?
                                    qgcPal.buttonHighlightText : qgcPal.buttonText
                    anchors.horizontalCenter:   parent.horizontalCenter
                }

                QGCLabel {
                    text:                       qsTr("ROI")
                    font.pointSize:             ScreenTools.smallFontPointSize
                    color:                      (roiMA.pressed || roiMA.containsMouse) ?
                                                qgcPal.buttonHighlightText : qgcPal.buttonText
                    anchors.horizontalCenter:   parent.horizontalCenter
                }
            }

            QGCMouseArea {
                id:         roiMA
                fillItem:   parent
                onClicked:  roiClicked()
            }
        }

        Rectangle {
            id:                 vehicleButton
            width:              parent.width
            height:             width
            radius:             ScreenTools.defaultFontPixelWidth / 2
            color:              (vehicleMA.pressed || vehicleMA.containsMouse) ?
                                    qgcPal.buttonHighlight : qgcPal.toolbarBackground

            Column {
                anchors.centerIn:   parent
                spacing:            ScreenTools.defaultFontPixelHeight * 0.1

                QGCLabel {
                    text:           "UAV"
                    font.pointSize: ScreenTools.defaultFontPixelSize * 1.5
                    font.bold:      true
                    color:          (vehicleMA.pressed || vehicleMA.containsMouse) ?
                                    qgcPal.buttonHighlightText : qgcPal.buttonText
                    anchors.horizontalCenter:   parent.horizontalCenter
                }

                QGCLabel {
                    text:                       qsTr("Vehicle")
                    font.pointSize:             ScreenTools.smallFontPointSize
                    color:                      (vehicleMA.pressed || vehicleMA.containsMouse) ?
                                                qgcPal.buttonHighlightText : qgcPal.buttonText
                    anchors.horizontalCenter:   parent.horizontalCenter
                }
            }

            QGCMouseArea {
                id:         vehicleMA
                fillItem:   parent
                onClicked:  vehicleClicked()
            }
        }

        Rectangle {
            id:                 fenceButton
            width:              parent.width
            height:             width
            radius:             ScreenTools.defaultFontPixelWidth / 2
            color:              (fenceMA.pressed || fenceMA.containsMouse) ?
                                    qgcPal.buttonHighlight : qgcPal.toolbarBackground

            Column {
                anchors.centerIn:   parent
                spacing:            ScreenTools.defaultFontPixelHeight * 0.1

                QGCLabel {
                    text:           qsTr("围栏")
                    font.pointSize: ScreenTools.defaultFontPixelSize * 1.2
                    font.bold:      true
                    color:          (fenceMA.pressed || fenceMA.containsMouse) ?
                                    qgcPal.buttonHighlightText : qgcPal.buttonText
                    anchors.horizontalCenter:   parent.horizontalCenter
                }

                QGCLabel {
                    text:                       qsTr("Fence")
                    font.pointSize:             ScreenTools.smallFontPointSize
                    color:                      (fenceMA.pressed || fenceMA.containsMouse) ?
                                                qgcPal.buttonHighlightText : qgcPal.buttonText
                    anchors.horizontalCenter:   parent.horizontalCenter
                }
            }

            QGCMouseArea {
                id:         fenceMA
                fillItem:   parent
                onClicked:  fenceClicked()
            }
        }
    }
}