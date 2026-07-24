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

            property Fact _battLowVoltage:      controller.getParameterFact(-1, "BATT_LOW_VOLT", false)
            property Fact _battFsLowAct:        controller.getParameterFact(-1, "BATT_FS_LOW_ACT", false)
            property Fact _fsThrEnable:         controller.getParameterFact(-1, "FS_THR_ENABLE", false)
            property Fact _fsThrValue:          controller.getParameterFact(-1, "FS_THR_VALUE", false)
            property Fact _fsGcsEnable:         controller.getParameterFact(-1, "FS_GCS_ENABLE", false)
            property Fact _fsGcsTimeout:        controller.getParameterFact(-1, "FS_GCS_TIMEOUT", false)
            property Fact _fenceAction:         controller.getParameterFact(-1, "FENCE_ACTION", false)
            property Fact _fenceAltMax:         controller.getParameterFact(-1, "FENCE_ALT_MAX", false)
            property Fact _fenceRadius:         controller.getParameterFact(-1, "FENCE_RADIUS", false)
            property Fact _avoidEnable:         controller.getParameterFact(-1, "AVOID_ENABLE", false)
            property Fact _avoidDistMax:        controller.getParameterFact(-1, "AVOID_DIST_MAX", false)
            property Fact _proxType:            controller.getParameterFact(-1, "PRX1_TYPE", false)
            property Fact _logBackendType:      controller.getParameterFact(-1, "LOG_BACKEND_TYPE", false)

            property bool _avoidParamsAvailable:    controller.parameterExists(-1, "AVOID_ENABLE")
            property bool _logParamsAvailable:      controller.parameterExists(-1, "LOG_BACKEND_TYPE")

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
                width:      parent.width / 2
                anchors.horizontalCenter: parent.horizontalCenter

                Column {
                    id:         leftColumn
                    width:      parent.width
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
                                    text: qsTr("Failsafe Trigger Voltage") + " " + rangeString(_battLowVoltage)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _battLowVoltage
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                    Layout.alignment:   Qt.AlignRight
                                }

                                QGCLabel {
                                    text: qsTr("Failsafe Action")
                                    Layout.fillWidth: true
                                }
                                FactComboBox {
                                    fact:               _battFsLowAct
                                    indexModel:         false
                                    sizeToContents:     true
                                    Layout.preferredWidth: Math.max(_fieldWidth, implicitWidth)
                                    Layout.alignment:   Qt.AlignRight
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
                                    text: qsTr("PWM Minimum") + " " + rangeString(_fsThrValue)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _fsThrValue
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                    Layout.alignment:   Qt.AlignRight
                                }

                                QGCLabel {
                                    text: qsTr("Failsafe Action")
                                    Layout.fillWidth: true
                                }
                                FactComboBox {
                                    fact:               _fsThrEnable
                                    indexModel:         false
                                    sizeToContents:     true
                                    Layout.preferredWidth: Math.max(_fieldWidth, implicitWidth)
                                    Layout.alignment:   Qt.AlignRight
                                }
                            }
                        }
                    }

                    Column {
                        width:      parent.width
                        spacing:    _margins

                        QGCLabel {
                            text:       qsTr("GCS Link Loss Failsafe")
                            font.bold:  true
                            font.pointSize: ScreenTools.mediumFontPointSize
                        }

                        Rectangle {
                            width:  parent.width
                            height: gcsGrid.height + _margins * 2
                            color:  qgcPal.windowShade
                            radius: ScreenTools.buttonBorderRadius

                            GridLayout {
                                id:             gcsGrid
                                anchors.margins: _margins
                                anchors.left:   parent.left
                                anchors.top:    parent.top
                                width:          parent.width - _margins * 2
                                columns:        2
                                columnSpacing:  _margins
                                rowSpacing:     _margins

                                QGCLabel {
                                    text: qsTr("Connection Timeout") + " " + rangeString(_fsGcsTimeout)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _fsGcsTimeout
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                    Layout.alignment:   Qt.AlignRight
                                }

                                QGCLabel {
                                    text: qsTr("Failsafe Action")
                                    Layout.fillWidth: true
                                }
                                FactComboBox {
                                    fact:               _fsGcsEnable
                                    indexModel:         false
                                    sizeToContents:     true
                                    Layout.preferredWidth: Math.max(_fieldWidth, implicitWidth)
                                    Layout.alignment:   Qt.AlignRight
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
                                    Layout.alignment:   Qt.AlignRight
                                }

                                QGCLabel {
                                    text: qsTr("Max Altitude") + " " + rangeString(_fenceAltMax)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _fenceAltMax
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                    Layout.alignment:   Qt.AlignRight
                                }

                                QGCLabel {
                                    text: qsTr("Max Radius") + " " + rangeString(_fenceRadius)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _fenceRadius
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                    Layout.alignment:   Qt.AlignRight
                                }
                            }
                        }
                    }

                    Column {
                        width:      parent.width
                        spacing:    _margins
                        visible:    _avoidParamsAvailable

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
                                    text: qsTr("Avoidance Action")
                                    Layout.fillWidth: true
                                }
                                FactComboBox {
                                    fact:               _avoidEnable
                                    indexModel:         false
                                    Layout.preferredWidth: _fieldWidth
                                    Layout.alignment:   Qt.AlignRight
                                }

                                QGCLabel {
                                    text: qsTr("Minimum Distance") + " " + rangeString(_avoidDistMax)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _avoidDistMax
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                    Layout.alignment:   Qt.AlignRight
                                }

                                QGCLabel {
                                    text: qsTr("Show Obstacle Distance Overlay")
                                    Layout.fillWidth: true
                                }
                                QGCSwitch {
                                    Layout.alignment:   Qt.AlignRight
                                    checked:            _proxType && _proxType.rawValue !== 0
                                    onCheckedChanged: {
                                        if (_proxType) {
                                            _proxType.value = checked ? 1 : 0
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Column {
                        width:      parent.width
                        spacing:    _margins
                        visible:    _logParamsAvailable

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
                                    Layout.alignment:   Qt.AlignRight
                                    checked:            _logBackendType && (_logBackendType.rawValue & 2)
                                    onCheckedChanged: {
                                        if (_logBackendType) {
                                            if (checked) {
                                                _logBackendType.rawValue |= 2
                                            } else {
                                                _logBackendType.rawValue &= ~2
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Column {
                    id:         rightColumn
                    width:      0
                    spacing:    _margins * 2
                    visible:    false
                }
            }
        }
    }
}
