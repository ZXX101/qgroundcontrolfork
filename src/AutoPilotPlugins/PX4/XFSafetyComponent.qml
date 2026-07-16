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
import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.Palette
import QGroundControl.Controls
import QGroundControl.ScreenTools

SetupPage {
    id:             safetyPage
    pageComponent:  safetyPageComponent

    Component {
        id: safetyPageComponent

        Item {
            width:  availableWidth
            height: leftColumn.height

            FactPanelController { id: controller }

            QGCPalette { id: qgcPal; colorGroupEnabled: true }

            property real _margins:     ScreenTools.defaultFontPixelHeight / 2
            property real _fieldWidth:  ScreenTools.defaultFontPixelWidth * 12

            readonly property string hitlParam: "SYS_HITL"

            property Fact _lowBattAction:       controller.getParameterFact(-1, "COM_LOW_BAT_ACT")
            property Fact _rcLossAction:        controller.getParameterFact(-1, "NAV_RCL_ACT")
            property Fact _dlLossAction:        controller.getParameterFact(-1, "NAV_DLL_ACT")
            property Fact _fenceAction:         controller.getParameterFact(-1, "GF_ACTION")
            property Fact _fenceRadius:         controller.getParameterFact(-1, "GF_MAX_HOR_DIST")
            property Fact _fenceAlt:            controller.getParameterFact(-1, "GF_MAX_VER_DIST")
            property Fact _collisionPrevention: controller.getParameterFact(-1, "CP_DIST")
            property Fact _objectAvoidance:     controller.getParameterFact(-1, "COM_OBS_AVOID")
            property Fact _rtlLandDelay:        controller.getParameterFact(-1, "RTL_LAND_DELAY")
            property Fact _disarmLandDelay:     controller.getParameterFact(-1, "COM_DISARM_LAND")
            property Fact _enableLogging:       controller.getParameterFact(-1, "SDLOG_MODE")
            property Fact _landSpeedMC:         controller.getParameterFact(-1, "MPC_LAND_SPEED", false)
            property bool _hitlAvailable:       controller.parameterExists(-1, hitlParam)
            property Fact _hitlEnabled:         controller.getParameterFact(-1, hitlParam, false)

            function rangeString(fact) {
                if (!fact) return ""
                if (fact.minIsDefaultForType && fact.maxIsDefaultForType) {
                    return ""
                }
                var min = fact.minString
                var max = fact.maxString
                if (min === "" && max === "") {
                    return ""
                }
                return "(" + min + " ~ " + max + ")"
            }

            Row {
                id:         mainRow
                spacing:    _margins * 2
                width:      parent.width

                Column {
                    id:         leftColumn
                    width:      (parent.width - mainRow.spacing) / 2
                    spacing:    _margins * 2

                    Column {
                        width:      parent.width
                        spacing:    _margins

                        QGCLabel {
                            text:       qsTr("Low Battery Failsafe")
                            font.bold:  true
                            font.pointSize: ScreenTools.mediumFontPointSize
                        }

                        Rectangle {
                            width:  parent.width
                            height: battGrid.height + _margins * 2
                            color:  qgcPal.windowShade
                            radius: ScreenTools.buttonBorderRadius

                            GridLayout {
                                id:             battGrid
                                anchors.margins: _margins
                                anchors.left:   parent.left
                                anchors.top:    parent.top
                                width:          parent.width - _margins * 2
                                columns:        2
                                columnSpacing:  _margins
                                rowSpacing:     _margins

                                QGCLabel {
                                    text: qsTr("Failsafe Action")
                                    Layout.fillWidth: true
                                }
                                FactComboBox {
                                    fact:               _lowBattAction
                                    indexModel:         false
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("Battery Warn Level") + " " + rangeString(controller.getParameterFact(-1, "BAT_LOW_THR", false))
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               controller.getParameterFact(-1, "BAT_LOW_THR")
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("Battery Failsafe Level") + " " + rangeString(controller.getParameterFact(-1, "BAT_CRIT_THR", false))
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               controller.getParameterFact(-1, "BAT_CRIT_THR")
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("Battery Emergency Level") + " " + rangeString(controller.getParameterFact(-1, "BAT_EMERGEN_THR", false))
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               controller.getParameterFact(-1, "BAT_EMERGEN_THR")
                                    Layout.preferredWidth: _fieldWidth
                                }
                            }
                        }
                    }

                    Column {
                        width:      parent.width
                        spacing:    _margins

                        QGCLabel {
                            text:       qsTr("RC Loss Failsafe")
                            font.bold:  true
                            font.pointSize: ScreenTools.mediumFontPointSize
                        }

                        Rectangle {
                            width:  parent.width
                            height: rcGrid.height + _margins * 2
                            color:  qgcPal.windowShade
                            radius: ScreenTools.buttonBorderRadius

                            GridLayout {
                                id:             rcGrid
                                anchors.margins: _margins
                                anchors.left:   parent.left
                                anchors.top:    parent.top
                                width:          parent.width - _margins * 2
                                columns:        2
                                columnSpacing:  _margins
                                rowSpacing:     _margins

                                QGCLabel {
                                    text: qsTr("Failsafe Action")
                                    Layout.fillWidth: true
                                }
                                FactComboBox {
                                    fact:               _rcLossAction
                                    indexModel:         false
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("RC Loss Timeout") + " " + rangeString(controller.getParameterFact(-1, "COM_RC_LOSS_T", false))
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               controller.getParameterFact(-1, "COM_RC_LOSS_T")
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                }
                            }
                        }
                    }

                    Column {
                        width:      parent.width
                        spacing:    _margins

                        QGCLabel {
                            text:       qsTr("Data Link Loss Failsafe")
                            font.bold:  true
                            font.pointSize: ScreenTools.mediumFontPointSize
                        }

                        Rectangle {
                            width:  parent.width
                            height: dlGrid.height + _margins * 2
                            color:  qgcPal.windowShade
                            radius: ScreenTools.buttonBorderRadius

                            GridLayout {
                                id:             dlGrid
                                anchors.margins: _margins
                                anchors.left:   parent.left
                                anchors.top:    parent.top
                                width:          parent.width - _margins * 2
                                columns:        2
                                columnSpacing:  _margins
                                rowSpacing:     _margins

                                QGCLabel {
                                    text: qsTr("Failsafe Action")
                                    Layout.fillWidth: true
                                }
                                FactComboBox {
                                    fact:               _dlLossAction
                                    indexModel:         false
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("Data Link Loss Timeout") + " " + rangeString(controller.getParameterFact(-1, "COM_DL_LOSS_T", false))
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               controller.getParameterFact(-1, "COM_DL_LOSS_T")
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                }
                            }
                        }
                    }

                    Column {
                        width:      parent.width
                        spacing:    _margins

                        QGCLabel {
                            text:       qsTr("Geofence")
                            font.bold:  true
                            font.pointSize: ScreenTools.mediumFontPointSize
                        }

                        Rectangle {
                            width:  parent.width
                            height: fenceGrid.height + _margins * 2
                            color:  qgcPal.windowShade
                            radius: ScreenTools.buttonBorderRadius

                            GridLayout {
                                id:             fenceGrid
                                anchors.margins: _margins
                                anchors.left:   parent.left
                                anchors.top:    parent.top
                                width:          parent.width - _margins * 2
                                columns:        2
                                columnSpacing:  _margins
                                rowSpacing:     _margins

                                QGCLabel {
                                    text: qsTr("Action on Breach")
                                    Layout.fillWidth: true
                                }
                                FactComboBox {
                                    fact:               _fenceAction
                                    indexModel:         false
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("Max Altitude") + " " + rangeString(_fenceAlt)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _fenceAlt
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("Max Radius") + " " + rangeString(_fenceRadius)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _fenceRadius
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                }
                            }
                        }
                    }
                }

                Column {
                    id:         rightColumn
                    width:      (parent.width - mainRow.spacing) / 2
                    spacing:    _margins * 2

                    Column {
                        width:      parent.width
                        spacing:    _margins

                        QGCLabel {
                            text:       qsTr("Object Detection")
                            font.bold:  true
                            font.pointSize: ScreenTools.mediumFontPointSize
                        }

                        Rectangle {
                            width:  parent.width
                            height: avoidGrid.height + _margins * 2
                            color:  qgcPal.windowShade
                            radius: ScreenTools.buttonBorderRadius

                            GridLayout {
                                id:             avoidGrid
                                anchors.margins: _margins
                                anchors.left:   parent.left
                                anchors.top:    parent.top
                                width:          parent.width - _margins * 2
                                columns:        2
                                columnSpacing:  _margins
                                rowSpacing:     _margins

                                QGCLabel {
                                    text: qsTr("Collision Prevention")
                                    Layout.fillWidth: true
                                }
                                QGCComboBox {
                                    model:              [qsTr("Disabled"), qsTr("Enabled")]
                                    enabled:            _collisionPrevention
                                    Layout.preferredWidth: _fieldWidth
                                    currentIndex:       _collisionPrevention ? (_collisionPrevention.rawValue > 0 ? 1 : 0) : 0
                                    onActivated: (index) => {
                                        if (_collisionPrevention) {
                                            _collisionPrevention.value = index > 0 ? 5 : -1
                                        }
                                    }
                                }

                                QGCLabel {
                                    text: qsTr("Obstacle Avoidance")
                                    Layout.fillWidth: true
                                }
                                QGCComboBox {
                                    model:              [qsTr("Disabled"), qsTr("Enabled")]
                                    enabled:            _objectAvoidance && _collisionPrevention.rawValue > 0
                                    Layout.preferredWidth: _fieldWidth
                                    currentIndex:       _objectAvoidance ? (_objectAvoidance.value === 0 ? 0 : 1) : 0
                                    onActivated: (index) => {
                                        if (_objectAvoidance) {
                                            _objectAvoidance.value = index > 0 ? 1 : 0
                                        }
                                    }
                                }

                                QGCLabel {
                                    text: qsTr("Minimum Distance") + " (" + QGroundControl.unitsConversion.appSettingsHorizontalDistanceUnitsString + ")"
                                    Layout.fillWidth: true
                                }
                                QGCSlider {
                                    enabled:                _collisionPrevention && _collisionPrevention.rawValue > 0
                                    Layout.preferredWidth:  _fieldWidth
                                    Layout.minimumHeight:   ScreenTools.defaultFontPixelHeight * 2
                                    to:                     QGroundControl.unitsConversion.metersToAppSettingsHorizontalDistanceUnits(15)
                                    from:                   QGroundControl.unitsConversion.metersToAppSettingsHorizontalDistanceUnits(1)
                                    stepSize:               1
                                    displayValue:           true
                                    live:                   false
                                    value: {
                                        if (_collisionPrevention && _collisionPrevention.rawValue > 0) {
                                            return QGroundControl.unitsConversion.metersToAppSettingsHorizontalDistanceUnits(_collisionPrevention.rawValue)
                                        } else {
                                            return 1
                                        }
                                    }
                                    onValueChanged: {
                                        if (_collisionPrevention) {
                                            if (_collisionPrevention.rawValue >= 0) {
                                                _collisionPrevention.rawValue = QGroundControl.unitsConversion.appSettingsHorizontalDistanceUnitsToMeters(value)
                                            }
                                        }
                                    }
                                }

                                QGCLabel {
                                    text: qsTr("Show Obstacle Distance Overlay")
                                    Layout.fillWidth: true
                                }
                                FactCheckBox {
                                    fact: QGroundControl.settingsManager.flyViewSettings.showObstacleDistanceOverlay
                                }
                            }
                        }
                    }

                    Column {
                        width:      parent.width
                        spacing:    _margins

                        QGCLabel {
                            text:       qsTr("Return To Launch")
                            font.bold:  true
                            font.pointSize: ScreenTools.mediumFontPointSize
                        }

                        Rectangle {
                            width:  parent.width
                            height: rtlGrid.height + _margins * 2
                            color:  qgcPal.windowShade
                            radius: ScreenTools.buttonBorderRadius

                            GridLayout {
                                id:             rtlGrid
                                anchors.margins: _margins
                                anchors.left:   parent.left
                                anchors.top:    parent.top
                                width:          parent.width - _margins * 2
                                columns:        2
                                columnSpacing:  _margins
                                rowSpacing:     _margins

                                QGCLabel {
                                    text: qsTr("Climb to Altitude") + " " + rangeString(controller.getParameterFact(-1, "RTL_RETURN_ALT", false))
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               controller.getParameterFact(-1, "RTL_RETURN_ALT")
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("Return Then:")
                                    Layout.columnSpan: 2
                                }

                                QGCRadioButton {
                                    id:                 homeLandRadio
                                    checked:            _rtlLandDelay ? _rtlLandDelay.value === 0 : false
                                    text:               qsTr("Land immediately")
                                    onClicked:          _rtlLandDelay.value = 0
                                    Layout.columnSpan:  2
                                    Layout.leftMargin:  _margins
                                }

                                QGCRadioButton {
                                    id:                 homeLoiterNoLandRadio
                                    checked:            _rtlLandDelay ? _rtlLandDelay.value < 0 : false
                                    text:               qsTr("Loiter and do not land")
                                    onClicked:          _rtlLandDelay.value = -1
                                    Layout.columnSpan:  2
                                    Layout.leftMargin:  _margins
                                }

                                QGCRadioButton {
                                    id:                 homeLoiterLandRadio
                                    checked:            _rtlLandDelay ? _rtlLandDelay.value > 0 : false
                                    text:               qsTr("Loiter and land after specified time")
                                    onClicked:          _rtlLandDelay.value = 60
                                    Layout.columnSpan:  2
                                    Layout.leftMargin:  _margins
                                }

                                QGCLabel {
                                    text: qsTr("Loiter Time") + " " + rangeString(controller.getParameterFact(-1, "RTL_LAND_DELAY", false))
                                    Layout.fillWidth: true
                                    enabled: homeLoiterLandRadio.checked
                                }
                                FactTextField {
                                    fact:               controller.getParameterFact(-1, "RTL_LAND_DELAY")
                                    enabled:            homeLoiterLandRadio.checked
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("Loiter Altitude") + " " + rangeString(controller.getParameterFact(-1, "RTL_DESCEND_ALT", false))
                                    Layout.fillWidth: true
                                    enabled: homeLoiterLandRadio.checked || homeLoiterNoLandRadio.checked
                                }
                                FactTextField {
                                    fact:               controller.getParameterFact(-1, "RTL_DESCEND_ALT")
                                    enabled:            homeLoiterLandRadio.checked || homeLoiterNoLandRadio.checked
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                }
                            }
                        }
                    }

                    Column {
                        width:      parent.width
                        spacing:    _margins

                        QGCLabel {
                            text:       qsTr("Land Mode")
                            font.bold:  true
                            font.pointSize: ScreenTools.mediumFontPointSize
                        }

                        Rectangle {
                            width:  parent.width
                            height: landGrid.height + _margins * 2
                            color:  qgcPal.windowShade
                            radius: ScreenTools.buttonBorderRadius

                            GridLayout {
                                id:             landGrid
                                anchors.margins: _margins
                                anchors.left:   parent.left
                                anchors.top:    parent.top
                                width:          parent.width - _margins * 2
                                columns:        2
                                columnSpacing:  _margins
                                rowSpacing:     _margins

                                QGCLabel {
                                    text: qsTr("Landing Descent Rate") + " " + rangeString(_landSpeedMC)
                                    visible:            controller.vehicle && !controller.vehicle.fixedWing
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _landSpeedMC
                                    visible:            controller.vehicle && !controller.vehicle.fixedWing
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCCheckBox {
                                    id:                 disarmDelayCheckBox
                                    text:               qsTr("Disarm After:")
                                    checked:            _disarmLandDelay.value > 0
                                    onClicked:          _disarmLandDelay.value = checked ? 2 : 0
                                    Layout.fillWidth:   true
                                }
                                FactTextField {
                                    fact:               _disarmLandDelay
                                    enabled:            disarmDelayCheckBox.checked
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                }
                            }
                        }
                    }

                    Column {
                        width:      parent.width
                        spacing:    _margins

                        QGCLabel {
                            text:       qsTr("Telemetry Log")
                            font.bold:  true
                            font.pointSize: ScreenTools.mediumFontPointSize
                        }

                        Rectangle {
                            width:  parent.width
                            height: logGrid.height + _margins * 2
                            color:  qgcPal.windowShade
                            radius: ScreenTools.buttonBorderRadius

                            GridLayout {
                                id:             logGrid
                                anchors.margins: _margins
                                anchors.left:   parent.left
                                anchors.top:    parent.top
                                width:          parent.width - _margins * 2
                                columns:        2
                                columnSpacing:  _margins
                                rowSpacing:     _margins

                                QGCLabel {
                                    text: qsTr("Save Telemetry Log to Vehicle")
                                    Layout.fillWidth: true
                                }
                                QGCSwitch {
                                    checked:            _enableLogging && _enableLogging.value >= 0
                                    onCheckedChanged: {
                                        if (_enableLogging) {
                                            _enableLogging.value = checked ? 0 : -1
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Column {
                        width:      parent.width
                        spacing:    _margins
                        visible:    _hitlAvailable

                        QGCLabel {
                            text:       qsTr("HITL Simulation")
                            font.bold:  true
                            font.pointSize: ScreenTools.mediumFontPointSize
                        }

                        Rectangle {
                            width:  parent.width
                            height: hitlGrid.height + _margins * 2
                            color:  qgcPal.windowShade
                            radius: ScreenTools.buttonBorderRadius

                            GridLayout {
                                id:             hitlGrid
                                anchors.margins: _margins
                                anchors.left:   parent.left
                                anchors.top:    parent.top
                                width:          parent.width - _margins * 2
                                columns:        2
                                columnSpacing:  _margins
                                rowSpacing:     _margins

                                QGCLabel {
                                    text: qsTr("HITL Enabled")
                                    Layout.fillWidth: true
                                }
                                FactComboBox {
                                    fact:               _hitlEnabled
                                    indexModel:         false
                                    Layout.preferredWidth: _fieldWidth
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
