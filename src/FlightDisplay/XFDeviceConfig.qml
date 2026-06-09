/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.ScreenTools

//设备配置主容器 - 动态加载飞控组件
Item {
    id: root
    anchors.fill: parent

    //获取飞控和autopilotPlugin
    property var _vehicle: QGroundControl.multiVehicleManager.activeVehicle
    property var _autopilotPlugin: _vehicle ? _vehicle.autopilotPlugin : null
    property var _vehicleComponents: _autopilotPlugin ? _autopilotPlugin.vehicleComponents : []
    property var _fullParameterVehicleAvailable: _vehicle ?
        (QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable &&
         !_vehicle.parameterManager.missingParameters) : false

    readonly property real _defaultTextHeight: ScreenTools.defaultFontPixelHeight
    readonly property real _defaultTextWidth: ScreenTools.defaultFontPixelWidth

    //当前选中的组件索引
    property int currentIndex: -1

    //飞控未连接时显示提示
    Rectangle {
        anchors.fill: parent
        color: qgcPal.window
        visible: !_vehicle || !_fullParameterVehicleAvailable

        Column {
            anchors.centerIn: parent
            spacing: _defaultTextHeight

            QGCLabel {
                text: qsTr("等待飞控连接...")
                font.pointSize: ScreenTools.largeFontPointSize
                color: qgcPal.text
                anchors.horizontalCenter: parent.horizontalCenter
            }

            QGCLabel {
                text: _vehicle ? qsTr("正在加载参数...") : qsTr("请连接飞控设备")
                font.pointSize: ScreenTools.defaultFontPointSize
                color: qgcPal.text
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    //已连接时显示组件列表和内容
    RowLayout {
        anchors.fill: parent
        spacing: _defaultTextWidth
        visible: _vehicle && _fullParameterVehicleAvailable

        //左侧：组件按钮列表
        ColumnLayout {
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 18
            Layout.fillHeight: true
            spacing: _defaultTextHeight / 4

            //概况按钮
            ConfigButton {
                text: qsTr("概况")
                checked: currentIndex === -1
                Layout.fillWidth: true
                onClicked: {
                    currentIndex = -1
                    contentLoader.source = "qrc:/qml/QGroundControl/FlightDisplay/XFVehicleSummary.qml"
                }
            }

            //动态组件列表
            Repeater {
                model: _vehicleComponents

                ConfigButton {
                    text: modelData.name
                    checked: currentIndex === index
                    Layout.fillWidth: true
                    onClicked: {
                        currentIndex = index
                        contentLoader.source = modelData.setupSource.toString()
                    }
                }
            }
        }

        //分隔线
        Rectangle {
            Layout.fillHeight: true
            width: 1
            color: qgcPal.windowShade
        }

        //右侧：内容加载器
        Loader {
            id: contentLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: "qrc:/qml/QGroundControl/FlightDisplay/XFVehicleSummary.qml"
        }
    }
}