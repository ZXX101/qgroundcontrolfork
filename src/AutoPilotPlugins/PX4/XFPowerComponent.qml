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
import QtQuick.Dialogs
import QtQuick.Layouts

import QGroundControl
import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.Palette
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Controllers
import QGroundControl.AutoPilotPlugins.PX4

SetupPage {
    id:             powerPage
    pageComponent:  powerPageComponent
    pageName:       ""
    pageDescription: ""

    property real _margins: ScreenTools.defaultFontPixelHeight

    PowerComponentController {
        id:                     controller
        onOldFirmware:          mainWindow.showMessageDialog(qsTr("ESC Calibration"),           qsTr("%1 cannot perform ESC Calibration with this version of firmware. You will need to upgrade to a newer firmware.").arg(QGroundControl.appName))
        onNewerFirmware:        mainWindow.showMessageDialog(qsTr("ESC Calibration"),           qsTr("%1 cannot perform ESC Calibration with this version of firmware. You will need to upgrade %1.").arg(QGroundControl.appName))
        onDisconnectBattery:    mainWindow.showMessageDialog(qsTr("ESC Calibration failed"),    qsTr("You must disconnect the battery prior to performing ESC Calibration. Disconnect your battery and try again."))
        onConnectBattery:       escCalibrationDlgComponent.createObject(mainWindow).open()
    }

    Component {
        id: powerPageComponent

        Flow {
            id:         flowLayout
            width:      availableWidth
            spacing:    _margins

            property int _indexedBatteryParamCount:  getIndexedBatteryParamCount()

            function getIndexedBatteryParamCount() {
                var batteryIndex = 1
                do {
                    if (!controller.parameterExists(-1, "BAT#_SOURCE".replace("#", batteryIndex))) {
                        return batteryIndex - 1
                    }
                    batteryIndex++
                } while (true)
            }

            property Fact   _batt1Source:            controller.getParameterFact(-1, "BAT1_SOURCE")
            property Fact   _batt2Source:            controller.getParameterFact(-1, "BAT2_SOURCE", false)
            property bool   _batt2SourceAvailable:   controller.parameterExists(-1, "BAT2_SOURCE")
            property bool   _batt1SourceEnabled:     _batt1Source.rawValue !== -1
            property bool   _batt2SourceEnabled:     _batt2SourceAvailable && _batt2Source.rawValue !== -1
            property bool   _batt1ParamsAvailable:   controller.parameterExists(-1, "BAT1_CAPACITY")
            property bool   _batt2ParamsAvailable:   controller.parameterExists(-1, "BAT2_CAPACITY")
            property bool   _showBatt1Reboot:        _batt1SourceEnabled && !_batt1ParamsAvailable
            property bool   _showBatt2Reboot:        _batt2SourceEnabled && !_batt2ParamsAvailable
            property Fact   _uavcanEnable:           controller.getParameterFact(-1, "UAVCAN_ENABLE", false)

            property string _restartRequired: qsTr("Requires vehicle reboot")

            QGCPalette { id: ggcPal; colorGroupEnabled: true }

            Column {
                spacing: _margins / 2
                visible: !_batt1SourceEnabled || !_batt1ParamsAvailable

                QGCLabel {
                    text:       qsTr("Battery 1")
                    font.bold:  true
                }

                Rectangle {
                    width:  batt1Column.x + batt1Column.width + _margins
                    height: batt1Column.y + batt1Column.height + _margins
                    color:  ggcPal.windowShade

                    ColumnLayout {
                        id:                 batt1Column
                        anchors.margins:    _margins
                        anchors.top:        parent.top
                        anchors.left:       parent.left
                        spacing:            ScreenTools.defaultFontPixelWidth

                        RowLayout {
                            spacing: ScreenTools.defaultFontPixelWidth

                            QGCLabel { text: qsTr("Battery1 source:") }
                            FactComboBox {
                                fact:           _batt1Source
                                indexModel:     false
                                sizeToContents: true
                            }
                        }

                        QGCLabel {
                            text:       _restartRequired
                            visible:    _showBatt1Reboot
                        }

                        QGCButton {
                            text:       qsTr("Reboot vehicle")
                            visible:    _showBatt1Reboot
                            onClicked:  controller.vehicle.rebootVehicle()
                        }
                    }
                }
            }

            Column {
                id:         _batt1FullSettings
                spacing:    _margins / 2
                visible:    _batt1SourceEnabled && _batt1ParamsAvailable

                QGCLabel {
                    text:       qsTr("Battery 1")
                    font.bold:  true
                }

                Rectangle {
                    width:  battery1Loader.x + battery1Loader.width + _margins
                    height: battery1Loader.y + battery1Loader.height + _margins
                    color:  ggcPal.windowShade

                    Loader {
                        id:                 battery1Loader
                        anchors.margins:    _margins
                        anchors.top:        parent.top
                        anchors.left:       parent.left
                        sourceComponent:    _batt1FullSettings.visible ? batterySetupComponent : undefined

                        property int    _batteryIndex: 1
                        property var    _controller:   controller
                    }
                }
            }

            Column {
                spacing: _margins / 2
                visible: _batt2SourceAvailable && (!_batt2SourceEnabled || !_batt2ParamsAvailable)

                QGCLabel {
                    text:       qsTr("Battery 2")
                    font.bold:  true
                }

                Rectangle {
                    width:  batt2Column.x + batt2Column.width + _margins
                    height: batt2Column.y + batt2Column.height + _margins
                    color:  ggcPal.windowShade

                    ColumnLayout {
                        id:                 batt2Column
                        anchors.margins:    _margins
                        anchors.top:        parent.top
                        anchors.left:       parent.left
                        spacing:            ScreenTools.defaultFontPixelWidth

                        RowLayout {
                            spacing: ScreenTools.defaultFontPixelWidth

                            QGCLabel { text: qsTr("Battery2 source:") }
                            FactComboBox {
                                fact:           _batt2Source
                                indexModel:     false
                                sizeToContents: true
                            }
                        }

                        QGCLabel {
                            text:       _restartRequired
                            visible:    _showBatt2Reboot
                        }

                        QGCButton {
                            text:       qsTr("Reboot vehicle")
                            visible:    _showBatt2Reboot
                            onClicked:  controller.vehicle.rebootVehicle()
                        }
                    }
                }
            }

            Column {
                id:         batt2FullSettings
                spacing:    _margins / 2
                visible:    _batt2SourceEnabled && _batt2ParamsAvailable

                QGCLabel {
                    text:       qsTr("Battery 2")
                    font.bold:  true
                }

                Rectangle {
                    width:  battery2Loader.x + battery2Loader.width + _margins
                    height: battery2Loader.y + battery2Loader.height + _margins
                    color:  ggcPal.windowShade

                    Loader {
                        id:                 battery2Loader
                        anchors.margins:    _margins
                        anchors.top:        parent.top
                        anchors.left:       parent.left
                        sourceComponent:    batt2FullSettings.visible ? batterySetupComponent : undefined

                        property int    _batteryIndex: 2
                        property var    _controller:   controller
                    }
                }
            }

            Column {
                spacing:    _margins / 2

                QGCLabel {
                    text:       qsTr("ESC Calibration")
                    font.bold:  true
                }

                Rectangle {
                    width:  escCalibrationHolder.x + escCalibrationHolder.width + _margins
                    height: escCalibrationHolder.y + escCalibrationHolder.height + _margins
                    color:  ggcPal.windowShade

                    Column {
                        id:         escCalibrationHolder
                        x:          _margins
                        y:          _margins
                        spacing:    _margins

                        Column {
                            spacing: _margins

                            QGCLabel {
                                text:   qsTr("WARNING: Remove props prior to calibration!")
                                color:  qgcPal.warningText
                            }

                            QGCLabel {
                                text: qsTr("You must use USB connection for this operation.")
                            }

                            QGCButton {
                                text:       qsTr("Calibrate")
                                width:      ScreenTools.defaultFontPixelWidth * 20
                                onClicked:  controller.calibrateEsc()
                            }
                        }
                    }
                }
            }

            Column {
                spacing:    _margins / 2
                visible:    _uavcanEnable && _uavcanEnable.rawValue !== 0

                QGCCheckBox {
                    id:         showUAVCAN
                    text:       qsTr("Show UAVCAN Settings")
                    checked:    true
                }
            }

            Column {
                spacing:    _margins / 2
                visible:    showUAVCAN.checked && _uavcanEnable && _uavcanEnable.rawValue !== 0

                QGCLabel {
                    text:       qsTr("UAVCAN Bus Configuration")
                    font.bold:  true
                }

                Rectangle {
                    width:  uavcanColumn.x + uavcanColumn.width + _margins
                    height: uavcanColumn.y + uavcanColumn.height + _margins
                    color:  ggcPal.windowShade

                    Column {
                        id:         uavcanColumn
                        x:          _margins
                        y:          _margins
                        spacing:    _margins

                        Row {
                            spacing: ScreenTools.defaultFontPixelWidth

                            FactComboBox {
                                id:     _uavcanEnabledCheckBox
                                width:  ScreenTools.defaultFontPixelWidth * 20
                                fact:   _uavcanEnable
                                indexModel: false
                            }

                            QGCLabel {
                                anchors.verticalCenter: parent.verticalCenter
                                text:                   qsTr("Change required restart")
                            }
                        }
                    }
                }
            }

            Column {
                spacing:    _margins / 2
                visible:    showUAVCAN.checked && _uavcanEnable && _uavcanEnable.rawValue !== 0

                QGCLabel {
                    text:       qsTr("UAVCAN Motor Index and Direction Assignment")
                    font.bold:  true
                }

                Rectangle {
                    width:  uavcanAssignColumn.x + uavcanAssignColumn.width + _margins
                    height: uavcanAssignColumn.y + uavcanAssignColumn.height + _margins
                    color:  ggcPal.windowShade

                    Column {
                        id:         uavcanAssignColumn
                        x:          _margins
                        y:          _margins
                        spacing:    _margins

                        QGCLabel {
                            wrapMode:   Text.WordWrap
                            color:      qgcPal.warningText
                            text:       qsTr("WARNING: Propellers must be removed from vehicle prior to performing UAVCAN ESC configuration.")
                        }

                        QGCLabel {
                            wrapMode:   Text.WordWrap
                            text:       qsTr("ESC parameters will only be accessible in the editor after assignment.")
                        }

                        QGCLabel {
                            wrapMode:   Text.WordWrap
                            text:       qsTr("Start the process, then turn each motor into its turn direction, in the order of their motor indices.")
                        }

                        QGCButton {
                            text:       qsTr("Start Assignment")
                            width:      ScreenTools.defaultFontPixelWidth * 20
                            onClicked:  controller.startBusConfigureActuators()
                        }

                        QGCButton {
                            text:       qsTr("Stop Assignment")
                            width:      ScreenTools.defaultFontPixelWidth * 20
                            onClicked:  controller.stopBusConfigureActuators()
                        }
                    }
                }
            }
        }
    }

    Component {
        id: batterySetupComponent

        Column {
            spacing: _margins

            property real _margins:         ScreenTools.defaultFontPixelHeight / 2
            property real _fieldWidth:      ScreenTools.defaultFontPixelWidth * 25
            property int  batteryIndex:     _batteryIndex
            property var  _controller:      controller

            BatteryParams {
                id:             batParams
                controller:     _controller
                batteryIndex:   batteryIndex
            }

            property bool battNumCellsAvailable:        batParams.battNumCellsAvailable
            property bool battHighVoltAvailable:        batParams.battHighVoltAvailable
            property bool battLowVoltAvailable:         batParams.battLowVoltAvailable
            property bool battVoltLoadDropAvailable:    batParams.battVoltLoadDropAvailable
            property bool battVoltageDividerAvailable:  batParams.battVoltageDividerAvailable
            property bool battAmpsPerVoltAvailable:     batParams.battAmpsPerVoltAvailable

            property Fact battSource:           batParams.battSource
            property Fact battNumCells:         batParams.battNumCells
            property Fact battHighVolt:         batParams.battHighVolt
            property Fact battLowVolt:          batParams.battLowVolt
            property Fact battVoltLoadDrop:     batParams.battVoltLoadDrop
            property Fact battVoltageDivider:   batParams.battVoltageDivider
            property Fact battAmpsPerVolt:      batParams.battAmpsPerVolt

            property Fact battCapacity:         controller.getParameterFact(-1, "BAT#_CAPACITY".replace("#", batteryIndex), false)
            property bool battCapacityAvailable: controller.parameterExists(-1, "BAT#_CAPACITY".replace("#", batteryIndex))

            property FactGroup _batteryFactGroup: controller.vehicle.getFactGroup("battery" + (batteryIndex - 1))

            QGCPalette { id: qgcPal; colorGroupEnabled: true }

            GridLayout {
                columns:        3
                rowSpacing:     _margins
                columnSpacing:  _margins

                QGCLabel { text: qsTr("Battery source:") }
                FactComboBox {
                    fact:           battSource
                    indexModel:     false
                    sizeToContents: true
                }
                Item { width: 1; height: 1 }

                QGCLabel {
                    text:       qsTr("Battery capacity:")
                    visible:    battCapacityAvailable
                }
                FactTextField {
                    width:      _fieldWidth
                    fact:       battCapacity
                    visible:    battCapacityAvailable
                }
                Item { width: 1; height: 1; visible: battCapacityAvailable }

                QGCLabel {
                    text:       qsTr("Number of Cells (in Series)")
                    visible:    battNumCellsAvailable
                }
                FactTextField {
                    width:      _fieldWidth
                    fact:       battNumCells
                    showUnits:  true
                    visible:    battNumCellsAvailable
                }
                QGCLabel {
                    text:       battNumCellsAvailable && battHighVoltAvailable ?
                                    qsTr("Battery Max: %1 V").arg((battNumCells.value * battHighVolt.value).toFixed(1)) : ""
                    visible:    battNumCellsAvailable && battHighVoltAvailable
                }

                QGCLabel {
                    text:       qsTr("Empty Voltage (per cell)")
                    visible:    battLowVoltAvailable
                }
                FactTextField {
                    width:      _fieldWidth
                    fact:       battLowVolt
                    showUnits:  true
                    visible:    battLowVoltAvailable
                }
                QGCLabel {
                    text:       battNumCellsAvailable && battLowVoltAvailable ?
                                    qsTr("Battery Min: %1 V").arg((battNumCells.value * battLowVolt.value).toFixed(1)) : ""
                    visible:    battNumCellsAvailable && battLowVoltAvailable
                }

                QGCLabel {
                    text:       qsTr("Full Voltage (per cell)")
                    visible:    battHighVoltAvailable
                }
                FactTextField {
                    width:      _fieldWidth
                    fact:       battHighVolt
                    showUnits:  true
                    visible:    battHighVoltAvailable
                }
                Item { width: 1; height: 1; visible: battHighVoltAvailable }

                QGCLabel {
                    text:       qsTr("Voltage divider")
                    visible:    battVoltageDividerAvailable
                }
                FactTextField {
                    width:      _fieldWidth
                    fact:       battVoltageDivider
                    visible:    battVoltageDividerAvailable
                }
                QGCButton {
                    text:       qsTr("Calculate")
                    visible:    battVoltageDividerAvailable
                    onClicked:  calcVoltageDividerDlgComponent.createObject(mainWindow, { batteryIndex: batteryIndex }).open()
                }

                QGCLabel {
                    Layout.columnSpan:  3
                    Layout.fillWidth:   true
                    font.pointSize:     ScreenTools.smallFontPointSize
                    wrapMode:           Text.WordWrap
                    text:               qsTr("If the battery voltage reported by the vehicle is largely different than the voltage read externally using a voltmeter you can adjust the voltage multiplier value to correct this. Click the Calculate button for help with calculating a new value.")
                    visible:            battVoltageDividerAvailable
                }

                QGCLabel {
                    text:       qsTr("Amps per volt")
                    visible:    battAmpsPerVoltAvailable
                }
                FactTextField {
                    width:      _fieldWidth
                    fact:       battAmpsPerVolt
                    visible:    battAmpsPerVoltAvailable
                }
                QGCButton {
                    text:       qsTr("Calculate")
                    visible:    battAmpsPerVoltAvailable
                    onClicked:  calcAmpsPerVoltDlgComponent.createObject(mainWindow, { batteryIndex: batteryIndex }).open()
                }

                QGCLabel {
                    Layout.columnSpan:  3
                    Layout.fillWidth:   true
                    font.pointSize:     ScreenTools.smallFontPointSize
                    wrapMode:           Text.WordWrap
                    text:               qsTr("If the current draw reported by the vehicle is largely different than the current read externally using a current meter you can adjust the amps per volt value to correct this. Click the Calculate button for help with calculating a new value.")
                    visible:            battAmpsPerVoltAvailable
                }

                QGCCheckBox {
                    id:                 showAdvanced
                    Layout.columnSpan:  3
                    text:               qsTr("Show Advanced Settings")
                    visible:            battVoltLoadDropAvailable
                }

                QGCLabel {
                    text:       qsTr("Voltage Drop on Full Load (per cell)")
                    visible:    showAdvanced.checked
                }
                FactTextField {
                    width:      _fieldWidth
                    fact:       battVoltLoadDrop
                    showUnits:  true
                    visible:    showAdvanced.checked
                }
                Item { width: 1; height: 1; visible: showAdvanced.checked }

                QGCLabel {
                    Layout.columnSpan:  3
                    Layout.fillWidth:   true
                    wrapMode:           Text.WordWrap
                    font.pointSize:     ScreenTools.smallFontPointSize
                    text:               qsTr("Batteries show less voltage at high throttle. Enter the difference in Volts between idle throttle and full throttle, divided by the number of battery cells. Leave at the default if unsure.")
                    visible:            showAdvanced.checked
                }

                QGCLabel {
                    text:       qsTr("Compensated Minimum Voltage:")
                    visible:    showAdvanced.checked
                }
                QGCLabel {
                    text:       visible ? ((battNumCells.value * battLowVolt.value) - (battNumCells.value * battVoltLoadDrop.value)).toFixed(1) + qsTr(" V") : ""
                    visible:    showAdvanced.checked
                }
                Item { width: 1; height: 1; visible: showAdvanced.checked }
            }
        }
    }

    Component {
        id: calcVoltageDividerDlgComponent

        QGCPopupDialog {
            title:      qsTr("Calculate Voltage Divider")
            buttons:    Dialog.Close

            property alias batteryIndex: batParams.batteryIndex

            property var        _controller:        controller
            property FactGroup  _batteryFactGroup:  controller.vehicle.getFactGroup("battery" + (batteryIndex - 1))

            BatteryParams {
                id:             batParams
                controller:     _controller
            }

            ColumnLayout {
                spacing: ScreenTools.defaultFontPixelHeight

                QGCLabel {
                    Layout.preferredWidth:  gridLayout.width
                    wrapMode:               Text.WordWrap
                    text:                   qsTr("Measure battery voltage using an external voltmeter and enter the value below. Click Calculate to set the new voltage multiplier.")
                }

                GridLayout {
                    id:         gridLayout
                    columns:    2

                    QGCLabel { text: qsTr("Measured voltage:") }
                    QGCTextField { id: measuredVoltage; numericValuesOnly: true }

                    QGCLabel { text: qsTr("Vehicle voltage:") }
                    QGCLabel { text: _batteryFactGroup.voltage.valueString }

                    QGCLabel { text: qsTr("Voltage divider:") }
                    FactLabel { fact: batParams.battVoltageDivider }
                }

                QGCButton {
                    text: qsTr("Calculate And Set")

                    onClicked:  {
                        var measuredVoltageValue = parseFloat(measuredVoltage.text)
                        if (measuredVoltageValue === 0 || isNaN(measuredVoltageValue)) {
                            return
                        }
                        var newVoltageDivider = (measuredVoltageValue * batParams.battVoltageDivider.value) / _batteryFactGroup.voltage.value
                        if (newVoltageDivider > 0) {
                            batParams.battVoltageDivider.value = newVoltageDivider
                        }
                    }
                }
            }
        }
    }

    Component {
        id: calcAmpsPerVoltDlgComponent

        QGCPopupDialog {
            title:      qsTr("Calculate Amps per Volt")
            buttons:    Dialog.Close

            property alias batteryIndex: batParams.batteryIndex

            property var        _controller:        controller
            property FactGroup  _batteryFactGroup:  controller.vehicle.getFactGroup("battery" + (batteryIndex - 1))

            BatteryParams {
                id:             batParams
                controller:     _controller
            }

            ColumnLayout {
                spacing: ScreenTools.defaultFontPixelHeight

                QGCLabel {
                    Layout.preferredWidth:  gridLayout.width
                    wrapMode:               Text.WordWrap
                    text:                   qsTr("Measure current draw using an external current meter and enter the value below. Click Calculate to set the new amps per volt value.")
                }

                GridLayout {
                    id:         gridLayout
                    columns:    2

                    QGCLabel { text: qsTr("Measured current:") }
                    QGCTextField { id: measuredCurrent; numericValuesOnly: true }

                    QGCLabel { text: qsTr("Vehicle current:") }
                    QGCLabel { text: _batteryFactGroup.current.valueString }

                    QGCLabel { text: qsTr("Amps per volt:") }
                    FactLabel { fact: batParams.battAmpsPerVolt }
                }

                QGCButton {
                    text: qsTr("Calculate And Set")

                    onClicked:  {
                        var measuredCurrentValue = parseFloat(measuredCurrent.text)
                        if (measuredCurrentValue === 0 || isNaN(measuredCurrentValue)) {
                            return
                        }
                        var newAmpsPerVolt = (measuredCurrentValue * batParams.battAmpsPerVolt.value) / _batteryFactGroup.current.value
                        if (newAmpsPerVolt != 0) {
                            batParams.battAmpsPerVolt.value = newAmpsPerVolt
                        }
                    }
                }
            }
        }
    }

    Component {
        id: escCalibrationDlgComponent

        QGCPopupDialog {
            id:                     escCalibrationDlg
            title:                  qsTr("ESC Calibration")
            buttons:                Dialog.Ok
            acceptButtonEnabled:    false

            readonly property string _highlightPrefix: "<font color=\"" + qgcPal.warningText + "\">"
            readonly property string _highlightSuffix: "</font>"

            Connections {
                target: controller

                onBatteryConnected:     textLabel.text = qsTr("Performing calibration. This will take a few seconds..")
                onCalibrationFailed:    { escCalibrationDlg.acceptButtonEnabled = true; textLabel.text = _highlightPrefix + qsTr("ESC Calibration failed. ") + _highlightSuffix + errorMessage }
                onCalibrationSuccess:   { escCalibrationDlg.acceptButtonEnabled = true; textLabel.text = qsTr("Calibration complete. You can disconnect your battery now if you like.") }
            }

            ColumnLayout {
                QGCLabel {
                    id:                     textLabel
                    wrapMode:               Text.WordWrap
                    text:                   _highlightPrefix + qsTr("WARNING: Props must be removed from vehicle prior to performing ESC calibration.") + _highlightSuffix + qsTr(" Connect the battery now and calibration will begin.")
                    Layout.fillWidth:       true
                    Layout.maximumWidth:    mainWindow.width / 2
                }
            }
        }
    }
}
