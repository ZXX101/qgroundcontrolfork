/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
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
import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.AutoPilotPlugin
import MAVLink

//-------------------------------------------------------------------------
//-- Battery Indicator
//电池指示器，位于工具栏右侧，显示电池状态（百分比/电压）
//图标颜色：绿色=正常、黄绿色/黄色=低电量警告、橙色=低电量、红色=紧急/故障
//点击弹出电池详情面板：剩余电量、电压、消耗量、温度等
Item {
    id:             control
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    width:          implicitWidth
    implicitWidth:  batteryIndicatorRow.width

    property bool       showIndicator:      true
    property bool       waitForParameters:  false   // UI won't show until parameters are ready
    property Component  expandedPageComponent

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property var    _batterySettings:   QGroundControl.settingsManager.batteryIndicatorSettings
    property Fact   _indicatorDisplay:  _batterySettings.valueDisplay
    property bool   _showPercentage:    _indicatorDisplay.rawValue === 0
    property bool   _showVoltage:       _indicatorDisplay.rawValue === 1
    property bool   _showBoth:          _indicatorDisplay.rawValue === 2
    property bool   compactVoltageDisplay: false

    // Properties to hold the thresholds
    property int threshold1: _batterySettings.threshold1.rawValue
    property int threshold2: _batterySettings.threshold2.rawValue   

    Row {
        id:             batteryIndicatorRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        anchors.right:  parent.right

        property bool _connected: _activeVehicle && !_activeVehicle.vehicleLinkManager.communicationLost

        // 默认显示（未连接时）
        Loader {
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            sourceComponent:    defaultBatteryVisual
            visible:            !batteryIndicatorRow._connected || !_activeVehicle.batteries || _activeVehicle.batteries.length === 0
        }

        // 实际电池数据显示
        Repeater {
            model: _activeVehicle && _activeVehicle.batteries ? _activeVehicle.batteries : 0

            Loader {
                anchors.top:        parent.top
                anchors.bottom:     parent.bottom
                sourceComponent:    batteryVisual
                visible:            batteryIndicatorRow._connected

                property var battery: object
            }
        }
    }
    MouseArea {
        anchors.fill:   parent
        onClicked: {
            mainWindow.showIndicatorDrawer(batteryPopup, control)
        }
    }

    // 默认电池显示（未连接时）
    Component {
        id: defaultBatteryVisual

        Row {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom

            QGCColoredImage {
                height:                 ScreenTools.defaultFontPixelHeight * 1.2
                width:                  height
                sourceSize.height:      height
                sourceSize.width:       width
                source:                 "/xfressvg/Battery.svg"
                fillMode:               Image.PreserveAspectFit
                color:                  "white"
                anchors.verticalCenter: parent.verticalCenter
            }

            QGCLabel {
                text:                   "--"
                font.pointSize:         ScreenTools.mediumFontPointSize
                color:                  "white"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Component {
        id: batteryPopup

        ToolIndicatorPage {
            showExpand:         false   // 隐藏右侧扩展面板和分隔线
            waitForParameters:  control.waitForParameters
            contentComponent:   batteryContentComponent
            expandedComponent:  batteryExpandedComponent
        }
    }

    Component {
        id: batteryVisual

        Row {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom

            function getBatteryColor() {
                switch (battery.chargeState.rawValue) {
                    case MAVLink.MAV_BATTERY_CHARGE_STATE_OK:
                        if (!isNaN(battery.percentRemaining.rawValue)) {
                            if (battery.percentRemaining.rawValue > threshold1) {
                                return qgcPal.colorGreen 
                            } else if (battery.percentRemaining.rawValue > threshold2) {
                                return qgcPal.colorYellowGreen 
                            } else {
                                return qgcPal.colorYellow 
                            }
                        } else {
                            return "white"
                        }
                    case MAVLink.MAV_BATTERY_CHARGE_STATE_LOW:
                        return qgcPal.colorOrange
                    case MAVLink.MAV_BATTERY_CHARGE_STATE_CRITICAL:
                    case MAVLink.MAV_BATTERY_CHARGE_STATE_EMERGENCY:
                    case MAVLink.MAV_BATTERY_CHARGE_STATE_FAILED:
                    case MAVLink.MAV_BATTERY_CHARGE_STATE_UNHEALTHY:
                        return qgcPal.colorRed
                    default:
                        return "white"
                }
            }    

            function getBatterySvgSource() {
                switch (battery.chargeState.rawValue) {
                    case MAVLink.MAV_BATTERY_CHARGE_STATE_OK:
                        if (!isNaN(battery.percentRemaining.rawValue)) {
                            if (battery.percentRemaining.rawValue > threshold1) {
                                return "/xfressvg/BatteryGreen.svg"
                            } else if (battery.percentRemaining.rawValue > threshold2) {
                                return "/xfressvg/BatteryYellowGreen.svg"
                            } else {
                                return "/xfressvg/BatteryYellow.svg"
                            } 
                        }
                    case MAVLink.MAV_BATTERY_CHARGE_STATE_LOW:
                        return "/xfressvg/BatteryOrange.svg" // Low with orange svg
                    case MAVLink.MAV_BATTERY_CHARGE_STATE_CRITICAL:
                        return "/xfressvg/BatteryCritical.svg" // Critical with red svg
                    case MAVLink.MAV_BATTERY_CHARGE_STATE_EMERGENCY:
                    case MAVLink.MAV_BATTERY_CHARGE_STATE_FAILED:
                    case MAVLink.MAV_BATTERY_CHARGE_STATE_UNHEALTHY:
                        return "/xfressvg/BatteryEMERGENCY.svg" // Exclamation mark
                    default:
                        return "/xfressvg/Battery.svg" // Fallback if percentage is unavailable
                }
            }

            function getBatteryPercentageText() {
                if (!_activeVehicle || _activeVehicle.vehicleLinkManager.communicationLost) {
                    return "--"
                }
                if (!isNaN(battery.percentRemaining.rawValue)) {
                    if (battery.percentRemaining.rawValue > 98.9) {
                        return qsTr("100%")
                    } else {
                        return battery.percentRemaining.valueString + battery.percentRemaining.units
                    }
                } else if (!isNaN(battery.voltage.rawValue)) {
                    return battery.voltage.valueString + battery.voltage.units
                } else if (battery.chargeState.rawValue !== MAVLink.MAV_BATTERY_CHARGE_STATE_UNDEFINED) {
                    return battery.chargeState.enumStringValue
                }
                return "--"
            }

            function getBatteryVoltageText() {
                if (!_activeVehicle || _activeVehicle.vehicleLinkManager.communicationLost) {
                    return "--"
                }
                if (!isNaN(battery.voltage.rawValue)) {
                    return battery.voltage.valueString + battery.voltage.units
                } else if (!compactVoltageDisplay && battery.chargeState.rawValue !== MAVLink.MAV_BATTERY_CHARGE_STATE_UNDEFINED) {
                    return battery.chargeState.enumStringValue
                }
                return "--"
            }

            QGCColoredImage {
                height:                 ScreenTools.defaultFontPixelHeight * 1.2
                width:                  height
                sourceSize.height:      height
                sourceSize.width:       width
                source:                 getBatterySvgSource()
                fillMode:               Image.PreserveAspectFit
                color:                  getBatteryColor()
                anchors.verticalCenter: parent.verticalCenter
            }

           ColumnLayout {
                id:                     batteryInfoColumn
                anchors.verticalCenter: parent.verticalCenter
                spacing:                0

                QGCLabel {
                    Layout.alignment:       Qt.AlignHCenter
                    verticalAlignment:      Text.AlignVCenter
                    color:                  "white"
                    text:                   getBatteryPercentageText()
                    font.pointSize:         compactVoltageDisplay || _showBoth ? ScreenTools.defaultFontPointSize : ScreenTools.mediumFontPointSize
                    visible:                !compactVoltageDisplay && (_showBoth || _showPercentage)
                }

                QGCLabel {
                    Layout.alignment:       Qt.AlignHCenter
                    font.pointSize:         compactVoltageDisplay || _showBoth ? ScreenTools.defaultFontPointSize : ScreenTools.mediumFontPointSize
                    color:                  "white"
                    text:                   getBatteryVoltageText()
                    visible:                compactVoltageDisplay || _showBoth || _showVoltage
                }
            }
        }
    }

    Component {
        id: batteryContentComponent

        ColumnLayout {
            spacing: ScreenTools.defaultFontPixelHeight / 2

            Component {
                id: batteryValuesAvailableComponent

                QtObject {
                    property bool functionAvailable:         battery.function.rawValue !== MAVLink.MAV_BATTERY_FUNCTION_UNKNOWN
                    property bool showFunction:              functionAvailable && battery.function.rawValue != MAVLink.MAV_BATTERY_FUNCTION_ALL
                    property bool temperatureAvailable:      !isNaN(battery.temperature.rawValue)
                    property bool currentAvailable:          !isNaN(battery.current.rawValue)
                    property bool mahConsumedAvailable:      !isNaN(battery.mahConsumed.rawValue)
                    property bool timeRemainingAvailable:    !isNaN(battery.timeRemaining.rawValue)
                    property bool percentRemainingAvailable: !isNaN(battery.percentRemaining.rawValue)
                    property bool chargeStateAvailable:      battery.chargeState.rawValue !== MAVLink.MAV_BATTERY_CHARGE_STATE_UNDEFINED
                }
            }

            //电量显示方式切换下拉框（百分比/电压/两者），保留在左侧电池信息顶部
            LabelledFactComboBox {
                label:  qsTr("Value")
                fact:   _valueDisplayFact

                property Fact _valueDisplayFact: QGroundControl.settingsManager.batteryIndicatorSettings.valueDisplay
            }

            Repeater {
                model: _activeVehicle ? _activeVehicle.batteries : 0

                SettingsGroupLayout {
                    heading:        qsTr("Battery %1").arg(_activeVehicle.batteries.length === 1 ? qsTr("Status") : object.id.rawValue)
                    contentSpacing: 0
                    showDividers:   false

                    property var batteryValuesAvailable: batteryValuesAvailableLoader.item

                    Loader {
                        id:                 batteryValuesAvailableLoader
                        sourceComponent:    batteryValuesAvailableComponent

                        property var battery: object
                    }

                    LabelledLabel {
                        label:  qsTr("Charge State")
                        labelText:  object.chargeState.enumStringValue
                        visible:    batteryValuesAvailable.chargeStateAvailable
                    }

                    LabelledLabel {
                        label:      qsTr("Remaining")
                        labelText:  object.timeRemainingStr.value
                        visible:    batteryValuesAvailable.timeRemainingAvailable
                    }

                    LabelledLabel {
                        label:      qsTr("Remaining")
                        labelText:  object.percentRemaining.valueString + " " + object.percentRemaining.units
                        visible:    batteryValuesAvailable.percentRemainingAvailable
                    }

                    LabelledLabel {
                        label:      qsTr("Voltage")
                        labelText:  object.voltage.valueString + " " + object.voltage.units
                    }

                    LabelledLabel {
                        label:      qsTr("Consumed")
                        labelText:  object.mahConsumed.valueString + " " + object.mahConsumed.units
                        visible:    batteryValuesAvailable.mahConsumedAvailable
                    }

                    LabelledLabel {
                        label:      qsTr("Temperature")
                        labelText:  object.temperature.valueString + " " + object.temperature.units
                        visible:    batteryValuesAvailable.temperatureAvailable
                    }

                    LabelledLabel {
                        label:      qsTr("Function")
                        labelText:  object.function.enumStringValue
                        visible:    batteryValuesAvailable.showFunction
                    }
                }
            }
        }
    }

    Component {
        id: batteryExpandedComponent

        ColumnLayout {
            spacing: ScreenTools.defaultFontPixelHeight / 2

            FactPanelController { id: controller }

            SettingsGroupLayout {
                heading:            qsTr("Battery Display")
                Layout.fillWidth:   true

                ColumnLayout {
                    QGCLabel { text: qsTr("Coloring") }

                    RowLayout {
                        spacing: ScreenTools.defaultFontPixelWidth * 0.05  // Reduced spacing between elements

                        // Battery 100%
                        RowLayout {
                            spacing: ScreenTools.defaultFontPixelWidth * 0.05  // Tighter spacing for icon and label
                            QGCColoredImage {
                                source: "/qmlimages/BatteryGreen.svg"
                                width: ScreenTools.defaultFontPixelWidth * 6
                                height: width
                                fillMode: Image.PreserveAspectFit
                                color: qgcPal.colorGreen
                            }
                            QGCLabel { text: qsTr("100%") }
                        }

                        // Threshold 1
                        RowLayout {
                            spacing: ScreenTools.defaultFontPixelWidth * 0.05  // Tighter spacing for icon and field
                            QGCColoredImage {
                                source: "/qmlimages/BatteryYellowGreen.svg"
                                width: ScreenTools.defaultFontPixelWidth * 6
                                height: width
                                fillMode: Image.PreserveAspectFit
                                color: qgcPal.colorYellowGreen
                            }
                            FactTextField {
                                id: threshold1Field
                                fact: _batterySettings.threshold1
                                implicitWidth: ScreenTools.defaultFontPixelWidth * 6
                                height: ScreenTools.defaultFontPixelHeight * 1.5
                                enabled: fact.visible
                                onEditingFinished: {
                                    // Validate and set the new threshold value
                                    _batterySettings.setThreshold1(parseInt(text));
                                }
                            }
                        }

                        // Threshold 2
                        RowLayout {
                            spacing: ScreenTools.defaultFontPixelWidth * 0.05  // Tighter spacing for icon and field
                            QGCColoredImage {
                                source: "/qmlimages/BatteryYellow.svg"
                                width: ScreenTools.defaultFontPixelWidth * 6
                                height: width
                                fillMode: Image.PreserveAspectFit
                                color: qgcPal.colorYellow
                            }
                            FactTextField {
                                fact: _batterySettings.threshold2
                                implicitWidth: ScreenTools.defaultFontPixelWidth * 6
                                height: ScreenTools.defaultFontPixelHeight * 1.5
                                enabled: fact.visible
                                onEditingFinished: {
                                    // Validate and set the new threshold value
                                    _batterySettings.setThreshold2(parseInt(text));                                
                                }
                            }
                        }

                        // Low state
                        RowLayout {
                            spacing: ScreenTools.defaultFontPixelWidth * 0.05  // Tighter spacing for icon and label
                            QGCColoredImage {
                                source: "/qmlimages/BatteryOrange.svg"
                                width: ScreenTools.defaultFontPixelWidth * 6
                                height: width
                                fillMode: Image.PreserveAspectFit
                                color: qgcPal.colorOrange
                            }
                            QGCLabel { text: qsTr("Low") }
                        }

                        // Critical state
                        RowLayout {
                            spacing: ScreenTools.defaultFontPixelWidth * 0.05  // Tighter spacing for icon and label
                            QGCColoredImage {
                                source: "/qmlimages/BatteryCritical.svg"
                                width: ScreenTools.defaultFontPixelWidth * 6
                                height: width
                                fillMode: Image.PreserveAspectFit
                                color: qgcPal.colorRed
                            }
                            QGCLabel { text: qsTr("Critical") }
                        }
                    }
                }
            }

            Loader {
                Layout.fillWidth: true
                sourceComponent: expandedPageComponent
            }

            SettingsGroupLayout {
                visible: _activeVehicle.autopilotPlugin.knownVehicleComponentAvailable(AutoPilotPlugin.KnownPowerVehicleComponent) &&
                            QGroundControl.corePlugin.showAdvancedUI

                LabelledButton {
                    label:      qsTr("Vehicle Power")
                    buttonText: qsTr("Configure")

                    onClicked: {
                        mainWindow.showKnownVehicleComponentConfigPage(AutoPilotPlugin.KnownPowerVehicleComponent)
                        mainWindow.closeIndicatorDrawer()
                    }
                }                
            }
        }
    }
}
