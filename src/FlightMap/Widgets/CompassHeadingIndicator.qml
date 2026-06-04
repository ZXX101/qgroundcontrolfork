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
import QGroundControl.Vehicle
import QGroundControl.Palette

Canvas {
    id:                 control
    anchors.centerIn:   parent
    width:              compassSize * 1/5
    height:             width

    property real compassSize
    property real heading
    property bool simplified:           false
    property color arrowColorLeft:      "#0C7B2B"  // 箭头左侧颜色 RGB(12, 124, 43)
    property color arrowColorRight:     "#45A961"  // 箭头右侧颜色 RGB(69, 169, 97)
    // property color strokeColor:         simplified ? "#0C7B2B" : "#FFFFFF"  // 边框颜色

    property var _qgcPal: QGroundControl.globalPalette

    Connections {
        target:                 _qgcPal
        onGlobalThemeChanged:   control.requestPaint()
    }

    onHeadingChanged: requestPaint()
    onArrowColorLeftChanged: requestPaint()
    onArrowColorRightChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)

        ctx.strokeStyle = arrowColorRight
        ctx.lineWidth = 1

        // 绘制箭头右侧（右侧三角形）
        ctx.fillStyle = arrowColorRight
        ctx.beginPath()
        ctx.moveTo(width / 2, 0)
        ctx.lineTo(width, height)
        ctx.lineTo(width / 2, height * 0.75)
        ctx.lineTo(width / 2, 0)
        ctx.fill()
        ctx.stroke()

        ctx.strokeStyle = arrowColorLeft
        // 绘制箭头左侧（左侧三角形）
        ctx.fillStyle = arrowColorLeft
        ctx.beginPath()
        ctx.moveTo(width / 2, 0)
        ctx.lineTo(0, height)
        ctx.lineTo(width / 2, height * 0.75)
        ctx.lineTo(width / 2, 0)
        ctx.fill()
        ctx.stroke()
    }

    transform: Rotation {
        origin.x:   control.width / 2
        origin.y:   control.height / 2
        angle:      heading
    }
}
