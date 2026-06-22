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
    id:                 card
    height:             ScreenTools.defaultFontPixelHeight * 6
    color:              missionItem && missionItem.isCurrentItem ? qgcPal.missionItemEditor : qgcPal.windowShade
    radius:             ScreenTools.defaultFontPixelWidth / 4
    border.width:       1
    border.color:       qgcPal.windowShade

    property var        missionItem

    signal clicked(int sequenceNumber)
    signal remove(int index)

    RowLayout {
        anchors.fill:       parent
        anchors.margins:    ScreenTools.defaultFontPixelWidth / 2
        spacing:            ScreenTools.defaultFontPixelWidth

        Column {
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 4

            QGCLabel {
                text:       "#" + (missionItem ? missionItem.sequenceNumber : 0)
                font.bold:  true
                font.pointSize: ScreenTools.defaultFontPixelSize * 1.2
            }
            QGCLabel {
                text:       missionItem ? missionItem.commandName : ""
                font.pointSize: ScreenTools.smallFontPointSize
                color:      qgcPal.text
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: ScreenTools.defaultFontPixelHeight / 4
            columnSpacing: ScreenTools.defaultFontPixelWidth

            Column {
                QGCLabel {
                    text:       qsTr("Altitude")
                    font.pointSize: ScreenTools.smallFontPointSize
                    color:      qgcPal.text
                }
                QGCLabel {
                    text:       missionItem && missionItem.coordinate ? missionItem.coordinate.altitude.toFixed(1) + " m" : "0 m"
                    font.bold:  true
                }
            }

            Column {
                QGCLabel {
                    text:       qsTr("Speed")
                    font.pointSize: ScreenTools.smallFontPointSize
                    color:      qgcPal.text
                }
                QGCLabel {
                    text:       missionItem ? missionItem.speed.toFixed(1) + " m/s" : "0 m/s"
                    font.bold:  true
                }
            }

            Column {
                QGCLabel {
                    text:       qsTr("Longitude")
                    font.pointSize: ScreenTools.smallFontPointSize
                    color:      qgcPal.text
                }
                QGCLabel {
                    text:       missionItem && missionItem.coordinate ? missionItem.coordinate.longitude.toFixed(6) : "0"
                    font.bold:  true
                }
            }

            Column {
                QGCLabel {
                    text:       qsTr("Latitude")
                    font.pointSize: ScreenTools.smallFontPointSize
                    color:      qgcPal.text
                }
                QGCLabel {
                    text:       missionItem && missionItem.coordinate ? missionItem.coordinate.latitude.toFixed(6) : "0"
                    font.bold:  true
                }
            }
        }

        QGCButton {
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
            text:       "Delete"
            visible:    missionItem && missionItem.sequenceNumber !== 0
            onClicked:  {
                remove(index)
            }
        }
    }

    QGCMouseArea {
        anchors.fill: parent
        onClicked: {
            if (missionItem) {
                clicked(missionItem.sequenceNumber)
            }
        }
    }
}