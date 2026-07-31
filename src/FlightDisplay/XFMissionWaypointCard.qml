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
    height:             ScreenTools.defaultFontPixelHeight * 7
    color:              missionItem && missionItem.isCurrentItem ? qgcPal.missionItemEditor : qgcPal.windowShade
    radius:             ScreenTools.defaultFontPixelWidth / 4
    border.width:       1
    border.color:       qgcPal.windowShade

    property var        missionItem
    property real       effectiveSpeed: NaN
    property int        speedProfileRevision: 0
    readonly property real deleteButtonWidth: waypointDeleteBtn.implicitWidth

    signal waypointClicked(int sequenceNumber)
    signal waypointRemove(int itemIndex)

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
            rowSpacing: ScreenTools.defaultFontPixelHeight / 2
            columnSpacing: ScreenTools.defaultFontPixelWidth * 2

            ColumnLayout {
                Layout.fillWidth: true

                QGCLabel {
                    text:       qsTr("Altitude")
                    font.pointSize: ScreenTools.defaultFontPointSize
                    color:      qgcPal.text
                }
                QGCLabel {
                    text:       (missionItem && missionItem.isSimpleItem && missionItem.altitude && !isNaN(missionItem.altitude.value)) ? Number(missionItem.altitude.value).toFixed(1) + " m" : "-- m"
                    font.pointSize: ScreenTools.defaultFontPointSize
                }
            }

            ColumnLayout {
                Layout.fillWidth: true

                QGCLabel {
                    text:       qsTr("Speed")
                    font.pointSize: ScreenTools.defaultFontPointSize
                    color:      qgcPal.text
                }
                QGCLabel {
                    text:       !isNaN(effectiveSpeed) ? Number(effectiveSpeed).toFixed(1) + " m/s" : "-- m/s"
                    font.pointSize: ScreenTools.defaultFontPointSize
                }
            }

            ColumnLayout {
                Layout.fillWidth: true

                QGCLabel {
                    text:       qsTr("Longitude")
                    font.pointSize: ScreenTools.defaultFontPointSize
                    color:      qgcPal.text
                }
                QGCLabel {
                    text:       (missionItem && missionItem.coordinate && !isNaN(missionItem.coordinate.longitude)) ? missionItem.coordinate.longitude.toFixed(6) : "--"
                    font.pointSize: ScreenTools.defaultFontPointSize
                }
            }

            ColumnLayout {
                Layout.fillWidth: true

                QGCLabel {
                    text:       qsTr("Latitude")
                    font.pointSize: ScreenTools.defaultFontPointSize
                    color:      qgcPal.text
                }
                QGCLabel {
                    text:       (missionItem && missionItem.coordinate && !isNaN(missionItem.coordinate.latitude)) ? missionItem.coordinate.latitude.toFixed(6) : "--"
                    font.pointSize: ScreenTools.defaultFontPointSize
                }
            }
        }

    }
    Image {
        id: waypointDeleteBtn
        z: 1
        height: ScreenTools.minTouchPixels* 0.7
        width: height
        sourceSize.height: height
        fillMode: Image.PreserveAspectFit
        source: "/xfressvg/deleteProtocol.svg"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.right
        anchors.leftMargin: -width / 2
        visible: missionItem && missionItem.sequenceNumber !== 0

        QGCMouseArea {
            fillItem: parent
            onClicked: {
                waypointRemove(index)
            }
        }
    }

    QGCMouseArea {
        z: 0
        anchors.fill: parent
        onClicked: {
            if (missionItem) {
                waypointClicked(missionItem.sequenceNumber)
            }
        }
    }
}
