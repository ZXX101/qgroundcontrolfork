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

//计时器指示器，位于工具栏右侧，显示飞行计时（MM:ss格式）
//点击启动计时，再次点击归零并停止
//断开连接时显示"--"
Item {
    id:                 control
    anchors.top:        parent.top
    anchors.bottom:     parent.bottom
    width:              timerRow.width + ScreenTools.defaultFontPixelWidth

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property bool   _connected:         _activeVehicle && !_activeVehicle.vehicleLinkManager.communicationLost
    property int    _elapsedSeconds:    0
    property bool   _timerRunning:      false

    function formatTime(seconds) {
        var mins = Math.floor(seconds / 60)
        var secs = seconds % 60
        return mins.toString().padStart(2, '0') + ":" + secs.toString().padStart(2, '0')
    }

    Timer {
        id:             stopwatchTimer
        interval:       1000
        running:        _timerRunning && _connected
        repeat:         true
        onTriggered:    _elapsedSeconds++
    }

    Row {
        id:                 timerRow
        anchors.centerIn:   parent
        spacing:            ScreenTools.defaultFontPixelWidth / 2

        Image {
            id:                 timerIcon
            height:             ScreenTools.defaultFontPixelHeight* 1.5
            width:              height
            sourceSize.height:  height
            sourceSize.width:   width
            fillMode:           Image.PreserveAspectFit
            source:             "/xfres/timer.png"
            anchors.verticalCenter: parent.verticalCenter
        }

        QGCLabel {
            id:             timerLabel
            text:           _connected ? formatTime(_elapsedSeconds) : "--"
            font.pointSize: ScreenTools.largeFontPointSize
            font.family:    "monospace"
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    QGCMouseArea {
        anchors.fill:   parent

        onClicked: {
            if (!_connected) return

            if (_timerRunning) {
                // 计时状态点击：归零并停止
                _elapsedSeconds = 0
                _timerRunning = false
            } else {
                // 停止状态点击：开始计时
                _timerRunning = true
            }
        }
    }
}
