/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


/**
 * @file
 *   @brief QGC Artificial Horizon
 *   @author Gus Grubba <gus@auterion.com>
 */

import QtQuick

Item {
    id: root
    property real rollAngle :   0
    property real pitchAngle:   0
    clip:           true
    anchors.fill:   parent

    property real angularScale: pitchAngle * root.height / 45

    Item {
        id: artificialHorizon
        width:  root.width  * 4
        height: root.height * 8
        anchors.centerIn: parent
        Rectangle {
            id: sky
            anchors.fill: parent
            smooth: true
            antialiasing: true
            gradient: Gradient {
                GradientStop { position: 0.25; color: Qt.hsla(126/360, 26/100, 7/100, 1) }   // 天空顶部 HSL(126, 26, 7)
                GradientStop { position: 0.5;  color: Qt.hsla(129/360, 89/100, 11/100, 1) } // 天空底部 HSL(129, 89, 11)
            }
        }
        Rectangle {
            id: ground
            height: sky.height / 2
            anchors {
                left:   sky.left;
                right:  sky.right;
                bottom: sky.bottom
            }
            smooth: true
            antialiasing: true
            gradient: Gradient {
                GradientStop { position: 0.0;  color: Qt.hsla(0/360, 0/100, 6/100, 1) }   // 地面顶部 HSL(0, 0, 6)
                GradientStop { position: 0.25; color: Qt.hsla(0/360, 0/100, 0/100, 1) }   // 地面底部 HSL(0, 0, 0)
            }
        }
        transform: [
            Translate {
                y:  angularScale
            },
            Rotation {
                origin.x: artificialHorizon.width  / 2
                origin.y: artificialHorizon.height / 2
                angle:    -rollAngle
            }]
    }
}
