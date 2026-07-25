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
//自动显示飞行时间，格式为MM:SS
//没有数据时显示"--"
Item {
    id:                 control
    anchors.top:        parent.top
    anchors.bottom:     parent.bottom
    width:              implicitWidth
    implicitWidth:      timerRow.width

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property bool   _connected:         _activeVehicle && !_activeVehicle.vehicleLinkManager.communicationLost
    property int    _flightTimeSeconds: _activeVehicle ? _activeVehicle.vehicle.flightTime.rawValue : 0

    signal clicked()

    function formatTime(seconds) {
        if (seconds <= 0) return "--"
        var mins = Math.floor(seconds / 60)
        var secs = seconds % 60
        return mins.toString().padStart(2, '0') + ":" + secs.toString().padStart(2, '0')
    }

    Row {
        id:                 timerRow
        anchors.right:      parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing:            ScreenTools.defaultFontPixelWidth / 2

        Image {
            id:                 timerIcon
            height:             ScreenTools.defaultFontPixelHeight * 1.2
            width:              height
            sourceSize.height:  height
            sourceSize.width:   width
            fillMode:           Image.PreserveAspectFit
            source:             "/xfres/timer.png"
            anchors.verticalCenter: parent.verticalCenter
        }

        QGCLabel {
            id:             timerLabel
            text:           _connected && _flightTimeSeconds > 0 ? formatTime(_flightTimeSeconds) : "--"
            font.pointSize: ScreenTools.largeFontPointSize
            font.family:    "monospace"
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked:    control.clicked()
    }
}
