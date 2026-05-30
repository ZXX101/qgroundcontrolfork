/****************************************************************************
 *
 * (c) 2009-2022 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.MultiVehicleManager
import QGroundControl.ScreenTools
import QGroundControl.Palette

//-------------------------------------------------------------------------
//-- Remote ID Indicator
//远程ID指示器，显示远程ID合规状态
//图标颜色：绿色=健康、黄色=警告、红色=错误、灰色=不可用
//点击弹出远程ID详情面板
Item {
    id:             control
    width:          remoteIDIcon.width * 1.1
    anchors.top:    parent.top
    anchors.bottom: parent.bottom

    property bool   showIndicator:      remoteIDManager.available

    property var    activeVehicle:      QGroundControl.multiVehicleManager.activeVehicle
    property var    remoteIDManager:    activeVehicle ? activeVehicle.remoteIDManager : null

    property bool   gpsFlag:            activeVehicle && remoteIDManager ? remoteIDManager.gcsGPSGood         : false
    property bool   basicIDFlag:        activeVehicle && remoteIDManager ? remoteIDManager.basicIDGood        : false
    property bool   armFlag:            activeVehicle && remoteIDManager ? remoteIDManager.armStatusGood      : false
    property bool   commsFlag:          activeVehicle && remoteIDManager ? remoteIDManager.commsGood          : false
    property bool   emergencyDeclared:  activeVehicle && remoteIDManager ? remoteIDManager.emergencyDeclared  : false
    property bool   operatorIDFlag:     activeVehicle && remoteIDManager ? remoteIDManager.operatorIDGood     : false
    property int    remoteIDState:      getRemoteIDState()

    property int    regionOperation:    QGroundControl.settingsManager.remoteIDSettings.region.value

    enum RIDState {
        HEALTHY,
        WARNING,
        ERROR,
        UNAVAILABLE
    }

    enum RegionOperation {
        FAA,
        EU
    }

    //获取远程ID图标颜色，根据状态返回对应颜色
    function getRidColor() {
        switch (remoteIDState) {
            case RemoteIDIndicator.RIDState.HEALTHY: 
                return qgcPal.colorGreen
                break
            case RemoteIDIndicator.RIDState.WARNING: 
                return qgcPal.colorYellow
                break
            case RemoteIDIndicator.RIDState.ERROR: 
                return qgcPal.colorRed
                break
            case RemoteIDIndicator.RIDState.UNAVAILABLE: 
                return qgcPal.colorGrey
                break
            default:
                return qgcPal.colorGrey
        }
    }

    function getRemoteIDState() {
        if (!activeVehicle) {
            return RemoteIDIndicator.RIDState.UNAVAILABLE
        }
        // We need to have comms and arm healthy to even be in any other state other than ERROR
        if (!commsFlag || !armFlag || emergencyDeclared) {
            return RemoteIDIndicator.RIDState.ERROR
        }
        if (!gpsFlag || !basicIDFlag) {
            return RemoteIDIndicator.RIDState.WARNING
        }
        if (regionOperation == RemoteIDIndicator.RegionOperation.EU || QGroundControl.settingsManager.remoteIDSettings.sendOperatorID.value) {
            if (!operatorIDFlag) {
                return RemoteIDIndicator.RIDState.WARNING
            }
        }
        return RemoteIDIndicator.RIDState.HEALTHY
    }

    function goToSettings() {
        if (mainWindow.allowViewSwitch()) {
            globals.commingFromRIDIndicator = true
            mainWindow.showSettingsTool()
        }
    }

    QGCColoredImage {
        id:                 remoteIDIcon
        width:              height
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        source:             "/qmlimages/RidIconMan.svg"
        color:              getRidColor()
        fillMode:           Image.PreserveAspectFit
        sourceSize.height:  height

        QGCColoredImage {
            width:              height
            anchors.fill:       parent
            sourceSize.height:  height
            source:             "/qmlimages/RidIconText.svg"
            fillMode:           Image.PreserveAspectFit
            color:              qgcPal.text
        }
    }

    MouseArea {
        anchors.fill:   parent
        onClicked:      mainWindow.showIndicatorDrawer(indicatorPage, control)
    }

    Component {
        id: indicatorPage

        RemoteIDIndicatorPage { }
    }
}
