/****************************************************************************
 *
 * Flight Check Content for QGroundControl
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Palette
import QGroundControl.FactSystem

//飞行检查内容组件，显示连接、传感器、电机、安全、飞行等检查项
Rectangle {
    id:                 root
    width:              contentLayout.width + ScreenTools.defaultFontPixelWidth * 2
    height:             contentLayout.height + ScreenTools.defaultFontPixelHeight
    color:              Qt.rgba(0, 0, 0, 0.7)  //半透明深色背景
    radius:             ScreenTools.defaultFontPixelWidth / 2
    border.width:       0  //无边框

    property var activeVehicle

    QGCPalette { id: qgcPal }

    // All sections share one set of widths so the four columns stay aligned.
    property var _columnWidths: {
        var widths = [headerCategoryLabel.implicitWidth,
                      headerItemLabel.implicitWidth,
                      headerDataLabel.implicitWidth,
                      headerStatusLabel.implicitWidth]
        for (var i = 0; i < contentLayout.children.length; i++) {
            var section = contentLayout.children[i]
            if (!section || !section.columnWidths) continue
            for (var column = 0; column < 4; column++) {
                widths[column] = Math.max(widths[column], section.columnWidths[column])
            }
        }
        for (var widthIndex = 0; widthIndex < 4; widthIndex++) {
            widths[widthIndex] += ScreenTools.defaultFontPixelWidth
        }
        return widths
    }

    //飞控类型判断
    property bool _isAPM: activeVehicle ? activeVehicle.apmFirmware : false
    property bool _isPX4: activeVehicle ? activeVehicle.px4Firmware : false
    property bool _paramsReady: activeVehicle && activeVehicle.parameterManager ? activeVehicle.parameterManager.parametersReady : false

    //电机数量判断 - 根据FRAME_CLASS参数（APM）或MAV_TYPE（通用）
    property int _motorCount: _getMotorCount()

    function _getMotorCount() {
        if (!activeVehicle) return 0
        if (_isAPM && _paramsReady) {
            var frameClassParam = activeVehicle.parameterManager.getParameter(-1, "FRAME_CLASS")
            if (frameClassParam) {
                var fc = frameClassParam.rawValue
                if (fc === 1) return 4   // QUAD
                if (fc === 2) return 6   // HEX
                if (fc === 3) return 8   // OCTA
                if (fc === 4) return 8   // OCTAQUAD
                if (fc === 5) return 6   // Y6
                if (fc === 6) return 1   // HELI (主旋翼)
                if (fc === 7) return 3   // TRI
                if (fc === 8) return 1   // SINGLECOPTER
                if (fc === 9) return 2   // COAXCOPTER
                if (fc === 10) return 2  // BICOPTER
                if (fc === 11) return 2  // HELI_DUAL
                if (fc === 12) return 12 // DODECAHEXA
                if (fc === 13) return 4  // HELIQUAD
            }
        }
        if (activeVehicle.multiRotor) {
            var vtype = activeVehicle.vehicleType
            if (vtype === 2) return 4   // MAV_TYPE_QUADROTOR
            if (vtype === 3) return 4   // MAV_TYPE_COAXIAL
            if (vtype === 4) return 6   // MAV_TYPE_HELICOPTER (approximate)
            if (vtype === 13) return 6  // MAV_TYPE_HEXAROTOR
            if (vtype === 14) return 8  // MAV_TYPE_OCTOROTOR
            if (vtype === 15) return 3  // MAV_TYPE_TRICOPTER
            return 4
        }
        return 0
    }

    //ESC数据
    property var _escStatus: activeVehicle ? activeVehicle.escStatus : null
    property int _escCount: _escStatus && _escStatus.escCount ? _escStatus.escCount.rawValue : 0

    property real _temp1: _escStatus && _escStatus.tempFirst ? _escStatus.tempFirst.rawValue : NaN
    property real _temp2: _escStatus && _escStatus.tempSecond ? _escStatus.tempSecond.rawValue : NaN
    property real _temp3: _escStatus && _escStatus.tempThird ? _escStatus.tempThird.rawValue : NaN
    property real _temp4: _escStatus && _escStatus.tempFourth ? _escStatus.tempFourth.rawValue : NaN
    property real _temp5: _escStatus && _escStatus.tempFifth ? _escStatus.tempFifth.rawValue : NaN
    property real _temp6: _escStatus && _escStatus.tempSixth ? _escStatus.tempSixth.rawValue : NaN
    property real _temp7: _escStatus && _escStatus.tempSeventh ? _escStatus.tempSeventh.rawValue : NaN
    property real _temp8: _escStatus && _escStatus.tempEighth ? _escStatus.tempEighth.rawValue : NaN

    property real _rpm1: _escStatus && _escStatus.rpmFirst ? _escStatus.rpmFirst.rawValue : NaN
    property real _rpm2: _escStatus && _escStatus.rpmSecond ? _escStatus.rpmSecond.rawValue : NaN
    property real _rpm3: _escStatus && _escStatus.rpmThird ? _escStatus.rpmThird.rawValue : NaN
    property real _rpm4: _escStatus && _escStatus.rpmFourth ? _escStatus.rpmFourth.rawValue : NaN
    property real _rpm5: _escStatus && _escStatus.rpmFifth ? _escStatus.rpmFifth.rawValue : NaN
    property real _rpm6: _escStatus && _escStatus.rpmSixth ? _escStatus.rpmSixth.rawValue : NaN
    property real _rpm7: _escStatus && _escStatus.rpmSeventh ? _escStatus.rpmSeventh.rawValue : NaN
    property real _rpm8: _escStatus && _escStatus.rpmEighth ? _escStatus.rpmEighth.rawValue : NaN

    property real _volt1: _escStatus && _escStatus.voltageFirst ? _escStatus.voltageFirst.rawValue : NaN
    property real _volt2: _escStatus && _escStatus.voltageSecond ? _escStatus.voltageSecond.rawValue : NaN
    property real _volt3: _escStatus && _escStatus.voltageThird ? _escStatus.voltageThird.rawValue : NaN
    property real _volt4: _escStatus && _escStatus.voltageFourth ? _escStatus.voltageFourth.rawValue : NaN
    property real _volt5: _escStatus && _escStatus.voltageFifth ? _escStatus.voltageFifth.rawValue : NaN
    property real _volt6: _escStatus && _escStatus.voltageSixth ? _escStatus.voltageSixth.rawValue : NaN
    property real _volt7: _escStatus && _escStatus.voltageSeventh ? _escStatus.voltageSeventh.rawValue : NaN
    property real _volt8: _escStatus && _escStatus.voltageEighth ? _escStatus.voltageEighth.rawValue : NaN

    property real _cur1: _escStatus && _escStatus.currentFirst ? _escStatus.currentFirst.rawValue : NaN
    property real _cur2: _escStatus && _escStatus.currentSecond ? _escStatus.currentSecond.rawValue : NaN
    property real _cur3: _escStatus && _escStatus.currentThird ? _escStatus.currentThird.rawValue : NaN
    property real _cur4: _escStatus && _escStatus.currentFourth ? _escStatus.currentFourth.rawValue : NaN
    property real _cur5: _escStatus && _escStatus.currentFifth ? _escStatus.currentFifth.rawValue : NaN
    property real _cur6: _escStatus && _escStatus.currentSixth ? _escStatus.currentSixth.rawValue : NaN
    property real _cur7: _escStatus && _escStatus.currentSeventh ? _escStatus.currentSeventh.rawValue : NaN
    property real _cur8: _escStatus && _escStatus.currentEighth ? _escStatus.currentEighth.rawValue : NaN

    property var _tempValues: [_temp1, _temp2, _temp3, _temp4, _temp5, _temp6, _temp7, _temp8]
    property var _rpmValues: [_rpm1, _rpm2, _rpm3, _rpm4, _rpm5, _rpm6, _rpm7, _rpm8]
    property var _voltValues: [_volt1, _volt2, _volt3, _volt4, _volt5, _volt6, _volt7, _volt8]
    property var _curValues: [_cur1, _cur2, _cur3, _cur4, _cur5, _cur6, _cur7, _cur8]

    function _fmtVal(val, decimals) {
        if (val === undefined || isNaN(val)) return "--"
        if (decimals === 0) return Math.round(val)
        return val.toFixed(decimals)
    }

    function _getEscTempIcon(index) {
        if (index >= _tempValues.length) return ""
        var val = _tempValues[index]
        if (val === undefined || isNaN(val)) return ""
        if (val > 80) return "/xfres/checkRed.png"
        if (val > 60) return "/xfres/checkWhite.png"
        return "/xfres/checkGreen.png"
    }

    function _buildMotorItems() {
        var count = _escCount > 0 ? _escCount : _motorCount
        if (count <= 0) count = 4
        if (count > 8) count = 8
        var items = []
        for (var i = 0; i < count; i++) {
            var rpm = _fmtVal(_rpmValues[i], 0)
            var volt = _fmtVal(_voltValues[i], 1)
            var cur = _fmtVal(_curValues[i], 1)
            var temp = _fmtVal(_tempValues[i], 0)
            items.push({
                name: qsTr("M%1").arg(i + 1),
                value: rpm + "/" + volt + "V/" + cur + "A/" + temp + "°C",
                icon: _getEscTempIcon(i)
            })
        }
        return items
    }

    //PX4飞控：直接读取CAL_*参数
    property var _px4Mag0Id:     _paramsReady && _isPX4 ? activeVehicle.parameterManager.getParameter(-1, "CAL_MAG0_ID") : null
    property var _px4Acc0Id:     _paramsReady && _isPX4 ? activeVehicle.parameterManager.getParameter(-1, "CAL_ACC0_ID") : null
    property var _px4Gyro0Id:    _paramsReady && _isPX4 ? activeVehicle.parameterManager.getParameter(-1, "CAL_GYRO0_ID") : null

    //APM飞控：读取传感器校准参数（参考APMSensorsComponent.cc逻辑）
    property var _apmCompass0Id:    _paramsReady && _isAPM ? activeVehicle.parameterManager.getParameter(-1, "COMPASS_DEV_ID") : null
    property var _apmCompass0OfsX:  _paramsReady && _isAPM ? activeVehicle.parameterManager.getParameter(-1, "COMPASS_OFS_X") : null
    property var _apmCompass0OfsY:  _paramsReady && _isAPM ? activeVehicle.parameterManager.getParameter(-1, "COMPASS_OFS_Y") : null
    property var _apmCompass0OfsZ:  _paramsReady && _isAPM ? activeVehicle.parameterManager.getParameter(-1, "COMPASS_OFS_Z") : null
    property var _apmCompass1Id:    _paramsReady && _isAPM ? activeVehicle.parameterManager.getParameter(-1, "COMPASS_DEV_ID2") : null
    property var _apmCompass1OfsX:  _paramsReady && _isAPM ? activeVehicle.parameterManager.getParameter(-1, "COMPASS_OFS2_X") : null
    property var _apmCompass1OfsY:  _paramsReady && _isAPM ? activeVehicle.parameterManager.getParameter(-1, "COMPASS_OFS2_Y") : null
    property var _apmCompass1OfsZ:  _paramsReady && _isAPM ? activeVehicle.parameterManager.getParameter(-1, "COMPASS_OFS2_Z") : null
    property var _apmCompass2Id:    _paramsReady && _isAPM ? activeVehicle.parameterManager.getParameter(-1, "COMPASS_DEV_ID3") : null
    property var _apmCompass2OfsX:  _paramsReady && _isAPM ? activeVehicle.parameterManager.getParameter(-1, "COMPASS_OFS3_X") : null
    property var _apmCompass2OfsY:  _paramsReady && _isAPM ? activeVehicle.parameterManager.getParameter(-1, "COMPASS_OFS3_Y") : null
    property var _apmCompass2OfsZ:  _paramsReady && _isAPM ? activeVehicle.parameterManager.getParameter(-1, "COMPASS_OFS3_Z") : null
    property var _apmAccOffsX:      _paramsReady && _isAPM ? activeVehicle.parameterManager.getParameter(-1, "INS_ACCOFFS_X") : null
    property var _apmAccOffsY:      _paramsReady && _isAPM ? activeVehicle.parameterManager.getParameter(-1, "INS_ACCOFFS_Y") : null
    property var _apmAccOffsZ:      _paramsReady && _isAPM ? activeVehicle.parameterManager.getParameter(-1, "INS_ACCOFFS_Z") : null

    //安全参数 - APM
    property var _battLowVoltage:    null
    property var _battFsLowAct:      null
    property var _fsGcsEnable:       null  // 数据链路断联动作（APM没有单独超时参数）
    property var _fsThrEnable:       null
    property var _fsThrValue:        null
    property var _rtlAlt:            null

    //安全参数 - PX4
    property var _px4LowBattAction:    null
    property var _px4BatLowThr:        null  // 电池低电量百分比阈值
    property var _px4DlLossAction:     null  // 数据链路断联动作
    property var _px4DlLossTimeout:    null  // 数据链路断联超时
    property var _px4RcLossAction:     null  // 遥控器失控动作
    property var _px4RcLossTimeout:    null  // 遥控器失控超时

    //监听参数加载完成
    Connections {
        target: activeVehicle ? activeVehicle.parameterManager : null
        function onParametersReadyChanged() {
            updateParameters()
        }
    }

    Component.onCompleted: {
        if (activeVehicle && activeVehicle.parameterManager && activeVehicle.parameterManager.parametersReady) {
            updateParameters()
        }
    }

    //参数更新函数
    function updateParameters() {
        if (!activeVehicle || !activeVehicle.parameterManager || !activeVehicle.parameterManager.parametersReady) return

        var paramMgr = activeVehicle.parameterManager

        if (_isAPM) {
            // APM安全参数
            _battLowVoltage = paramMgr.getParameter(-1, "BATT_LOW_VOLT")
            _battFsLowAct = paramMgr.getParameter(-1, "BATT_FS_LOW_ACT")
            _fsGcsEnable = paramMgr.getParameter(-1, "FS_GCS_ENABLE")
            _fsThrEnable = paramMgr.getParameter(-1, "FS_THR_ENABLE")
            _fsThrValue = paramMgr.getParameter(-1, "FS_THR_VALUE")
            _rtlAlt = paramMgr.getParameter(-1, "RTL_ALT")
        } else if (_isPX4) {
            // PX4安全参数
            _px4LowBattAction = paramMgr.getParameter(-1, "COM_LOW_BAT_ACT")
            _px4BatLowThr = paramMgr.getParameter(-1, "BAT_LOW_THR")
            _px4DlLossAction = paramMgr.getParameter(-1, "NAV_DLL_ACT")
            _px4DlLossTimeout = paramMgr.getParameter(-1, "COM_DL_LOSS_T")
            _px4RcLossAction = paramMgr.getParameter(-1, "NAV_RCL_ACT")
            _px4RcLossTimeout = paramMgr.getParameter(-1, "COM_RC_LOSS_T")
            _rtlAlt = paramMgr.getParameter(-1, "RTL_RETURN_ALT")
        }
    }

    //检查APM罗盘是否已校准（参考APMSensorsComponent::compassSetupNeeded逻辑）
    function checkApmCompassCalibrated(compassId, ofsX, ofsY, ofsZ) {
        // 如果设备ID为0，表示该罗盘不存在
        if (!compassId || compassId.rawValue === 0) return false
        // 如果偏移值不全为0，表示已校准
        if (ofsX && ofsY && ofsZ &&
            (ofsX.rawValue !== 0 || ofsY.rawValue !== 0 || ofsZ.rawValue !== 0)) {
            return true
        }
        return false
    }

    //获取传感器状态图标
    function getCompassIcon() {
        if (!_paramsReady) return "/xfres/checkWhite.png"

        if (_isAPM) {
            // APM: 检查三个罗盘是否有已校准的
            if (checkApmCompassCalibrated(_apmCompass0Id, _apmCompass0OfsX, _apmCompass0OfsY, _apmCompass0OfsZ) ||
                checkApmCompassCalibrated(_apmCompass1Id, _apmCompass1OfsX, _apmCompass1OfsY, _apmCompass1OfsZ) ||
                checkApmCompassCalibrated(_apmCompass2Id, _apmCompass2OfsX, _apmCompass2OfsY, _apmCompass2OfsZ)) {
                return "/xfres/checkGreen.png"
            }
            return "/xfres/checkRed.png"
        } else if (_isPX4) {
            // PX4: 检查CAL_MAG0_ID
            if (_px4Mag0Id && _px4Mag0Id.rawValue !== 0) {
                return "/xfres/checkGreen.png"
            }
            return "/xfres/checkRed.png"
        }
        return "/xfres/checkWhite.png"
    }

    function getAccelIcon() {
        if (!_paramsReady) return "/xfres/checkWhite.png"

        if (_isAPM) {
            // APM: 检查INS_ACCOFFS_X/Y/Z是否不全为0（参考accelSetupNeeded逻辑）
            // 如果全为0，表示需要校准
            if (_apmAccOffsX && _apmAccOffsY && _apmAccOffsZ) {
                if (_apmAccOffsX.rawValue !== 0 || _apmAccOffsY.rawValue !== 0 || _apmAccOffsZ.rawValue !== 0) {
                    return "/xfres/checkGreen.png"
                }
            }
            return "/xfres/checkRed.png"
        } else if (_isPX4) {
            // PX4: 检查CAL_ACC0_ID
            if (_px4Acc0Id && _px4Acc0Id.rawValue !== 0) {
                return "/xfres/checkGreen.png"
            }
            return "/xfres/checkRed.png"
        }
        return "/xfres/checkWhite.png"
    }

    function getGyroIcon() {
        if (!_paramsReady) return "/xfres/checkWhite.png"

        if (_isAPM) {
            // APM: 陀螺仪校准与加速度计相关，使用加速度计状态
            if (_apmAccOffsX && _apmAccOffsY && _apmAccOffsZ) {
                if (_apmAccOffsX.rawValue !== 0 || _apmAccOffsY.rawValue !== 0 || _apmAccOffsZ.rawValue !== 0) {
                    return "/xfres/checkGreen.png"
                }
            }
            return "/xfres/checkRed.png"
        } else if (_isPX4) {
            // PX4: 检查CAL_GYRO0_ID
            if (_px4Gyro0Id && _px4Gyro0Id.rawValue !== 0) {
                return "/xfres/checkGreen.png"
            }
            return "/xfres/checkRed.png"
        }
        return "/xfres/checkWhite.png"
    }

    //高度转换（APM的RTL_ALT是厘米，PX4的RTL_RETURN_ALT是米）
    function getAltitudeText(altValue, isPX4) {
        if (altValue === undefined || altValue === null || isNaN(altValue)) return "--"
        if (isPX4) {
            // PX4: RTL_RETURN_ALT单位是米
            if (altValue === 0) return qsTr("current")
            return Math.round(altValue) + "m"
        } else {
            // APM: RTL_ALT单位是厘米
            if (altValue === 0) return qsTr("current")
            return Math.round(altValue / 100) + "m"
        }
    }

    function getVehicleIdentifier() {
        if (!activeVehicle) return "--"
        if (activeVehicle.serialString && activeVehicle.serialString.length > 0) {
            return activeVehicle.serialString
        }
        if (activeVehicle.vehicleUID !== 0) {
            return activeVehicle.vehicleUIDStr
        }
        return "--"
    }

    ColumnLayout {
        id:                 contentLayout
        anchors.centerIn:   parent
        spacing:            ScreenTools.defaultFontPixelHeight * 0.5

        //表格标题行
        RowLayout {
            spacing: ScreenTools.defaultFontPixelWidth * 2

            QGCLabel { id: headerCategoryLabel; text: qsTr("类别"); font.bold: true; Layout.preferredWidth: root._columnWidths[0] }
            QGCLabel { id: headerItemLabel; text: qsTr("设置项"); font.bold: true; Layout.preferredWidth: root._columnWidths[1] }
            QGCLabel { id: headerDataLabel; text: qsTr("数据"); font.bold: true; Layout.preferredWidth: root._columnWidths[2] }
            QGCLabel { id: headerStatusLabel; text: qsTr("状态"); font.bold: true; Layout.preferredWidth: root._columnWidths[3] }
        }

        //分隔线
        Rectangle {
            Layout.fillWidth:   true
            height:             1
            color:              qgcPal.text
        }

        //连接检查
        CheckSection {
            sectionTitle:   qsTr("连接")
            items: [
                { name: activeVehicle ? activeVehicle.vehicleLinkManager.primaryLinkName : qsTr("Not Connected"), value: "", icon: "" },
                { name: qsTr("编码"), value: getVehicleIdentifier(), icon: "" }
            ]
        }

        //传感器检查（根据飞控类型使用不同参数）
        CheckSection {
            sectionTitle:   qsTr("传感器")
            items: [
                { name: qsTr("罗盘"), value: "", icon: getCompassIcon() },
                { name: qsTr("加速度计"), value: "", icon: getAccelIcon() },
                { name: qsTr("陀螺仪"), value: "", icon: getGyroIcon() },
                { name: qsTr("EKF"), value: "", icon: "/xfres/checkGreen.png" }
            ]
        }

        //电机检查
        CheckSection {
            sectionTitle:   qsTr("电机")
            items:          _buildMotorItems()
        }

        //安全检查（从参数获取）
        CheckSection {
            sectionTitle:   qsTr("安全")
            items: [
                {
                    name: qsTr("低电压保护设置"),
                    value: _isAPM && _battLowVoltage && _battLowVoltage.rawValue !== undefined ? _battLowVoltage.valueString :
                           _isPX4 && _px4BatLowThr && _px4BatLowThr.rawValue !== undefined ? _px4BatLowThr.valueString + "%" : "--",
                    status: _isAPM && _battFsLowAct && _battFsLowAct.rawValue !== undefined ? _battFsLowAct.enumStringValue :
                            _isPX4 && _px4LowBattAction && _px4LowBattAction.rawValue !== undefined ? _px4LowBattAction.enumStringValue : "--"
                },
                {
                    name: qsTr("数据链路断联保护"),
                    value: _isPX4 && _px4DlLossTimeout && _px4DlLossTimeout.rawValue !== undefined ? _px4DlLossTimeout.valueString + "s" : "--",
                    status: _isAPM && _fsGcsEnable && _fsGcsEnable.rawValue !== undefined ? _fsGcsEnable.enumStringValue :
                            _isPX4 && _px4DlLossAction && _px4DlLossAction.rawValue !== undefined ? _px4DlLossAction.enumStringValue : "--"
                },
                {
                    name: qsTr("遥控器失控保护"),
                    value: _isAPM && _fsThrValue && _fsThrValue.rawValue !== undefined ? _fsThrValue.valueString :
                            _isPX4 && _px4RcLossTimeout && _px4RcLossTimeout.rawValue !== undefined ? _px4RcLossTimeout.valueString + "s" : "--",
                    status: _isAPM && _fsThrEnable && _fsThrEnable.rawValue !== undefined ? _fsThrEnable.enumStringValue :
                            _isPX4 && _px4RcLossAction && _px4RcLossAction.rawValue !== undefined ? _px4RcLossAction.enumStringValue : "--"
                }
            ]
        }

        //飞行检查
        CheckSection {
            sectionTitle:   qsTr("飞行")
            items: [
                {
                    name: qsTr("返航高度"),
                    value: "",
                    status: _rtlAlt && _rtlAlt.rawValue !== undefined ? getAltitudeText(_rtlAlt.rawValue, _isPX4) : "--"
                }
            ]
        }
    }

    //检查项分组组件
    component CheckSection: ColumnLayout {
        spacing: ScreenTools.defaultFontPixelHeight * 0.25

        property string sectionTitle
        property var items: []
        property var columnWidths: {
            var widths = [sectionTitleLabel.implicitWidth,
                          firstItemRow.nameContentWidth,
                          firstItemRow.valueContentWidth,
                          firstItemRow.statusContentWidth]
            for (var i = 0; i < itemRepeater.count; i++) {
                var row = itemRepeater.itemAt(i)
                if (!row) continue
                widths[1] = Math.max(widths[1], row.nameContentWidth)
                widths[2] = Math.max(widths[2], row.valueContentWidth)
                widths[3] = Math.max(widths[3], row.statusContentWidth)
            }
            return widths
        }

        RowLayout {
            id: firstItemRow
            spacing: ScreenTools.defaultFontPixelWidth * 2
            property real nameContentWidth: firstItemNameLabel.implicitWidth
            property real valueContentWidth: firstItemValueLabel.implicitWidth
            property real statusContentWidth: firstStatusCell.implicitWidth

            //类别列
            QGCLabel {
                id:                     sectionTitleLabel
                text:                   sectionTitle
                font.bold:              true
                Layout.preferredWidth:  root._columnWidths[0]
            }

            //设置项列（第一项）
            QGCLabel {
                id:                     firstItemNameLabel
                text:                   items.length > 0 ? items[0].name : ""
                Layout.preferredWidth:  root._columnWidths[1]
            }

            //数据列（第一项）
            QGCLabel {
                id:                     firstItemValueLabel
                text:                   items.length > 0 ? items[0].value : ""
                Layout.preferredWidth:  root._columnWidths[2]
            }

            //状态列（第一项）- 可能是图标或文本
            Item {
                id:                     firstStatusCell
                implicitWidth:          Math.max(firstStatusIcon.width, firstStatusLabel.implicitWidth)
                Layout.preferredWidth:  root._columnWidths[3]
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight

                //状态图标
                Image {
                    id:                     firstStatusIcon
                    anchors.centerIn:       parent
                    width:                  ScreenTools.defaultFontPixelHeight * 0.8
                    height:                 width
                    source:                 (items.length > 0 && items[0].icon !== undefined && items[0].icon !== "") ? items[0].icon : ""
                    fillMode:               Image.PreserveAspectFit
                    visible:                items.length > 0 && items[0].icon !== undefined && items[0].icon !== ""
                }

                //状态文本（如果没有图标）
                QGCLabel {
                    id:                     firstStatusLabel
                    anchors.centerIn:       parent
                    text:                   (items.length > 0 && items[0].status !== undefined) ? items[0].status : ""
                    visible:                items.length > 0 && items[0].status !== undefined && items[0].status !== "" && !(items[0].icon !== undefined && items[0].icon !== "")
                }
            }
        }

        //后续项（类别列空白）
        Repeater {
            id: itemRepeater
            model: items.length > 1 ? items.slice(1) : []

            RowLayout {
                property real nameContentWidth: itemNameLabel.implicitWidth
                property real valueContentWidth: itemValueLabel.implicitWidth
                property real statusContentWidth: statusCell.implicitWidth
                spacing: ScreenTools.defaultFontPixelWidth * 2

                //类别列（空白）
                QGCLabel {
                    text:                   ""
                    Layout.preferredWidth:  root._columnWidths[0]
                }

                //设置项列
                QGCLabel {
                    id:                     itemNameLabel
                    text:                   modelData.name !== undefined ? modelData.name : ""
                    Layout.preferredWidth:  root._columnWidths[1]
                }

                //数据列
                QGCLabel {
                    id:                     itemValueLabel
                    text:                   modelData.value !== undefined ? modelData.value : ""
                    Layout.preferredWidth:  root._columnWidths[2]
                }

                //状态列 - 可能是图标或文本
                Item {
                    id:                     statusCell
                    implicitWidth:          Math.max(statusIcon.width, statusLabel.implicitWidth)
                    Layout.preferredWidth:  root._columnWidths[3]
                    Layout.preferredHeight: ScreenTools.defaultFontPixelHeight

                    //状态图标
                    Image {
                        id:                     statusIcon
                        anchors.centerIn:       parent
                        width:                  ScreenTools.defaultFontPixelHeight * 0.8
                        height:                 width
                        source:                 (modelData.icon !== undefined && modelData.icon !== "") ? modelData.icon : ""
                        fillMode:               Image.PreserveAspectFit
                        visible:                modelData.icon !== undefined && modelData.icon !== ""
                    }

                    //状态文本（如果没有图标）
                    QGCLabel {
                        id:                     statusLabel
                        anchors.centerIn:       parent
                        text:                   modelData.status !== undefined ? modelData.status : ""
                        visible:                modelData.status !== undefined && modelData.status !== "" && !(modelData.icon !== undefined && modelData.icon !== "")
                    }
                }
            }
        }

        //分隔线
        Rectangle {
            Layout.fillWidth:   true
            height:             1
            color:              qgcPal.windowShade
        }
    }
}
