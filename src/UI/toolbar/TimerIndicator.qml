/****************************************************************************
 *
 * Timer Indicator for QGroundControl
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Palette

//飞行时间指示器，位于工具栏右侧，显示飞行时间（从遥测参数flightTime读取）
//自动显示飞行时间，格式为HH:MM:SS
//断开连接时显示"--:--"
Item {
    id:                 control
    anchors.top:        parent.top
    anchors.bottom:     parent.bottom
    width:              timerRow.width + ScreenTools.defaultFontPixelWidth

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property bool   _connected:         _activeVehicle && !_activeVehicle.vehicleLinkManager.communicationLost
    property int    _flightTimeSeconds: _activeVehicle ? _activeVehicle.vehicle.flightTime.rawValue : 0

    function formatTime(seconds) {
        if (seconds <= 0) return "00:00:00"
        var hours = Math.floor(seconds / 3600)
        var mins = Math.floor((seconds % 3600) / 60)
        var secs = seconds % 60
        return hours.toString().padStart(2, '0') + ":" + mins.toString().padStart(2, '0') + ":" + secs.toString().padStart(2, '0')
    }

    Row {
        id:                 timerRow
        anchors.centerIn:   parent
        spacing:            ScreenTools.defaultFontPixelWidth / 2

        Image {
            id:                 timerIcon
            height:             ScreenTools.defaultFontPixelHeight * 1.5
            width:              height
            sourceSize.height:  height
            sourceSize.width:   width
            fillMode:           Image.PreserveAspectFit
            source:             "/xfres/timer.png"
            anchors.verticalCenter: parent.verticalCenter
        }

        QGCLabel {
            id:             timerLabel
            text:           _connected ? formatTime(_flightTimeSeconds) : "--:--:--"
            font.pointSize: ScreenTools.largeFontPointSize
            font.family:    "monospace"
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
