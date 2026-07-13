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
            height: Math.max(leftColumn.height, _advancedExpanded ? rightColumn.height : 0)

            FactPanelController { id: controller }

            QGCPalette { id: qgcPal; colorGroupEnabled: true }

            property real _margins:     ScreenTools.defaultFontPixelHeight / 2
            property real _fieldWidth:  ScreenTools.defaultFontPixelWidth * 12

            property Fact _angleMax:        controller.getParameterFact(-1, "ANGLE_MAX")
            property Fact _pilotSpeedUp:    controller.getParameterFact(-1, "PILOT_SPEED_UP")
            property Fact _pilotSpeedDn:    controller.getParameterFact(-1, "PILOT_SPEED_DN")
            property Fact _wpnavSpeed:      controller.getParameterFact(-1, "WPNAV_SPEED")
            property Fact _wpnavSpeedUp:    controller.getParameterFact(-1, "WPNAV_SPEED_UP")
            property Fact _wpnavSpeedDn:    controller.getParameterFact(-1, "WPNAV_SPEED_DN")

            property Fact _rtlAlt:          controller.getParameterFact(-1, "RTL_ALT")
            property Fact _rtlLoitTime:     controller.getParameterFact(-1, "RTL_LOIT_TIME")

            property Fact _rtlAltFinal:     controller.getParameterFact(-1, "RTL_ALT_FINAL")
            property Fact _landSpeed:       controller.getParameterFact(-1, "LAND_SPEED")

            property Fact _pilotAccelZ:     controller.getParameterFact(-1, "PILOT_ACCEL_Z")
            property Fact _loitAccMax:      controller.getParameterFact(-1, "LOIT_ACC_MAX")
            property Fact _atcInputTc:      controller.getParameterFact(-1, "ATC_INPUT_TC")
            property Fact _atcRatePMax:     controller.getParameterFact(-1, "ATC_RATE_P_MAX")
            property Fact _atcRateRMax:     controller.getParameterFact(-1, "ATC_RATE_R_MAX")
            property Fact _atcRateYMax:     controller.getParameterFact(-1, "ATC_RATE_Y_MAX")
            property Fact _atcAccelPMax:    controller.getParameterFact(-1, "ATC_ACCEL_P_MAX")
            property Fact _atcAccelRMax:    controller.getParameterFact(-1, "ATC_ACCEL_R_MAX")
            property Fact _atcAccelYMax:    controller.getParameterFact(-1, "ATC_ACCEL_Y_MAX")

            property bool _advancedExpanded: false

            function rangeString(fact) {
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
                            text:       qsTr("速度")
                            font.bold:  true
                            font.pointSize: ScreenTools.mediumFontPointSize
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
                                    text: qsTr("手动控制最大倾角") + " " + rangeString(_angleMax)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _angleMax
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("手动上升最大速度") + " " + rangeString(_pilotSpeedUp)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _pilotSpeedUp
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("手动下降最大速度") + " " + rangeString(_pilotSpeedDn)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _pilotSpeedDn
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("自动飞行速度") + " " + rangeString(_wpnavSpeed)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _wpnavSpeed
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("自动上升速度") + " " + rangeString(_wpnavSpeedUp)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _wpnavSpeedUp
                                    showUnits:          true
                                    Layout.preferredWidth: _fieldWidth
                                }

                                QGCLabel {
                                    text: qsTr("自动下降速度") + " " + rangeString(_wpnavSpeedDn)
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact:               _wpnavSpeedDn
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
                            text:       qsTr("返航参数")
                            font.bold:  true
                            font.pointSize: ScreenTools.mediumFontPointSize
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
                                        text: qsTr("返航高度") + " " + rangeString(_rtlAlt)
                                        Layout.fillWidth: true
                                    }
                                    FactTextField {
                                        fact:               _rtlAlt
                                        showUnits:          true
                                        Layout.preferredWidth: _fieldWidth
                                    }
                                }

                                QGCLabel {
                                    text:           qsTr("无人机将上升到设置的安全高度然后返航")
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
                                        text: qsTr("在Home点上方停留时间") + " " + rangeString(_rtlLoitTime)
                                        Layout.fillWidth: true
                                    }
                                    FactTextField {
                                        fact:               _rtlLoitTime
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
                            text:       qsTr("降落")
                            font.bold:  true
                            font.pointSize: ScreenTools.mediumFontPointSize
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
                                        text: qsTr("安全高度") + " " + rangeString(_rtlAltFinal)
                                        Layout.fillWidth: true
                                    }
                                    FactTextField {
                                        fact:               _rtlAltFinal
                                        showUnits:          true
                                        Layout.preferredWidth: _fieldWidth
                                    }
                                }

                                RowLayout {
                                    width: parent.width
                                    QGCLabel {
                                        text: qsTr("着陆速度") + " " + rangeString(_landSpeed)
                                        Layout.fillWidth: true
                                    }
                                    FactTextField {
                                        fact:               _landSpeed
                                        showUnits:          true
                                        Layout.preferredWidth: _fieldWidth
                                    }
                                }

                                QGCLabel {
                                    text:           qsTr("低于安全高度时生效")
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
                                text:       qsTr("高级参数")
                                font.bold:  true
                                font.pointSize: ScreenTools.mediumFontPointSize
                            }

                            QGCLabel {
                                text:       _advancedExpanded ? "▲" : "▼"
                                font.bold:  true
                                font.pointSize: ScreenTools.mediumFontPointSize
                                anchors.verticalCenter: parent.verticalCenter
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
                                QGCLabel { text: qsTr("最大飞行角度") }
                                QGCLabel {
                                    text:           "ANGLE_MAX"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color:          qgcPal.text
                                    opacity:        0.5
                                }
                            }
                            QGCLabel {
                                text: rangeString(_angleMax)
                                verticalAlignment: Text.AlignVCenter
                            }
                            FactTextField {
                                fact:               _angleMax
                                showUnits:          true
                                Layout.preferredWidth: _fieldWidth
                            }

                            Column {
                                Layout.fillWidth: true
                                QGCLabel { text: qsTr("垂直加速度") }
                                QGCLabel {
                                    text:           "PILOT_ACCELZ"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color:          qgcPal.text
                                    opacity:        0.5
                                }
                            }
                            QGCLabel {
                                text: rangeString(_pilotAccelZ)
                                verticalAlignment: Text.AlignVCenter
                            }
                            FactTextField {
                                fact:               _pilotAccelZ
                                showUnits:          true
                                Layout.preferredWidth: _fieldWidth
                            }

                            Column {
                                Layout.fillWidth: true
                                QGCLabel { text: qsTr("最大飞行加速度") }
                                QGCLabel {
                                    text:           "LOIT_ACC_MAX"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color:          qgcPal.text
                                    opacity:        0.5
                                }
                            }
                            QGCLabel {
                                text: rangeString(_loitAccMax)
                                verticalAlignment: Text.AlignVCenter
                            }
                            FactTextField {
                                fact:               _loitAccMax
                                showUnits:          true
                                Layout.preferredWidth: _fieldWidth
                            }

                            Column {
                                Layout.fillWidth: true
                                QGCLabel { text: qsTr("控制器时间常数") }
                                QGCLabel {
                                    text:           "ATC_INPUTTC"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color:          qgcPal.text
                                    opacity:        0.5
                                }
                            }
                            QGCLabel {
                                text: rangeString(_atcInputTc)
                                verticalAlignment: Text.AlignVCenter
                            }
                            FactTextField {
                                fact:               _atcInputTc
                                showUnits:          true
                                Layout.preferredWidth: _fieldWidth
                            }

                            Column {
                                Layout.fillWidth: true
                                QGCLabel { text: qsTr("角速度最大值P") }
                                QGCLabel {
                                    text:           "ATC_RATE_P_MAX"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color:          qgcPal.text
                                    opacity:        0.5
                                }
                            }
                            QGCLabel {
                                text: rangeString(_atcRatePMax)
                                verticalAlignment: Text.AlignVCenter
                            }
                            FactTextField {
                                fact:               _atcRatePMax
                                showUnits:          true
                                Layout.preferredWidth: _fieldWidth
                            }

                            Column {
                                Layout.fillWidth: true
                                QGCLabel { text: qsTr("角速度最大值R") }
                                QGCLabel {
                                    text:           "ATC_RATE_R_MAX"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color:          qgcPal.text
                                    opacity:        0.5
                                }
                            }
                            QGCLabel {
                                text: rangeString(_atcRateRMax)
                                verticalAlignment: Text.AlignVCenter
                            }
                            FactTextField {
                                fact:               _atcRateRMax
                                showUnits:          true
                                Layout.preferredWidth: _fieldWidth
                            }

                            Column {
                                Layout.fillWidth: true
                                QGCLabel { text: qsTr("角速度最大值Y") }
                                QGCLabel {
                                    text:           "ATC_RATE_Y_MAX"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color:          qgcPal.text
                                    opacity:        0.5
                                }
                            }
                            QGCLabel {
                                text: rangeString(_atcRateYMax)
                                verticalAlignment: Text.AlignVCenter
                            }
                            FactTextField {
                                fact:               _atcRateYMax
                                showUnits:          true
                                Layout.preferredWidth: _fieldWidth
                            }

                            Column {
                                Layout.fillWidth: true
                                QGCLabel { text: qsTr("角加速度最大值P") }
                                QGCLabel {
                                    text:           "ATC_ACCEL_P_MAX"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color:          qgcPal.text
                                    opacity:        0.5
                                }
                            }
                            QGCLabel {
                                text: rangeString(_atcAccelPMax)
                                verticalAlignment: Text.AlignVCenter
                            }
                            FactTextField {
                                fact:               _atcAccelPMax
                                showUnits:          true
                                Layout.preferredWidth: _fieldWidth
                            }

                            Column {
                                Layout.fillWidth: true
                                QGCLabel { text: qsTr("角加速度最大值R") }
                                QGCLabel {
                                    text:           "ATC_ACCEL_R_MAX"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color:          qgcPal.text
                                    opacity:        0.5
                                }
                            }
                            QGCLabel {
                                text: rangeString(_atcAccelRMax)
                                verticalAlignment: Text.AlignVCenter
                            }
                            FactTextField {
                                fact:               _atcAccelRMax
                                showUnits:          true
                                Layout.preferredWidth: _fieldWidth
                            }

                            Column {
                                Layout.fillWidth: true
                                QGCLabel { text: qsTr("角加速度最大值Y") }
                                QGCLabel {
                                    text:           "ATC_ACCEL_Y_MAX"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color:          qgcPal.text
                                    opacity:        0.5
                                }
                            }
                            QGCLabel {
                                text: rangeString(_atcAccelYMax)
                                verticalAlignment: Text.AlignVCenter
                            }
                            FactTextField {
                                fact:               _atcAccelYMax
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
