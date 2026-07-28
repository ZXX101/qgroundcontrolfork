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
            x:      ScreenTools.defaultFontPixelWidth * 2
            width:  availableWidth - ScreenTools.defaultFontPixelWidth * 2
            height: Math.max(leftColumn.height, _advancedExpanded ? rightColumn.height : 0)

            FactPanelController { id: controller }

            QGCPalette { id: qgcPal; colorGroupEnabled: true }

            property real _margins:     ScreenTools.defaultFontPixelHeight / 2
            property real _fieldWidth:  ScreenTools.defaultFontPixelWidth * 12

            property Fact _velManual:       controller.getParameterFact(-1, "MPC_VEL_MANUAL")
            property Fact _zVelMaxUp:       controller.getParameterFact(-1, "MPC_Z_VEL_MAX_UP")
            property Fact _zVelMaxDn:       controller.getParameterFact(-1, "MPC_Z_VEL_MAX_DN")
            property Fact _xyCruise:        controller.getParameterFact(-1, "MPC_XY_CRUISE")
            property Fact _zVAutoUp:        controller.getParameterFact(-1, "MPC_Z_V_AUTO_UP")
            property Fact _zVAutoDn:        controller.getParameterFact(-1, "MPC_Z_V_AUTO_DN")

            property Fact _rtlReturnAlt:    controller.getParameterFact(-1, "RTL_RETURN_ALT")
            property Fact _rtlLandDelay:    controller.getParameterFact(-1, "RTL_LAND_DELAY")

            property Fact _rtlDescendAlt:   controller.getParameterFact(-1, "RTL_DESCEND_ALT")
            property Fact _landSpeed:       controller.getParameterFact(-1, "MPC_LAND_SPEED")

            property Fact _tiltMaxAir:      controller.getParameterFact(-1, "MPC_TILTMAX_AIR")
            property Fact _tiltMaxLnd:      controller.getParameterFact(-1, "MPC_TILTMAX_LND")
            property Fact _accUpMax:        controller.getParameterFact(-1, "MPC_ACC_UP_MAX")
            property Fact _accDownMax:      controller.getParameterFact(-1, "MPC_ACC_DOWN_MAX")
            property Fact _accHorMax:       controller.getParameterFact(-1, "MPC_ACC_HOR_MAX")
            property Fact _posMode:         controller.getParameterFact(-1, "MPC_POS_MODE")
            property Fact _pitchrateMax:    controller.getParameterFact(-1, "MC_PITCHRATE_MAX")
            property Fact _rollrateMax:     controller.getParameterFact(-1, "MC_ROLLRATE_MAX")
            property Fact _yawrateMax:      controller.getParameterFact(-1, "MC_YAWRATE_MAX")
            property Fact _accelPMax:       controller.getParameterFact(-1, "MC_ACCEL_P_MAX")
            property Fact _accelRMax:       controller.getParameterFact(-1, "MC_ACCEL_R_MAX")
            property Fact _accelYMax:       controller.getParameterFact(-1, "MC_ACCEL_Y_MAX")

            property bool _advancedExpanded: false

            function formatRangeValue(val) {
                if (val === "" || val === undefined) return ""
                var num = parseFloat(val)
                if (isNaN(num)) return val
                if (num <= 0) return val
                if (num > 9999) return ">" + Math.floor(num * 10) / 10
                return val
            }

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
                var minDisp = formatRangeValue(min)
                var maxDisp = formatRangeValue(max)
                if (minDisp === "" && maxDisp === "") {
                    return ""
                }
                if (minDisp && maxDisp) {
                    return "(" + minDisp + " ~ " + maxDisp + ")"
                }
                if (minDisp) return "(>=" + minDisp + ")"
                if (maxDisp) return "(<= " + maxDisp + ")"
                return ""
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
                            text:       qsTr("Speed")
                            font.bold:  true
                        }

                        Rectangle {
                            width:  parent.width
                            height: speedGrid.height + _margins * 2
                            color:  qgcPal.windowShade
                            radius: ScreenTools.buttonBorderRadius

                            GridLayout {
                                id:             speedGrid
                                anchors.margins: _margins
                                anchors.left:   parent.left
                                anchors.top:    parent.top
                                width:          parent.width - _margins * 2
                                columns:        2
                                columnSpacing:  _margins
                                rowSpacing:     _margins

                                QGCLabel {
                                    text: qsTr("Max Manual Speed") + " " + rangeString(_velManual)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _velManual
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("Max Manual Ascend Speed") + " " + rangeString(_zVelMaxUp)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _zVelMaxUp
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("Max Manual Descend Speed") + " " + rangeString(_zVelMaxDn)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _zVelMaxDn
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("Auto Flight Speed") + " " + rangeString(_xyCruise)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _xyCruise
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("Auto Ascend Speed") + " " + rangeString(_zVAutoUp)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _zVAutoUp
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("Auto Descend Speed") + " " + rangeString(_zVAutoDn)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _zVAutoDn
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
                            text:       qsTr("Return To Home")
                            font.bold:  true
                        }

                        Rectangle {
                            width:  parent.width
                            height: rtlContent.height + _margins * 2
                            color:  qgcPal.windowShade
                            radius: ScreenTools.buttonBorderRadius

                            Column {
                                id:                 rtlContent
                                anchors.margins:    _margins
                                anchors.left:       parent.left
                                anchors.top:        parent.top
                                width:              parent.width - _margins * 2
                                spacing:            _margins

                                RowLayout {
                                    width: parent.width
                                    QGCLabel {
                                        text: qsTr("RTL Altitude") + " " + rangeString(_rtlReturnAlt)
                                        Layout.fillWidth: true
                                    }
                                    FactTextField {
                                        fact:               _rtlReturnAlt
                                        showUnits:          true
                                        Layout.preferredWidth: _fieldWidth
                                    }
                                }

                                QGCLabel {
                                    text:           qsTr("The vehicle will ascend to the set safe altitude then return home")
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color:          qgcPal.text
                                    opacity:        0.6
                                }

                                QGCColoredImage {
                                    width:              parent.width
                                    height:             ScreenTools.defaultFontPixelWidth * 12
                                    color:              qgcPal.text
                                    sourceSize.width:   width
                                    mipmap:             true
                                    fillMode:           Image.PreserveAspectFit
                                    source:             "/qmlimages/ReturnToHomeAltitude.svg"
                                }

                                RowLayout {
                                    width: parent.width
                                    QGCLabel {
                                        text: qsTr("Loiter Time Above Home") + " " + rangeString(_rtlLandDelay)
                                        Layout.fillWidth: true
                                    }
                                    FactTextField {
                                        fact:               _rtlLandDelay
                                        showUnits:          true
                                        Layout.preferredWidth: _fieldWidth
                                    }
                                }
                            }
                        }
                    }

                    Column {
                        width:      parent.width
                        spacing:    _margins

                        QGCLabel {
                            text:       qsTr("Landing")
                            font.bold:  true
                        }

                        Rectangle {
                            width:  parent.width
                            height: landContent.height + _margins * 2
                            color:  qgcPal.windowShade
                            radius: ScreenTools.buttonBorderRadius

                            Column {
                                id:                 landContent
                                anchors.margins:    _margins
                                anchors.left:       parent.left
                                anchors.top:        parent.top
                                width:              parent.width - _margins * 2
                                spacing:            _margins

                                RowLayout {
                                    width: parent.width
                                    QGCLabel {
                                        text: qsTr("Safe Altitude") + " " + rangeString(_rtlDescendAlt)
                                        Layout.fillWidth: true
                                    }
                                    FactTextField {
                                        fact:               _rtlDescendAlt
                                        showUnits:          true
                                        Layout.preferredWidth: _fieldWidth
                                    }
                                }

                                RowLayout {
                                    width: parent.width
                                    QGCLabel {
                                        text: qsTr("Landing Speed") + " " + rangeString(_landSpeed)
                                        Layout.fillWidth: true
                                    }
                                    FactTextField {
                                        fact:               _landSpeed
                                        showUnits:          true
                                        Layout.preferredWidth: _fieldWidth
                                    }
                                }

                                QGCLabel {
                                    text:           qsTr("Effective below safe altitude")
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color:          qgcPal.text
                                    opacity:        0.6
                                }
                            }
                        }
                    }

                    Item {
                        width:  parent.width
                        height: advancedLabelRow.height

                        Row {
                            id:         advancedLabelRow
                            spacing:    _margins / 2

                            QGCLabel {
                                id:         advancedTitle
                                text:       qsTr("Advanced Parameters")
                                font.bold:  true
                            }
                        }

                        MouseArea {
                            anchors.fill:   parent
                            cursorShape:    Qt.PointingHandCursor
                            onClicked:      _advancedExpanded = !_advancedExpanded
                        }
                    }
                }

                Column {
                    id:         rightColumn
                    width:      (parent.width - mainRow.spacing) / 2
                    spacing:    _margins
                    visible:    _advancedExpanded

                    Rectangle {
                        width:  parent.width
                        height: advancedGrid.height + _margins * 2
                        color:  qgcPal.windowShade
                        radius: ScreenTools.buttonBorderRadius

                        GridLayout {
                            id:             advancedGrid
                            anchors.margins: _margins
                            anchors.left:   parent.left
                            anchors.top:    parent.top
                            width:          parent.width - _margins * 2
                            columns:        3
                            columnSpacing:  _margins
                            rowSpacing:     _margins

                            Column {
                                Layout.fillWidth: true
                                QGCLabel { text: qsTr("Max Flight Angle (Air)") }
                                QGCLabel {
                                    text:           "MPC_TILTMAX_AIR"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color:          qgcPal.text
                                    opacity:        0.5
                                }
                            }
                            QGCLabel {
                                text: rangeString(_tiltMaxAir)
                                verticalAlignment: Text.AlignVCenter
                            }
                            FactTextField {
                                fact:               _tiltMaxAir
                                showUnits:          true
                                Layout.preferredWidth: _fieldWidth
                            }

                            Column {
                                Layout.fillWidth: true
                                QGCLabel { text: qsTr("Max Flight Angle (Land)") }
                                QGCLabel {
                                    text:           "MPC_TILTMAX_LND"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color:          qgcPal.text
                                    opacity:        0.5
                                }
                            }
                            QGCLabel {
                                text: rangeString(_tiltMaxLnd)
                                verticalAlignment: Text.AlignVCenter
                            }
                            FactTextField {
                                fact:               _tiltMaxLnd
                                showUnits:          true
                                Layout.preferredWidth: _fieldWidth
                            }

                            Column {
                                Layout.fillWidth: true
                                QGCLabel { text: qsTr("Vertical Accel Up") }
                                QGCLabel {
                                    text:           "MPC_ACC_UP_MAX"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color:          qgcPal.text
                                    opacity:        0.5
                                }
                            }
                            QGCLabel {
                                text: rangeString(_accUpMax)
                                verticalAlignment: Text.AlignVCenter
                            }
                            FactTextField {
                                fact:               _accUpMax
                                showUnits:          true
                                Layout.preferredWidth: _fieldWidth
                            }

                            Column {
                                Layout.fillWidth: true
                                QGCLabel { text: qsTr("Vertical Accel Down") }
                                QGCLabel {
                                    text:           "MPC_ACC_DOWN_MAX"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color:          qgcPal.text
                                    opacity:        0.5
                                }
                            }
                            QGCLabel {
                                text: rangeString(_accDownMax)
                                verticalAlignment: Text.AlignVCenter
                            }
                            FactTextField {
                                fact:               _accDownMax
                                showUnits:          true
                                Layout.preferredWidth: _fieldWidth
                            }

                            Column {
                                Layout.fillWidth: true
                                QGCLabel { text: qsTr("Max Flight Acceleration") }
                                QGCLabel {
                                    text:           "MPC_ACC_HOR_MAX"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color:          qgcPal.text
                                    opacity:        0.5
                                }
                            }
                            QGCLabel {
                                text: rangeString(_accHorMax)
                                verticalAlignment: Text.AlignVCenter
                            }
                            FactTextField {
                                fact:               _accHorMax
                                showUnits:          true
                                Layout.preferredWidth: _fieldWidth
                            }

                            Column {
                                Layout.fillWidth: true
                                QGCLabel { text: qsTr("Position Control Mode") }
                                QGCLabel {
                                    text:           "MPC_POS_MODE"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color:          qgcPal.text
                                    opacity:        0.5
                                }
                            }
                            QGCLabel {
                                text: ""
                                verticalAlignment: Text.AlignVCenter
                            }
                            FactComboBox {
                                fact:               _posMode
                                indexModel:         false
                                Layout.preferredWidth: _fieldWidth
                            }

                            Column {
                                Layout.fillWidth: true
                                QGCLabel { text: qsTr("Max Angular Rate P") }
                                QGCLabel {
                                    text:           "MC_PITCHRATE_MAX"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color:          qgcPal.text
                                    opacity:        0.5
                                }
                            }
                            QGCLabel {
                                text: rangeString(_pitchrateMax)
                                verticalAlignment: Text.AlignVCenter
                            }
                            FactTextField {
                                fact:               _pitchrateMax
                                showUnits:          true
                                Layout.preferredWidth: _fieldWidth
                            }

                            Column {
                                Layout.fillWidth: true
                                QGCLabel { text: qsTr("Max Angular Rate R") }
                                QGCLabel {
                                    text:           "MC_ROLLRATE_MAX"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color:          qgcPal.text
                                    opacity:        0.5
                                }
                            }
                            QGCLabel {
                                text: rangeString(_rollrateMax)
                                verticalAlignment: Text.AlignVCenter
                            }
                            FactTextField {
                                fact:               _rollrateMax
                                showUnits:          true
                                Layout.preferredWidth: _fieldWidth
                            }

                            Column {
                                Layout.fillWidth: true
                                QGCLabel { text: qsTr("Max Angular Rate Y") }
                                QGCLabel {
                                    text:           "MC_YAWRATE_MAX"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color:          qgcPal.text
                                    opacity:        0.5
                                }
                            }
                            QGCLabel {
                                text: rangeString(_yawrateMax)
                                verticalAlignment: Text.AlignVCenter
                            }
                            FactTextField {
                                fact:               _yawrateMax
                                showUnits:          true
                                Layout.preferredWidth: _fieldWidth
                            }

                            Column {
                                Layout.fillWidth: true
                                QGCLabel { text: qsTr("Max Angular Accel P") }
                                QGCLabel {
                                    text:           "MC_ACCEL_P_MAX"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color:          qgcPal.text
                                    opacity:        0.5
                                }
                            }
                            QGCLabel {
                                text: rangeString(_accelPMax)
                                verticalAlignment: Text.AlignVCenter
                            }
                            FactTextField {
                                fact:               _accelPMax
                                showUnits:          true
                                Layout.preferredWidth: _fieldWidth
                            }

                            Column {
                                Layout.fillWidth: true
                                QGCLabel { text: qsTr("Max Angular Accel R") }
                                QGCLabel {
                                    text:           "MC_ACCEL_R_MAX"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color:          qgcPal.text
                                    opacity:        0.5
                                }
                            }
                            QGCLabel {
                                text: rangeString(_accelRMax)
                                verticalAlignment: Text.AlignVCenter
                            }
                            FactTextField {
                                fact:               _accelRMax
                                showUnits:          true
                                Layout.preferredWidth: _fieldWidth
                            }

                            Column {
                                Layout.fillWidth: true
                                QGCLabel { text: qsTr("Max Angular Accel Y") }
                                QGCLabel {
                                    text:           "MC_ACCEL_Y_MAX"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color:          qgcPal.text
                                    opacity:        0.5
                                }
                            }
                            QGCLabel {
                                text: rangeString(_accelYMax)
                                verticalAlignment: Text.AlignVCenter
                            }
                            FactTextField {
                                fact:               _accelYMax
                                showUnits:          true
                                Layout.preferredWidth: _fieldWidth
                            }
                        }
                    }
                }
            }
        }
    }
}
