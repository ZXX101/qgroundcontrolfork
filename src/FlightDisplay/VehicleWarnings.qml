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
import QGroundControl.ScreenTools
import QGroundControl.Controls

//车辆警告显示组件，显示GPS锁定警告和预解锁错误警告
//当GPS未锁定或预解锁检查失败时显示警告消息
Rectangle {
    anchors.margins:    -ScreenTools.defaultFontPixelHeight
    height:             warningsCol.height
    width:              warningsCol.width
    color:              Qt.rgba(1, 1, 1, 0.5)
    radius:             ScreenTools.defaultFontPixelWidth / 2
    visible:            false   // XF: 屏蔽所有车辆警告显示(GPS锁定警告/预解锁错误警告)

    property var  _activeVehicle:       QGroundControl.multiVehicleManager.activeVehicle
    property bool _noGPSLockVisible:    _activeVehicle && _activeVehicle.requiresGpsFix && !_activeVehicle.coordinate.isValid
    property bool _prearmErrorVisible:  _activeVehicle && !_activeVehicle.armed && _activeVehicle.prearmError && !_activeVehicle.healthAndArmingCheckReport.supported

    Column {
        id:         warningsCol
        spacing:    ScreenTools.defaultFontPixelHeight

        //GPS锁定警告标签，显示"No GPS Lock for Vehicle"
        QGCLabel {
            anchors.horizontalCenter:   parent.horizontalCenter
            visible:                    _noGPSLockVisible
            color:                      "black"
            font.pointSize:             ScreenTools.largeFontPointSize
            text:                       qsTr("No GPS Lock for Vehicle")
        }

        //预解锁错误标签，显示具体错误信息
        QGCLabel {
            anchors.horizontalCenter:   parent.horizontalCenter
            visible:                    _prearmErrorVisible
            color:                      "black"
            font.pointSize:             ScreenTools.largeFontPointSize
            text:                       _activeVehicle ? _activeVehicle.prearmError : ""
        }

        //预解锁错误说明标签，显示"The vehicle has failed a pre-arm check..."
        QGCLabel {
            anchors.horizontalCenter:   parent.horizontalCenter
            visible:                    _prearmErrorVisible
            width:                      ScreenTools.defaultFontPixelWidth * 50
            horizontalAlignment:        Text.AlignHCenter
            wrapMode:                   Text.WordWrap
            color:                      "black"
            font.pointSize:             ScreenTools.largeFontPointSize
            text:                       qsTr("The vehicle has failed a pre-arm check. In order to arm the vehicle, resolve the failure.")
        }
    }
}
