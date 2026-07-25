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
import QGroundControl.Controllers
import QGroundControl.ScreenTools

SetupPage {
    id:             flightModePage
    pageComponent:  flightModePageComponent
    pageName:       ""
    pageDescription: ""

    readonly property var    _pwmStrings:       [ "PWM 0 - 1230", "PWM 1231 - 1360", "PWM 1361 - 1490", "PWM 1491 - 1620", "PWM 1621 - 1749", "PWM 1750 +"]

    property real   _margins:                   ScreenTools.defaultFontPixelHeight
    property Fact   _nullFact: Fact { }
    property bool   _rcMapFltmodeExists:         controller.parameterExists(-1, "RC_MAP_FLTMODE")
    property Fact   _rcMapFltmode:               _rcMapFltmodeExists ? controller.getParameterFact(-1, "RC_MAP_FLTMODE") : _nullFact

    property var    _switchNameList:  [ "RC_MAP_ARM_SW", "RC_MAP_GEAR_SW", "RC_MAP_KILL_SW", "RC_MAP_LOITER_SW", "RC_MAP_OFFB_SW", "RC_MAP_RETURN_SW" ]
    property var    _switchLabelList: [ qsTr("Arm Switch"), qsTr("Gear Switch"), qsTr("Kill Switch"), qsTr("Loiter Switch"), qsTr("Offboard Switch"), qsTr("Return Switch") ]

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    PX4SimpleFlightModesController {
        id:         controller
    }

    Component {
        id: flightModePageComponent

        ColumnLayout {
            x:      ScreenTools.defaultFontPixelWidth * 2
            width:  availableWidth - ScreenTools.defaultFontPixelWidth * 2
            spacing:    _margins

            FactPanelController { id: auxController }

            QGCLabel {
                text:           qsTr("Flight Mode Settings")
                font.bold:      true
            }

            Rectangle {
                Layout.fillWidth: true
                height: flightModeColumn.height + ScreenTools.defaultFontPixelHeight
                color:  qgcPal.windowShade

                Column {
                    id:                 flightModeColumn
                    anchors.margins:    ScreenTools.defaultFontPixelWidth
                    anchors.left:       parent.left
                    anchors.top:        parent.top
                    spacing:            ScreenTools.defaultFontPixelHeight

                    Row {
                        spacing:    _margins
                        visible:    _rcMapFltmodeExists

                        QGCLabel {
                            id:                 modeChannelLabel
                            anchors.baseline:   modeChannelCombo.baseline
                            text:               qsTr("Flight mode channel:")
                        }

                        FactComboBox {
                            id:             modeChannelCombo
                            width:          ScreenTools.defaultFontPixelWidth * 15
                            fact:           _rcMapFltmode
                            indexModel:     false
                        }
                    }

                    GridLayout {
                        columns:        2
                        flow:           GridLayout.LeftToRight
                        rowSpacing:     ScreenTools.defaultFontPixelHeight
                        columnSpacing:  ScreenTools.defaultFontPixelWidth * 4

                        Repeater {
                            model: 6

                            Row {
                                Layout.fillWidth: true
                                spacing: ScreenTools.defaultFontPixelWidth

                                QGCLabel {
                                    anchors.baseline:   fmCombo.baseline
                                    text:               qsTr("Flight Mode %1 (%2)").arg(modelData + 1).arg(_pwmStrings[modelData])
                                    color:              controller.activeFlightMode == (modelData + 1) ? "yellow" : qgcPal.text
                                }

                                FactComboBox {
                                    id:     fmCombo
                                    width:  ScreenTools.defaultFontPixelWidth * 15
                                    fact:   controller.getParameterFact(-1, "COM_FLTMODE" + (modelData + 1))
                                    indexModel: false
                                }
                            }
                        }
                    }
                }
            }

            QGCLabel {
                text:           qsTr("Switch Options")
                font.bold:      true
            }

            Rectangle {
                Layout.fillWidth: true
                height: channelOptColumn.height + ScreenTools.defaultFontPixelHeight
                color:  qgcPal.windowShade

                Column {
                    id:                 channelOptColumn
                    anchors.margins:    ScreenTools.defaultFontPixelWidth
                    anchors.left:       parent.left
                    anchors.top:        parent.top
                    spacing:            ScreenTools.defaultFontPixelHeight

                    GridLayout {
                        columns:        2
                        flow:           GridLayout.LeftToRight
                        rowSpacing:     ScreenTools.defaultFontPixelHeight
                        columnSpacing:  ScreenTools.defaultFontPixelWidth * 4

                        Repeater {
                            model: _switchNameList.length

                            Row {
                                Layout.fillWidth: true
                                spacing: ScreenTools.defaultFontPixelWidth

                                property string switchParam:  _switchNameList[index]
                                property bool   switchExists: controller.parameterExists(-1, switchParam)
                                property Fact   switchFact:   switchExists ? controller.getParameterFact(-1, switchParam) : _nullFact

                                QGCLabel {
                                    anchors.baseline:   optCombo.baseline
                                    text:               _switchLabelList[index] + ":"
                                    color:              switchFact.rawValue > 0 ? "yellow" : qgcPal.text
                                    visible:            parent.switchExists
                                }

                                FactComboBox {
                                    id:         optCombo
                                    width:      ScreenTools.defaultFontPixelWidth * 15
                                    fact:       parent.switchFact
                                    indexModel: false
                                    visible:    parent.switchExists
                                }
                            }
                        }
                    }
                }
            }

            QGCLabel {
                text:           qsTr("Actuator Output Functions")
                font.bold:      true
            }

            Rectangle {
                Layout.fillWidth: true
                height: auxColumn.height + ScreenTools.defaultFontPixelHeight
                color:  qgcPal.windowShade

                Column {
                    id:                 auxColumn
                    anchors.margins:    ScreenTools.defaultFontPixelWidth
                    anchors.left:       parent.left
                    anchors.top:        parent.top
                    spacing:            ScreenTools.defaultFontPixelHeight

                    GridLayout {
                        columns:        2
                        flow:           GridLayout.LeftToRight
                        rowSpacing:     ScreenTools.defaultFontPixelHeight
                        columnSpacing:  ScreenTools.defaultFontPixelWidth * 4

                        Repeater {
                            model: 8

                            Row {
                                Layout.fillWidth: true
                                spacing: ScreenTools.defaultFontPixelWidth

                                property Fact _auxNullFact: Fact { }
                                property string _paramName: "PWM_MAIN_FUNC" + (modelData + 1)
                                property bool _auxExists: auxController.parameterExists(-1, _paramName)

                                QGCLabel {
                                    anchors.baseline:   auxCombo.baseline
                                    text:               qsTr("Main %1").arg(modelData + 1)
                                    visible:            parent._auxExists
                                }

                                FactComboBox {
                                    id:         auxCombo
                                    width:      ScreenTools.defaultFontPixelWidth * 20
                                    fact:       parent._auxExists
                                                ? auxController.getParameterFact(-1, parent._paramName)
                                                : parent._auxNullFact
                                    indexModel: false
                                    visible:    parent._auxExists
                                }
                            }
                        }

                        Repeater {
                            model: 11

                            Row {
                                Layout.fillWidth: true
                                spacing: ScreenTools.defaultFontPixelWidth

                                property Fact _auxNullFact: Fact { }
                                property string _paramName: "PWM_AUX_FUNC" + (modelData + 1)
                                property bool _auxExists: auxController.parameterExists(-1, _paramName)

                                QGCLabel {
                                    anchors.baseline:   auxCombo2.baseline
                                    text:               qsTr("Aux %1").arg(modelData + 1)
                                    visible:            parent._auxExists
                                }

                                FactComboBox {
                                    id:         auxCombo2
                                    width:      ScreenTools.defaultFontPixelWidth * 20
                                    fact:       parent._auxExists
                                                ? auxController.getParameterFact(-1, parent._paramName)
                                                : parent._auxNullFact
                                    indexModel: false
                                    visible:    parent._auxExists
                                }
                            }
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    Component.onCompleted: {
        if (controller.vehicle.vtol) {
            _switchNameList.push("RC_MAP_TRANS_SW")
            _switchLabelList.push(qsTr("Transition Switch"))
        }
        if (controller.vehicle.fixedWing) {
            _switchNameList.push("RC_MAP_FLAPS")
            _switchLabelList.push(qsTr("Flaps"))
        }
    }
}
