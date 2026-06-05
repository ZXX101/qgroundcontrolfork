/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick

import QGroundControl
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Palette
import QtQuick.Shapes
/// This is the dial background for the compass

Item {
    id: control

    property real offsetRadius: width / 2 - ScreenTools.defaultFontPixelHeight / 2 - ScreenTools.defaultFontPixelHeight * 0.25

    function translateCenterToAngleX(radius, angle) {
        return radius * Math.sin(angle * (Math.PI / 180))
    }

    function translateCenterToAngleY(radius, angle) {
        return -radius * Math.cos(angle * (Math.PI / 180))
    }

    Rectangle {
        id: circle
        width: size
        height: size
        radius:size / 2          // radius = width / 2
        color: "transparent"
        border.color: "white"
        border.width: 2
    }


    QGCLabel {
        anchors.centerIn:   parent
        text:               "N"
        font.pointSize:  ScreenTools.smallFontPointSize
        transform: Translate {
            x: translateCenterToAngleX(control.offsetRadius, 0)
            y: translateCenterToAngleY(control.offsetRadius, 0)
        }
    }

    QGCLabel {
        anchors.centerIn:   parent
        text:               "E"
        font.pointSize:  ScreenTools.smallFontPointSize

        transform: Translate {
            x: translateCenterToAngleX(control.offsetRadius, 90)
            y: translateCenterToAngleY(control.offsetRadius, 90)
        }
    }

    QGCLabel {
        anchors.centerIn:   parent
        text:               "S"
        font.pointSize:  ScreenTools.smallFontPointSize

        transform: Translate {
            x: translateCenterToAngleX(control.offsetRadius, 180)
            y: translateCenterToAngleY(control.offsetRadius, 180)
        }
    }

    QGCLabel {
        anchors.centerIn:   parent
        text:               "W"
        font.pointSize:  ScreenTools.smallFontPointSize

        transform: Translate {
            x: translateCenterToAngleX(control.offsetRadius, 270)
            y: translateCenterToAngleY(control.offsetRadius, 270)
        }
    }

    // Major tick marks
    Repeater {
        model: 4

        Rectangle {
            id:                 majorTick
            x:                  size / 2
            width:              1
            height:             ScreenTools.defaultFontPixelHeight * 0.5


            color:              qgcPal.text

            transform: Rotation {
                origin.x:   0
                origin.y:   size / 2
                angle:      90 * index
            }
        }
    }
    // Major tick  triangle
    // Repeater {
    //     model: 4

    //     Shape {
    //         id:                 majorTick
    //         x:                  size / 2
    //         y:                  0
    //         width:              ScreenTools.defaultFontPixelHeight * 0.2
    //         height:             ScreenTools.defaultFontPixelHeight * 0.2
    //         ShapePath{

    //             strokeColor: qgcPal.text
    //             // strokeWidth: 0
    //             fillColor: strokeColor
    //             fillRule: ShapePath.WindingFill
    //             startX: 0
    //             startY: 0

    //             PathLine {
    //                 x: width
    //                 y: 0
    //             }

    //             PathLine {
    //                 x: 0
    //                 y: height
    //             }
    //             PathLine {
    //                 x: 0
    //                 y: ScreenTools.defaultFontPixelHeight * 0.5
    //             }
    //             PathLine {
    //                 x: 0
    //                 y: height
    //             }

    //             PathLine {
    //                 x: -width
    //                 y: 0
    //             }
    //             PathLine {
    //                 x: 0
    //                 y: 0
    //             }
    //         }


    //         // color:              qgcPal.text

    //         transform: Rotation {
    //             origin.x:   0
    //             origin.y:   size / 2
    //             angle:      90 * index
    //         }
    //     }
    // }

    // Minor tick marks
    Repeater {
        model: 24

        Rectangle {
            id:                 minorTick
            x:                  size / 2
            y:                  2 //外圈宽度
            width:              1
            height:             _margin
            color:              qgcPal.text

            property real _margin: ScreenTools.defaultFontPixelHeight * 0.25

            transform: Rotation {
                origin.x:   0
                origin.y:   size / 2 -2
                angle:      90/6 * index
            }
        }
    }
}
