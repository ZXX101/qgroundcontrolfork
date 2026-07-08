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
                width:      parent.width

                Column {
                    id:         leftColumn
                    width:      (parent.width - mainRow.spacing) / 2
                    spacing:    _margins * 2

                    Column {
                        width:      parent.width
                        spacing:    _margins

                        QGCLabel {
                            text:       qsTr("低电量故障保护")
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
                                    text: qsTr("保护触发电压") + " " + rangeString(_battLowVoltage)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _battLowVoltage
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("保护动作")
                                    Layout.fillWidth: true
                                }
                                FactComboBox {
                                    fact:               _battFsLowAct
                                    indexModel:         false
                                    Layout.preferredWidth: _fieldWidth
                                }
                            }
                        }
                    }

                    Column {
                        width:      parent.width
                        spacing:    _margins

                        QGCLabel {
                            text:       qsTr("遥控器失控保护")
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
                                    text: qsTr("PWM最低值") + " " + rangeString(_fsThrValue)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _fsThrValue
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("保护动作")
                                    Layout.fillWidth: true
                                }
                                FactComboBox {
                                    fact:               _fsThrEnable
                                    indexModel:         false
                                    Layout.preferredWidth: _fieldWidth
                                }
                            }
                        }
                    }

                    Column {
                        width:      parent.width
                        spacing:    _margins

                        QGCLabel {
                            text:       qsTr("软件断联保护")
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
                                    text: qsTr("连接超时") + " " + rangeString(_fsGcsTimeout)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _fsGcsTimeout
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("保护动作")
                                    Layout.fillWidth: true
                                }
                                FactComboBox {
                                    fact:               _fsGcsEnable
                                    indexModel:         false
                                    Layout.preferredWidth: _fieldWidth
                                }
                            }
                        }
                    }

                    Column {
                        width:      parent.width
                        spacing:    _margins

                        QGCLabel {
                            text:       qsTr("电子围栏")
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
                                    text: qsTr("冲出围栏时动作")
                                    Layout.fillWidth: true
                                }
                                FactComboBox {
                                    fact:               _fenceAction
                                    indexModel:         false
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("最大高度") + " " + rangeString(_fenceAltMax)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _fenceAltMax
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("最大半径") + " " + rangeString(_fenceRadius)
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

                    Column {
                        width:      parent.width
                        spacing:    _margins
                        visible:    _avoidParamsAvailable

                        QGCLabel {
                            text:       qsTr("物体探测")
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
                                    text: qsTr("避障动作")
                                    Layout.fillWidth: true
                                }
                                FactComboBox {
                                    fact:               _avoidEnable
                                    indexModel:         false
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("最小距离") + " " + rangeString(_avoidDistMax)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _avoidDistMax
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("显示障碍物距离叠加层")
                                    Layout.fillWidth: true
                                }
                                QGCSwitch {
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
                            text:       qsTr("无线数传日志")
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
                                    text: qsTr("储存数传日志到飞机里")
                                    Layout.fillWidth: true
                                }
                                QGCSwitch {
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
                    width:      (parent.width - mainRow.spacing) / 2
                    spacing:    _margins * 2
                }
            }
        }
    }
}
