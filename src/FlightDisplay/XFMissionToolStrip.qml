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

    property string currentMode:    "waypoint"
    property bool   isROIActive:    false

    signal waypointClicked
    signal roiClicked
    signal roiCancelClicked
    signal vehicleClicked
    signal fenceClicked

    Column {
        id:                     column
        anchors.margins:        ScreenTools.defaultFontPixelWidth
        anchors.left:           parent.left
        anchors.right:          parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing:                ScreenTools.defaultFontPixelWidth / 2

        QGCLabel {
            text:               qsTr("Mission")
            font.bold:          true
            horizontalAlignment:Text.AlignHCenter
            width:              parent.width
        }

        Rectangle {
            width:              parent.width
            height:             1
            color:              qgcPal.windowShade
        }

        Rectangle {
            id:                 waypointButton
            width:              parent.width
            height:             width
            radius:             ScreenTools.defaultFontPixelWidth / 2
            color:              _root.currentMode === "waypoint" ?
                                    qgcPal.buttonHighlight :
                                    (waypointMA.pressed || waypointMA.containsMouse ?
                                        qgcPal.buttonHighlight : qgcPal.toolbarBackground)

            Column {
                anchors.centerIn:   parent
                spacing:            ScreenTools.defaultFontPixelHeight * 0.1

                QGCLabel {
                    text:           qsTr("WP")
                    font.pointSize: ScreenTools.defaultFontPixelSize * 1.5
                    font.bold:      true
                    color:          _root.currentMode === "waypoint" ?
                                        qgcPal.buttonHighlightText :
                                        (waypointMA.pressed || waypointMA.containsMouse ?
                                            qgcPal.buttonHighlightText : qgcPal.buttonText)
                    anchors.horizontalCenter:   parent.horizontalCenter
                }

                QGCLabel {
                    text:                       qsTr("Waypoint")
                    font.pointSize:             ScreenTools.smallFontPointSize
                    color:                      _root.currentMode === "waypoint" ?
                                                    qgcPal.buttonHighlightText :
                                                    (waypointMA.pressed || waypointMA.containsMouse ?
                                                        qgcPal.buttonHighlightText : qgcPal.buttonText)
                    anchors.horizontalCenter:   parent.horizontalCenter
                }
            }

            QGCMouseArea {
                id:         waypointMA
                fillItem:   parent
                onClicked:  {
                    _root.currentMode = "waypoint"
                    waypointClicked()
                }
            }
        }

        Rectangle {
            id:                 roiButton
            width:              parent.width
            height:             width
            radius:             ScreenTools.defaultFontPixelWidth / 2
            color:              _root.currentMode === "roi" ?
                                    qgcPal.buttonHighlight :
                                    (roiMA.pressed || roiMA.containsMouse ?
                                        qgcPal.buttonHighlight : qgcPal.toolbarBackground)

            Column {
                anchors.centerIn:   parent
                spacing:            ScreenTools.defaultFontPixelHeight * 0.1

                QGCLabel {
                    text:           _root.isROIActive ? qsTr("X") : "ROI"
                    font.pointSize: ScreenTools.defaultFontPixelSize * 1.5
                    font.bold:      true
                    color:          _root.currentMode === "roi" ?
                                        qgcPal.buttonHighlightText :
                                        (roiMA.pressed || roiMA.containsMouse ?
                                            qgcPal.buttonHighlightText : qgcPal.buttonText)
                    anchors.horizontalCenter:   parent.horizontalCenter
                }

                QGCLabel {
                    text:                       _root.isROIActive ? qsTr("Cancel ROI") : qsTr("ROI")
                    font.pointSize:             ScreenTools.smallFontPointSize
                    color:                      _root.currentMode === "roi" ?
                                                    qgcPal.buttonHighlightText :
                                                    (roiMA.pressed || roiMA.containsMouse ?
                                                        qgcPal.buttonHighlightText : qgcPal.buttonText)
                    anchors.horizontalCenter:   parent.horizontalCenter
                }
            }

            QGCMouseArea {
                id:         roiMA
                fillItem:   parent
                onClicked:  {
                    if (_root.isROIActive) {
                        roiCancelClicked()
                    } else {
                        _root.currentMode = "roi"
                        roiClicked()
                    }
                }
            }
        }
    }
}
