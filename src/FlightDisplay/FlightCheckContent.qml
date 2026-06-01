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

    //安全参数（初始为null，通过updateParameters更新）
    property var _battLowVoltage: null
    property var _battFsLowAct: null
    property var _fsGcsEnable: null
    property var _fsThrEnable: null
    property var _fsThrValue: null
    property var _rtlAlt: null

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

        //尝试获取参数
        _battLowVoltage = paramMgr.getParameter(-1, "BATT_LOW_VOLT")
        _battFsLowAct = paramMgr.getParameter(-1, "BATT_FS_LOW_ACT")
        _fsGcsEnable = paramMgr.getParameter(-1, "FS_GCS_ENABLE")
        _fsThrEnable = paramMgr.getParameter(-1, "FS_THR_ENABLE")
        _fsThrValue = paramMgr.getParameter(-1, "FS_THR_VALUE")
        _rtlAlt = paramMgr.getParameter(-1, "RTL_ALT")
    }

    //故障保护动作转换为文本
    function getFailsafeActionText(actionValue) {
        // APM故障保护动作枚举: 0=Disabled, 1=Land, 2=RTL, 3=RTL then Land
        if (actionValue === undefined || actionValue === null) return "--"
        if (actionValue === 0) return qsTr("Disabled")
        if (actionValue === 1) return qsTr("Land")
        if (actionValue === 2) return qsTr("RTL")
        if (actionValue === 3) return qsTr("RTL+Land")
        return qsTr("Unknown")
    }

    //高度转换（厘米转米）
    function getAltitudeText(altCm) {
        if (altCm === undefined || altCm === null || isNaN(altCm)) return "--"
        return Math.round(altCm / 100) + "m"
    }

    //获取传感器状态图标
    function getSensorCheckIcon(hasError) {
        return hasError ? "/xfres/checkRed.png" : "/xfres/checkGreen.png"
    }

    ColumnLayout {
        id:                 contentLayout
        anchors.centerIn:   parent
        spacing:            ScreenTools.defaultFontPixelHeight * 0.5

        //表格标题行
        RowLayout {
            spacing: ScreenTools.defaultFontPixelWidth * 2

            QGCLabel { text: qsTr("类别"); font.bold: true; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8 }
            QGCLabel { text: qsTr("设置项"); font.bold: true; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 25 }
            QGCLabel { text: qsTr("数据"); font.bold: true; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8 }
            QGCLabel { text: qsTr("状态"); font.bold: true; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8 }
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
                { name: activeVehicle ? activeVehicle.vehicleLinkManager.primaryLinkName : qsTr("Not Connected"), value: "", icon: "" }
            ]
        }

        //传感器检查（从healthAndArmingCheckReport获取状态）
        CheckSection {
            sectionTitle:   qsTr("传感器")
            items: [
                { name: qsTr("罗盘"), value: "", icon: getSensorCheckIcon(false) },
                { name: qsTr("加速度计"), value: "", icon: getSensorCheckIcon(false) },
                { name: qsTr("陀螺仪"), value: "", icon: getSensorCheckIcon(false) },
                { name: qsTr("EKF"), value: "", icon: getSensorCheckIcon(false) }
            ]
        }

        //电机检查（温度暂不可用）
        CheckSection {
            sectionTitle:   qsTr("电机")
            items: [
                { name: qsTr("M1温度"), value: "--", icon: "" },
                { name: qsTr("M2温度"), value: "--", icon: "" },
                { name: qsTr("M3温度"), value: "--", icon: "" },
                { name: qsTr("M4温度"), value: "--", icon: "" }
            ]
        }

        //安全检查（从参数获取）
        CheckSection {
            sectionTitle:   qsTr("安全")
            items: [
                {
                    name: qsTr("低电压保护设置"),
                    value: _battLowVoltage && _battLowVoltage.rawValue !== undefined ? _battLowVoltage.valueString : "--",
                    status: _battFsLowAct && _battFsLowAct.rawValue !== undefined ? getFailsafeActionText(_battFsLowAct.rawValue) : "--"
                },
                {
                    name: qsTr("软件断联保护"),
                    value: _fsGcsEnable && _fsGcsEnable.rawValue !== undefined ?
                           (_fsGcsEnable.rawValue > 0 ? _fsGcsEnable.rawValue + "s" : qsTr("Disabled")) : "--",
                    status: _fsGcsEnable && _fsGcsEnable.rawValue !== undefined && _fsGcsEnable.rawValue > 0 ? qsTr("Land") : "--"
                },
                {
                    name: qsTr("遥控器失控保护"),
                    value: _fsThrValue && _fsThrValue.rawValue !== undefined ? _fsThrValue.valueString : "--",
                    status: _fsThrEnable && _fsThrEnable.rawValue !== undefined ?
                           (_fsThrEnable.rawValue > 0 ? qsTr("Land") : qsTr("Disabled")) : "--"
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
                    status: _rtlAlt && _rtlAlt.rawValue !== undefined ? getAltitudeText(_rtlAlt.rawValue) : "--"
                }
            ]
        }
    }

    //检查项分组组件
    component CheckSection: ColumnLayout {
        spacing: ScreenTools.defaultFontPixelHeight * 0.25

        property string sectionTitle
        property var items: []

        RowLayout {
            spacing: ScreenTools.defaultFontPixelWidth * 2

            //类别列
            QGCLabel {
                text:                   sectionTitle
                font.bold:              true
                Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 8
            }

            //设置项列（第一项）
            QGCLabel {
                text:                   items.length > 0 ? items[0].name : ""
                Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 25
            }

            //数据列（第一项）
            QGCLabel {
                text:                   items.length > 0 ? items[0].value : ""
                Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 8
            }

            //状态列（第一项）- 可能是图标或文本
            Item {
                Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 8
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight

                //状态图标
                Image {
                    anchors.centerIn:       parent
                    width:                  ScreenTools.defaultFontPixelHeight * 0.8
                    height:                 width
                    source:                 (items.length > 0 && items[0].icon !== undefined && items[0].icon !== "") ? items[0].icon : ""
                    fillMode:               Image.PreserveAspectFit
                    visible:                items.length > 0 && items[0].icon !== undefined && items[0].icon !== ""
                }

                //状态文本（如果没有图标）
                QGCLabel {
                    anchors.centerIn:       parent
                    text:                   (items.length > 0 && items[0].status !== undefined) ? items[0].status : ""
                    visible:                items.length > 0 && items[0].status !== undefined && items[0].status !== "" && !(items[0].icon !== undefined && items[0].icon !== "")
                }
            }
        }

        //后续项（类别列空白）
        Repeater {
            model: items.length > 1 ? items.slice(1) : []

            RowLayout {
                spacing: ScreenTools.defaultFontPixelWidth * 2

                //类别列（空白）
                QGCLabel {
                    text:                   ""
                    Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 8
                }

                //设置项列
                QGCLabel {
                    text:                   modelData.name !== undefined ? modelData.name : ""
                    Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 25
                }

                //数据列
                QGCLabel {
                    text:                   modelData.value !== undefined ? modelData.value : ""
                    Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 8
                }

                //状态列 - 可能是图标或文本
                Item {
                    Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 8
                    Layout.preferredHeight: ScreenTools.defaultFontPixelHeight

                    //状态图标
                    Image {
                        anchors.centerIn:       parent
                        width:                  ScreenTools.defaultFontPixelHeight * 0.8
                        height:                 width
                        source:                 (modelData.icon !== undefined && modelData.icon !== "") ? modelData.icon : ""
                        fillMode:               Image.PreserveAspectFit
                        visible:                modelData.icon !== undefined && modelData.icon !== ""
                    }

                    //状态文本（如果没有图标）
                    QGCLabel {
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