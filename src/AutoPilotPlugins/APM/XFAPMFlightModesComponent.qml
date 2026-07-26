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

    readonly property string _modeChannelParam: controller.modeChannelParam
    readonly property string _modeParamPrefix:  controller.modeParamPrefix
    readonly property var    _pwmStrings:       [ "PWM 0 - 1230", "PWM 1231 - 1360", "PWM 1361 - 1490", "PWM 1491 - 1620", "PWM 1621 - 1749", "PWM 1750 +"]

    property real   _margins:                   ScreenTools.defaultFontPixelHeight
    readonly property real _minimumColumnWidth: ScreenTools.defaultFontPixelWidth * 50
    property Fact   _nullFact: Fact { }
    property bool   _fltmodeChExists:           controller.parameterExists(-1, _modeChannelParam)
    property Fact   _fltmodeCh:                 _fltmodeChExists ? controller.getParameterFact(-1, _modeChannelParam) : _nullFact
    property bool   _ch7OptAvailable:           controller.parameterExists(-1, "CH7_OPT")
    property int    _rcOptionStart:             _ch7OptAvailable ? 7 : 6
    property int    _rcOptionStop:              _ch7OptAvailable ? 12 : 16
    property bool   _customSimpleMode:          controller.simpleMode === APMFlightModesComponentController.SimpleModeCustom

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    APMFlightModesComponentController {
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
                text:           qsTr("Flight Mode Settings") + (_fltmodeChExists ? "" : qsTr(" (Channel 5)"))
                font.bold:      true
            }

            Rectangle {
                Layout.fillWidth: true
                height: flightModeColumn.height + ScreenTools.defaultFontPixelHeight
                color:  qgcPal.windowShade

                Column {
                    id:                 flightModeColumn
                    anchors.left:       parent.left
                    anchors.top:        parent.top
                    anchors.right:      parent.right
                    anchors.leftMargin: ScreenTools.defaultFontPixelWidth
                    anchors.topMargin:  ScreenTools.defaultFontPixelWidth
                    anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 3
                    anchors.bottomMargin: ScreenTools.defaultFontPixelWidth
                    spacing:            ScreenTools.defaultFontPixelHeight

                    RowLayout {
                        Layout.fillWidth: true
                        spacing:    _margins
                        visible:    _fltmodeChExists

                        QGCLabel {
                            id:                 modeChannelLabel
                            text:               qsTr("Flight mode channel:")
                        }

                        QGCComboBox {
                            id:             modeChannelCombo
                            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 15
                            model:          [ qsTr("Not assigned"), qsTr("Channel 1"), qsTr("Channel 2"),
                                qsTr("Channel 3"),    qsTr("Channel 4"), qsTr("Channel 5"),
                                qsTr("Channel 6"),    qsTr("Channel 7"), qsTr("Channel 8") ]

                            currentIndex:   _fltmodeCh.value
                            onActivated: (index) => { _fltmodeCh.value = index }
                        }

                        Item { width: _margins; visible: controller.simpleModesSupported }

                        QGCLabel {
                            text: qsTr("Simple Mode")
                            visible: controller.simpleModesSupported
                        }

                        QGCComboBox {
                            visible: controller.simpleModesSupported
                            model:          controller.simpleModeNames
                            sizeToContents: true
                            currentIndex:   controller.simpleMode
                            onActivated: (index) => { controller.simpleMode = index }
                        }
                    }

                    GridLayout {
                        id:             flightModeGrid
                        width:          parent.width
                        columns:        Math.min(2, Math.max(1, Math.floor(width / _minimumColumnWidth)))
                        flow:           GridLayout.LeftToRight
                        rowSpacing:     ScreenTools.defaultFontPixelHeight
                        columnSpacing:  ScreenTools.defaultFontPixelWidth * 4

                        Repeater {
                            model: 6

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: ScreenTools.defaultFontPixelWidth

                                QGCLabel {
                                    text:               qsTr("Flight Mode %1 (%2)").arg(modelData + 1).arg(_pwmStrings[modelData])
                                    color:              controller.activeFlightMode == (modelData + 1) ? "yellow" : qgcPal.text
                                    Layout.fillWidth:   true
                                }

                                FactComboBox {
                                    id:     fmCombo
                                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 15
                                    Layout.alignment: Qt.AlignRight
                                    fact:   controller.getParameterFact(-1, _modeParamPrefix + (modelData + 1))
                                    indexModel: false
                                    sizeToContents: true
                                }
                            }
                        }

                        GridLayout {
                            visible:        _customSimpleMode
                            Layout.columnSpan: flightModeGrid.columns
                            Layout.fillWidth: true
                            columns:        2
                            flow:           GridLayout.LeftToRight
                            rowSpacing:     ScreenTools.defaultFontPixelHeight
                            columnSpacing:  ScreenTools.defaultFontPixelWidth * 4

                            QGCLabel {
                                text:           qsTr("Simple")
                                font.pointSize: ScreenTools.smallFontPointSize
                            }
                            QGCLabel {
                                font.pointSize: ScreenTools.smallFontPointSize
                            }

                            Repeater {
                                model: 3
                                Row {
                                    spacing: ScreenTools.defaultFontPixelWidth
                                    QGCCheckBox {
                                        checked:    controller.simpleModeEnabled[modelData]
                                        onClicked:  controller.setSimpleMode(modelData, checked)
                                    }
                                    QGCLabel { text: qsTr("FM%1").arg(modelData + 1); font.pointSize: ScreenTools.smallFontPointSize }
                                    Item { width: ScreenTools.defaultFontPixelWidth * 2 }
                                    QGCCheckBox {
                                        checked:    controller.simpleModeEnabled[modelData + 3]
                                        onClicked:  controller.setSimpleMode(modelData + 3, checked)
                                    }
                                    QGCLabel { text: qsTr("FM%1").arg(modelData + 4); font.pointSize: ScreenTools.smallFontPointSize }
                                }
                            }

                            QGCLabel {
                                text:           qsTr("Super-Simple")
                                font.pointSize: ScreenTools.smallFontPointSize
                            }
                            QGCLabel {
                                font.pointSize: ScreenTools.smallFontPointSize
                            }

                            Repeater {
                                model: 3
                                Row {
                                    spacing: ScreenTools.defaultFontPixelWidth
                                    QGCCheckBox {
                                        checked:    controller.superSimpleModeEnabled[modelData]
                                        onClicked:  controller.setSuperSimpleMode(modelData, checked)
                                    }
                                    QGCLabel { text: qsTr("FM%1").arg(modelData + 1); font.pointSize: ScreenTools.smallFontPointSize }
                                    Item { width: ScreenTools.defaultFontPixelWidth * 2 }
                                    QGCCheckBox {
                                        checked:    controller.superSimpleModeEnabled[modelData + 3]
                                        onClicked:  controller.setSuperSimpleMode(modelData + 3, checked)
                                    }
                                    QGCLabel { text: qsTr("FM%1").arg(modelData + 4); font.pointSize: ScreenTools.smallFontPointSize }
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
                    anchors.left:       parent.left
                    anchors.top:        parent.top
                    anchors.right:      parent.right
                    anchors.leftMargin: ScreenTools.defaultFontPixelWidth
                    anchors.topMargin:  ScreenTools.defaultFontPixelWidth
                    anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 3
                    anchors.bottomMargin: ScreenTools.defaultFontPixelWidth
                    spacing:            ScreenTools.defaultFontPixelHeight

                    GridLayout {
                        id:             channelOptionsGrid
                        width:          parent.width
                        columns:        Math.min(2, Math.max(1, Math.floor(width / _minimumColumnWidth)))
                        flow:           GridLayout.LeftToRight
                        rowSpacing:     ScreenTools.defaultFontPixelHeight
                        columnSpacing:  ScreenTools.defaultFontPixelWidth * 4

                        Repeater {
                            model: _rcOptionStop - _rcOptionStart + 1

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: ScreenTools.defaultFontPixelWidth

                                property int index: modelData + _rcOptionStart

                                QGCLabel {
                                    text:               qsTr("Channel option %1 :").arg(index)
                                    color:              controller.channelOptionEnabled[modelData + (_ch7OptAvailable ? 1 : 0)] ? "yellow" : qgcPal.text
                                    Layout.fillWidth:   true
                                }

                                FactComboBox {
                                    id:         optCombo
                                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 15
                                    Layout.alignment: Qt.AlignRight
                                    fact:       controller.getParameterFact(-1, "r.RC" + index + "_OPTION")
                                    indexModel: false
                                    sizeToContents: true
                                }
                            }
                        }
                    }
                }
            }

            QGCLabel {
                text:           qsTr("Auxiliary Output Channels")
                font.bold:  true
            }

            Rectangle {
                Layout.fillWidth: true
                height: auxColumn.height + ScreenTools.defaultFontPixelHeight
                color:  qgcPal.windowShade

                Column {
                    id:                 auxColumn
                    anchors.left:       parent.left
                    anchors.top:        parent.top
                    anchors.right:      parent.right
                    anchors.leftMargin: ScreenTools.defaultFontPixelWidth
                    anchors.topMargin:  ScreenTools.defaultFontPixelWidth
                    anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 3
                    anchors.bottomMargin: ScreenTools.defaultFontPixelWidth
                    spacing:            ScreenTools.defaultFontPixelHeight

                    GridLayout {
                        id:             auxOutputGrid
                        width:          parent.width
                        columns:        Math.min(2, Math.max(1, Math.floor(width / _minimumColumnWidth)))
                        flow:           GridLayout.LeftToRight
                        rowSpacing:     ScreenTools.defaultFontPixelHeight
                        columnSpacing:  ScreenTools.defaultFontPixelWidth * 4

                        Repeater {
                            model: 16

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: ScreenTools.defaultFontPixelWidth

                                property Fact _auxNullFact: Fact { }
                                property bool _auxExists: auxController.parameterExists(-1, "SERVO" + (modelData + 1) + "_FUNCTION")

                                QGCLabel {
                                    text:               qsTr("Auxiliary %1 (AUX%1)").arg(modelData + 1)
                                    visible:            parent._auxExists
                                    Layout.fillWidth:   true
                                }

                                FactComboBox {
                                    id:         auxCombo
                                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 20
                                    Layout.alignment: Qt.AlignRight
                                    fact:       parent._auxExists
                                                ? auxController.getParameterFact(-1, "SERVO" + (modelData + 1) + "_FUNCTION")
                                                : parent._auxNullFact
                                    indexModel: false
                                    sizeToContents: true
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
}
