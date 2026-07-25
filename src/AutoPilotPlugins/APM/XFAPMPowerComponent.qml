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

import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.Palette
import QGroundControl.Controls
import QGroundControl.ScreenTools

SetupPage {
    id:             powerPage
    pageComponent:  powerPageComponent
    pageName:       ""
    pageDescription: ""

    FactPanelController {
        id:         controller
    }

    Component {
        id: powerPageComponent

        Flow {
            id:         flowLayout
            x:          ScreenTools.defaultFontPixelWidth * 2
            width:      availableWidth - ScreenTools.defaultFontPixelWidth * 2
            spacing:    _margins

            property Fact _batt1Monitor:            controller.getParameterFact(-1, "BATT_MONITOR")
            property Fact _batt2Monitor:            controller.getParameterFact(-1, "BATT2_MONITOR", false /* reportMissing */)
            property bool _batt2MonitorAvailable:   controller.parameterExists(-1, "BATT2_MONITOR")
            property bool _batt1MonitorEnabled:     _batt1Monitor.rawValue !== 0
            property bool _batt2MonitorEnabled:     _batt2MonitorAvailable && _batt2Monitor.rawValue !== 0
            property bool _batt1ParamsAvailable:    controller.parameterExists(-1, "BATT_CAPACITY")
            property bool _batt2ParamsAvailable:    controller.parameterExists(-1, "BATT2_CAPACITY")
            property bool _showBatt1Reboot:         _batt1MonitorEnabled && !_batt1ParamsAvailable
            property bool _showBatt2Reboot:         _batt2MonitorEnabled && !_batt2ParamsAvailable
            property bool _escCalibrationAvailable: controller.parameterExists(-1, "ESC_CALIBRATION")
            property Fact _escCalibration:          controller.getParameterFact(-1, "ESC_CALIBRATION", false /* reportMissing */)

            property string _restartRequired: qsTr("Requires vehicle reboot")

            QGCPalette { id: ggcPal; colorGroupEnabled: true }

            // Battery1 Monitor settings only - used when only monitor param is available
            Column {
                spacing: _margins / 2
                visible: !_batt1MonitorEnabled || !_batt1ParamsAvailable

                QGCLabel {
                    text:       qsTr("Battery 1")
                    font.bold:   true
                }

                Rectangle {
                    width:  batt1Content.implicitWidth + _margins * 2
                    height: batt1Content.implicitHeight + _margins * 2
                    color:  ggcPal.windowShade
                    radius: ScreenTools.defaultFontPixelWidth * 0.5

                    ColumnLayout {
                        id:                 batt1Content
                        anchors.centerIn:   parent
                        spacing:            ScreenTools.defaultFontPixelWidth

                        RowLayout {
                            Layout.fillWidth:   true
                            spacing:            ScreenTools.defaultFontPixelWidth

                            QGCLabel { text: qsTr("Battery1 monitor:") }
                            Item { Layout.fillWidth: true }
                            FactComboBox {
                                id:         monitor1Combo
                                fact:       _batt1Monitor
                                indexModel: false
                                sizeToContents: true
                            }
                        }

                        QGCLabel {
                            text:       _restartRequired
                            visible:    _showBatt1Reboot
                        }

                        QGCButton {
                            Layout.alignment: Qt.AlignRight
                            text:       qsTr("Reboot vehicle")
                            visible:    _showBatt1Reboot
                            onClicked:  controller.vehicle.rebootVehicle()
                        }
                    }
                }
            }

            // Battery 1 settings
            Column {
                id:         _batt1FullSettings
                spacing:    _margins / 2
                visible:    _batt1MonitorEnabled && _batt1ParamsAvailable

                property Fact _battMonitor:      controller.getParameterFact(-1, "BATT_MONITOR", false)
                property Fact _battCapacity:     controller.getParameterFact(-1, "BATT_CAPACITY", false)
                property Fact _armVoltMin:       controller.getParameterFact(-1, "r.BATT_ARM_VOLT", false)

                QGCLabel {
                    text:       qsTr("Battery 1")
                    font.bold:   true
                }

                Rectangle {
                    width:  battery1Content.implicitWidth + _margins * 2
                    height: battery1Content.implicitHeight + _margins * 2
                    color:  ggcPal.windowShade
                    radius: ScreenTools.defaultFontPixelWidth * 0.5

                    ColumnLayout {
                        id:                 battery1Content
                        anchors.centerIn:   parent
                        spacing:            ScreenTools.defaultFontPixelWidth

                        RowLayout {
                            Layout.fillWidth:   true
                            spacing:            ScreenTools.defaultFontPixelWidth

                            QGCLabel { text: qsTr("Battery monitor:") }
                            Item { Layout.fillWidth: true }
                            FactComboBox {
                                fact:       _batt1FullSettings._battMonitor
                                indexModel: false
                                sizeToContents: true
                            }
                        }

                        RowLayout {
                            Layout.fillWidth:   true
                            spacing:            ScreenTools.defaultFontPixelWidth

                            QGCLabel { text: qsTr("Battery capacity:") }
                            Item { Layout.fillWidth: true }
                            FactTextField {
                                fact:   _batt1FullSettings._battCapacity
                            }
                        }

                        RowLayout {
                            Layout.fillWidth:   true
                            spacing:            ScreenTools.defaultFontPixelWidth

                            QGCLabel { text: qsTr("Minimum arming voltage:") }
                            Item { Layout.fillWidth: true }
                            FactTextField {
                                fact:   _batt1FullSettings._armVoltMin
                            }
                        }
                    }
                }
            }

            // Battery2 Monitor settings only - used when only monitor param is available
            Column {
                spacing: _margins / 2
                visible: !_batt2MonitorEnabled || !_batt2ParamsAvailable

                QGCLabel {
                    text:       qsTr("Battery 2")
                    font.bold:   true
                }

                Rectangle {
                    width:  batt2Content.implicitWidth + _margins * 2
                    height: batt2Content.implicitHeight + _margins * 2
                    color:  ggcPal.windowShade
                    radius: ScreenTools.defaultFontPixelWidth * 0.5

                    ColumnLayout {
                        id:                 batt2Content
                        anchors.centerIn:   parent
                        spacing:            ScreenTools.defaultFontPixelWidth

                        RowLayout {
                            Layout.fillWidth:   true
                            spacing:            ScreenTools.defaultFontPixelWidth

                            QGCLabel { text: qsTr("Battery2 monitor:") }
                            Item { Layout.fillWidth: true }
                            FactComboBox {
                                id:         monitor2Combo
                                fact:       _batt2Monitor
                                indexModel: false
                                sizeToContents: true
                            }
                        }

                        QGCLabel {
                            text:       _restartRequired
                            visible:    _showBatt2Reboot
                        }

                        QGCButton {
                            Layout.alignment: Qt.AlignRight
                            text:       qsTr("Reboot vehicle")
                            visible:    _showBatt2Reboot
                            onClicked:  controller.vehicle.rebootVehicle()
                        }
                    }
                }
            }

            // Battery 2 settings - Used when full params are available
            Column {
                id:         batt2FullSettings
                spacing:    _margins / 2
                visible:    _batt2MonitorEnabled && _batt2ParamsAvailable

                property Fact _battMonitor:      controller.getParameterFact(-1, "BATT2_MONITOR", false)
                property Fact _battCapacity:     controller.getParameterFact(-1, "BATT2_CAPACITY", false)
                property Fact _armVoltMin:       controller.getParameterFact(-1, "r.BATT2_ARM_VOLT", false)

                QGCLabel {
                    text:       qsTr("Battery 2")
                    font.bold:   true
                }

                Rectangle {
                    width:  battery2Content.implicitWidth + _margins * 2
                    height: battery2Content.implicitHeight + _margins * 2
                    color:  ggcPal.windowShade
                    radius: ScreenTools.defaultFontPixelWidth * 0.5

                    ColumnLayout {
                        id:                 battery2Content
                        anchors.centerIn:   parent
                        spacing:            ScreenTools.defaultFontPixelWidth

                        RowLayout {
                            Layout.fillWidth:   true
                            spacing:            ScreenTools.defaultFontPixelWidth

                            QGCLabel { text: qsTr("Battery monitor:") }
                            Item { Layout.fillWidth: true }
                            FactComboBox {
                                fact:       batt2FullSettings._battMonitor
                                indexModel: false
                                sizeToContents: true
                            }
                        }

                        RowLayout {
                            Layout.fillWidth:   true
                            spacing:            ScreenTools.defaultFontPixelWidth

                            QGCLabel { text: qsTr("Battery capacity:") }
                            Item { Layout.fillWidth: true }
                            FactTextField {
                                fact:   batt2FullSettings._battCapacity
                            }
                        }

                        RowLayout {
                            Layout.fillWidth:   true
                            spacing:            ScreenTools.defaultFontPixelWidth

                            QGCLabel { text: qsTr("Minimum arming voltage:") }
                            Item { Layout.fillWidth: true }
                            FactTextField {
                                fact:   batt2FullSettings._armVoltMin
                            }
                        }
                    }
                }
            }

            Column {
                spacing:    _margins / 2
                visible:    false // _escCalibrationAvailable

                QGCLabel {
                    text:       qsTr("ESC Calibration")
                    font.bold:   true
                }

                Rectangle {
                    width:  escCalibrationHolder.implicitWidth + _margins * 2
                    height: escCalibrationHolder.implicitHeight + _margins * 2
                    color:  ggcPal.windowShade
                    radius: ScreenTools.defaultFontPixelWidth * 0.5

                    Column {
                        id:         escCalibrationHolder
                        anchors.centerIn: parent
                        spacing:    _margins

                        Column {
                            spacing: _margins

                            QGCLabel {
                                text:   qsTr("WARNING: Remove props prior to calibration!")
                                color:  qgcPal.warningText
                            }

                            Row {
                                spacing: _margins

                                QGCButton {
                                    text: qsTr("Calibrate")
                                    enabled:    _escCalibration && _escCalibration.rawValue === 0
                                    onClicked:  if(_escCalibration) _escCalibration.rawValue = 3
                                }

                                Column {
                                    enabled: _escCalibration && _escCalibration.rawValue === 3
                                    QGCLabel { text:   _escCalibration ? (_escCalibration.rawValue === 3 ? qsTr("Now perform these steps:") : qsTr("Click Calibrate to start, then:")) : "" }
                                    QGCLabel { text:   qsTr("- Disconnect USB and battery so flight controller powers down") }
                                    QGCLabel { text:   qsTr("- Connect the battery") }
                                    QGCLabel { text:   qsTr("- The arming tone will be played (if the vehicle has a buzzer attached)") }
                                    QGCLabel { text:   qsTr("- If using a flight controller with a safety button press it until it displays solid red") }
                                    QGCLabel { text:   qsTr("- You will hear a musical tone then two beeps") }
                                    QGCLabel { text:   qsTr("- A few seconds later you should hear a number of beeps (one for each battery cell you're using)") }
                                    QGCLabel { text:   qsTr("- And finally a single long beep indicating the end points have been set and the ESC is calibrated") }
                                    QGCLabel { text:   qsTr("- Disconnect the battery and power up again normally") }
                                }
                            }
                        }
                    }
                }
            }
        } // Flow
    } // Component - powerPageComponent

    Component {
        id: calcVoltageMultiplierDlgComponent

        QGCPopupDialog {
            title:      qsTr("Calculate Voltage Multiplier")
            buttons:    Dialog.Close

            property Fact vehicleVoltageFact
            property Fact battVoltMultFact

            ColumnLayout {
                spacing: ScreenTools.defaultFontPixelHeight

                QGCLabel {
                    Layout.preferredWidth:  gridLayout.width
                    wrapMode:               Text.WordWrap
                    text:                   qsTr("Measure battery voltage using an external voltmeter and enter the value below. Click Calculate to set the new adjusted voltage multiplier.")
                }

                GridLayout {
                    id:         gridLayout
                    columns:    2

                    QGCLabel {
                        text: qsTr("Measured voltage:")
                    }
                    QGCTextField { id: measuredVoltage }

                    QGCLabel { text: qsTr("Vehicle voltage:") }
                    FactLabel { fact: vehicleVoltageFact }

                    QGCLabel { text: qsTr("Voltage multiplier:") }
                    FactLabel { fact: battVoltMultFact }
                }

                QGCButton {
                    text: qsTr("Calculate And Set")

                    onClicked:  {
                        var measuredVoltageValue = parseFloat(measuredVoltage.text)
                        if (measuredVoltageValue === 0 || isNaN(measuredVoltageValue) || !vehicleVoltageFact || !battVoltMultFact) {
                            return
                        }
                        var newVoltageMultiplier = (vehicleVoltageFact.value !== 0) ? (measuredVoltageValue * battVoltMultFact.value) / vehicleVoltageFact.value : 0
                        if (newVoltageMultiplier > 0) {
                            battVoltMultFact.value = newVoltageMultiplier
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

            property Fact vehicleCurrentFact
            property Fact battAmpPerVoltFact

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

                    QGCLabel {
                        text: qsTr("Measured current:")
                    }
                    QGCTextField { id: measuredCurrent }

                    QGCLabel { text: qsTr("Vehicle current:") }
                    FactLabel { fact: vehicleCurrentFact }

                    QGCLabel { text: qsTr("Amps per volt:") }
                    FactLabel { fact: battAmpPerVoltFact }
                }

                QGCButton {
                    text: qsTr("Calculate And Set")

                    onClicked:  {
                        var measuredCurrentValue = parseFloat(measuredCurrent.text)
                        if (measuredCurrentValue === 0 || isNaN(measuredCurrentValue) || !vehicleCurrentFact || !battAmpPerVoltFact) {
                            return
                        }
                        var newAmpsPerVolt = (vehicleCurrentFact.value !== 0) ? (measuredCurrentValue * battAmpPerVoltFact.value) / vehicleCurrentFact.value : 0
                        if (newAmpsPerVolt !== 0) {
                            battAmpPerVoltFact.value = newAmpsPerVolt
                        }
                    }
                }
            }
        }
    }
} // SetupPage
