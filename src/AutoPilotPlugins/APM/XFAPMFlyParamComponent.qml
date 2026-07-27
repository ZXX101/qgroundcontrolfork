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
            height: availableHeight

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

            function shortUnitString(units) {
                var unit = units ? units.trim() : ""
                if (unit === "") {
                    return ""
                }

                var unitMap = {
                    "meter":       "m",
                    "meters":      "m",
                    "metre":       "m",
                    "metres":      "m",
                    "centimeter":  "cm",
                    "centimeters": "cm",
                    "millimeter":  "mm",
                    "millimeters": "mm",
                    "kilometer":   "km",
                    "kilometers":  "km",
                    "degree":      "°",
                    "degrees":     "°",
                    "deg":         "°",
                    "cdeg":        "0.01°",
                    "second":      "s",
                    "seconds":     "s",
                    "millisecond": "ms",
                    "milliseconds": "ms",
                    "percent":     "%"
                }

                var parts = unit.split("/")
                for (var i = 0; i < parts.length; i++) {
                    var key = parts[i].trim().toLowerCase()
                    if (unitMap[key] !== undefined) {
                        parts[i] = unitMap[key]
                    }
                }

                unit = parts.join("/")
                unit = unit.replace(/\/s\/s\/s$/, "/s³")
                unit = unit.replace(/\/s\/s$/, "/s²")
                return unit
            }

            function rangeString(fact) {
                var range = ""
                if (!fact.minIsDefaultForType || !fact.maxIsDefaultForType) {
                    var min = fact.minString
                    var max = fact.maxString
                    if (min !== "" || max !== "") {
                        range = "(" + min + " ~ " + max + ")"
                    }
                }

                var units = shortUnitString(fact.units)
                return range + (range !== "" && units !== "" ? " " : "") + units
            }

            Row {
                id:         mainRow
                spacing:    _margins * 2
                width:      parent.width
                height:     parent.height

                QGCFlickable {
                    id:             leftFlickable
                    width:          (parent.width - mainRow.spacing) / 2
                    height:         parent.height
                    clip:           true
                    contentWidth:   leftColumn.width
                    contentHeight:  leftColumn.height

                    Column {
                        id:         leftColumn
                        width:      leftFlickable.width
                        spacing:    _margins * 2

                        Column {
                            width:      parent.width
                            spacing:    _margins

                            QGCLabel {
                                text:       qsTr("Speed")
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

                                    Column {
                                        Layout.fillWidth: true
                                        QGCLabel { text: qsTr("Max Manual Tilt Angle") }
                                        QGCLabel {
                                            text:           rangeString(_angleMax)
                                            font.pointSize: ScreenTools.smallFontPointSize
                                            color:          qgcPal.text
                                            opacity:        0.5
                                        }
                                    }
                                    FactTextField {
                                        fact:               _angleMax

                                        Layout.preferredWidth: _fieldWidth
                                        Layout.alignment:   Qt.AlignRight
                                    }

                                    Column {
                                        Layout.fillWidth: true
                                        QGCLabel { text: qsTr("Max Manual Ascend Speed") }
                                        QGCLabel {
                                            text:           rangeString(_pilotSpeedUp)
                                            font.pointSize: ScreenTools.smallFontPointSize
                                            color:          qgcPal.text
                                            opacity:        0.5
                                        }
                                    }
                                    FactTextField {
                                        fact:               _pilotSpeedUp

                                        Layout.preferredWidth: _fieldWidth
                                        Layout.alignment:   Qt.AlignRight
                                    }

                                    Column {
                                        Layout.fillWidth: true
                                        QGCLabel { text: qsTr("Max Manual Descend Speed") }
                                        QGCLabel {
                                            text:           rangeString(_pilotSpeedDn)
                                            font.pointSize: ScreenTools.smallFontPointSize
                                            color:          qgcPal.text
                                            opacity:        0.5
                                        }
                                    }
                                    FactTextField {
                                        fact:               _pilotSpeedDn

                                        Layout.preferredWidth: _fieldWidth
                                        Layout.alignment:   Qt.AlignRight
                                    }

                                    Column {
                                        Layout.fillWidth: true
                                        QGCLabel { text: qsTr("Auto Flight Speed") }
                                        QGCLabel {
                                            text:           rangeString(_wpnavSpeed)
                                            font.pointSize: ScreenTools.smallFontPointSize
                                            color:          qgcPal.text
                                            opacity:        0.5
                                        }
                                    }
                                    FactTextField {
                                        fact:               _wpnavSpeed

                                        Layout.preferredWidth: _fieldWidth
                                        Layout.alignment:   Qt.AlignRight
                                    }

                                    Column {
                                        Layout.fillWidth: true
                                        QGCLabel { text: qsTr("Auto Ascend Speed") }
                                        QGCLabel {
                                            text:           rangeString(_wpnavSpeedUp)
                                            font.pointSize: ScreenTools.smallFontPointSize
                                            color:          qgcPal.text
                                            opacity:        0.5
                                        }
                                    }
                                    FactTextField {
                                        fact:               _wpnavSpeedUp

                                        Layout.preferredWidth: _fieldWidth
                                        Layout.alignment:   Qt.AlignRight
                                    }

                                    Column {
                                        Layout.fillWidth: true
                                        QGCLabel { text: qsTr("Auto Descend Speed") }
                                        QGCLabel {
                                            text:           rangeString(_wpnavSpeedDn)
                                            font.pointSize: ScreenTools.smallFontPointSize
                                            color:          qgcPal.text
                                            opacity:        0.5
                                        }
                                    }
                                    FactTextField {
                                        fact:               _wpnavSpeedDn

                                        Layout.preferredWidth: _fieldWidth
                                        Layout.alignment:   Qt.AlignRight
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
                                        Column {
                                            Layout.fillWidth: true
                                            QGCLabel { text: qsTr("RTL Altitude") }
                                            QGCLabel {
                                                text:           rangeString(_rtlAlt)
                                                font.pointSize: ScreenTools.smallFontPointSize
                                                color:          qgcPal.text
                                                opacity:        0.5
                                            }
                                        }
                                        FactTextField {
                                            fact:               _rtlAlt
        
                                            Layout.preferredWidth: _fieldWidth
                                            Layout.alignment:   Qt.AlignRight
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
                                        Column {
                                            Layout.fillWidth: true
                                            QGCLabel { text: qsTr("Loiter Time Above Home") }
                                            QGCLabel {
                                                text:           rangeString(_rtlLoitTime)
                                                font.pointSize: ScreenTools.smallFontPointSize
                                                color:          qgcPal.text
                                                opacity:        0.5
                                            }
                                        }
                                        FactTextField {
                                            fact:               _rtlLoitTime
        
                                            Layout.preferredWidth: _fieldWidth
                                            Layout.alignment:   Qt.AlignRight
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
                                        Column {
                                            Layout.fillWidth: true
                                            QGCLabel { text: qsTr("Safe Altitude") }
                                            QGCLabel {
                                                text:           rangeString(_rtlAltFinal)
                                                font.pointSize: ScreenTools.smallFontPointSize
                                                color:          qgcPal.text
                                                opacity:        0.5
                                            }
                                        }
                                        FactTextField {
                                            fact:               _rtlAltFinal
        
                                            Layout.preferredWidth: _fieldWidth
                                            Layout.alignment:   Qt.AlignRight
                                        }
                                    }

                                    RowLayout {
                                        width: parent.width
                                        Column {
                                            Layout.fillWidth: true
                                            QGCLabel { text: qsTr("Landing Speed") }
                                            QGCLabel {
                                                text:           rangeString(_landSpeed)
                                                font.pointSize: ScreenTools.smallFontPointSize
                                                color:          qgcPal.text
                                                opacity:        0.5
                                            }
                                        }
                                        FactTextField {
                                            fact:               _landSpeed
        
                                            Layout.preferredWidth: _fieldWidth
                                            Layout.alignment:   Qt.AlignRight
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
                    }
                }

                QGCFlickable {
                    id:             rightFlickable
                    width:          (parent.width - mainRow.spacing) / 2
                    height:         parent.height
                    clip:           true
                    contentWidth:   rightColumn.width
                    contentHeight:  rightColumn.height

                    Column {
                        id:         rightColumn
                        width:      rightFlickable.width
                        spacing:    _margins

                        QGCLabel {
                            text:       qsTr("Advanced Parameters")
                            font.bold:  true
                            font.pointSize: ScreenTools.mediumFontPointSize
                        }

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
                                columns:        2
                                columnSpacing:  _margins
                                rowSpacing:     _margins

                                Column {
                                    Layout.fillWidth: true
                                    QGCLabel { text: qsTr("Max Flight Angle") }
                                    QGCLabel {
                                        text:           "ANGLE_MAX"
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        color:          qgcPal.text
                                        opacity:        0.5
                                    }
                                    QGCLabel {
                                        text:           rangeString(_angleMax)
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        color:          qgcPal.text
                                        opacity:        0.5
                                    }
                                }
                                FactTextField {
                                    fact:               _angleMax

                                    Layout.preferredWidth: _fieldWidth
                                    Layout.alignment:   Qt.AlignRight
                                    Layout.rightMargin: _margins
                                }

                                Column {
                                    Layout.fillWidth: true
                                    QGCLabel { text: qsTr("Vertical Acceleration") }
                                    QGCLabel {
                                        text:           "PILOT_ACCELZ"
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        color:          qgcPal.text
                                        opacity:        0.5
                                    }
                                    QGCLabel {
                                        text:           rangeString(_pilotAccelZ)
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        color:          qgcPal.text
                                        opacity:        0.5
                                    }
                                }
                                FactTextField {
                                    fact:               _pilotAccelZ

                                    Layout.preferredWidth: _fieldWidth
                                    Layout.alignment:   Qt.AlignRight
                                    Layout.rightMargin: _margins
                                }

                                Column {
                                    Layout.fillWidth: true
                                    QGCLabel { text: qsTr("Max Flight Acceleration") }
                                    QGCLabel {
                                        text:           "LOIT_ACC_MAX"
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        color:          qgcPal.text
                                        opacity:        0.5
                                    }
                                    QGCLabel {
                                        text:           rangeString(_loitAccMax)
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        color:          qgcPal.text
                                        opacity:        0.5
                                    }
                                }
                                FactTextField {
                                    fact:               _loitAccMax

                                    Layout.preferredWidth: _fieldWidth
                                    Layout.alignment:   Qt.AlignRight
                                    Layout.rightMargin: _margins
                                }

                                Column {
                                    Layout.fillWidth: true
                                    QGCLabel { text: qsTr("Controller Time Constant") }
                                    QGCLabel {
                                        text:           "ATC_INPUTTC"
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        color:          qgcPal.text
                                        opacity:        0.5
                                    }
                                    QGCLabel {
                                        text:           rangeString(_atcInputTc)
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        color:          qgcPal.text
                                        opacity:        0.5
                                    }
                                }
                                FactTextField {
                                    fact:               _atcInputTc

                                    Layout.preferredWidth: _fieldWidth
                                    Layout.alignment:   Qt.AlignRight
                                    Layout.rightMargin: _margins
                                }

                                Column {
                                    Layout.fillWidth: true
                                    QGCLabel { text: qsTr("Max Angular Rate P") }
                                    QGCLabel {
                                        text:           "ATC_RATE_P_MAX"
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        color:          qgcPal.text
                                        opacity:        0.5
                                    }
                                    QGCLabel {
                                        text:           rangeString(_atcRatePMax)
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        color:          qgcPal.text
                                        opacity:        0.5
                                    }
                                }
                                FactTextField {
                                    fact:               _atcRatePMax

                                    Layout.preferredWidth: _fieldWidth
                                    Layout.alignment:   Qt.AlignRight
                                    Layout.rightMargin: _margins
                                }

                                Column {
                                    Layout.fillWidth: true
                                    QGCLabel { text: qsTr("Max Angular Rate R") }
                                    QGCLabel {
                                        text:           "ATC_RATE_R_MAX"
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        color:          qgcPal.text
                                        opacity:        0.5
                                    }
                                    QGCLabel {
                                        text:           rangeString(_atcRateRMax)
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        color:          qgcPal.text
                                        opacity:        0.5
                                    }
                                }
                                FactTextField {
                                    fact:               _atcRateRMax

                                    Layout.preferredWidth: _fieldWidth
                                    Layout.alignment:   Qt.AlignRight
                                    Layout.rightMargin: _margins
                                }

                                Column {
                                    Layout.fillWidth: true
                                    QGCLabel { text: qsTr("Max Angular Rate Y") }
                                    QGCLabel {
                                        text:           "ATC_RATE_Y_MAX"
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        color:          qgcPal.text
                                        opacity:        0.5
                                    }
                                    QGCLabel {
                                        text:           rangeString(_atcRateYMax)
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        color:          qgcPal.text
                                        opacity:        0.5
                                    }
                                }
                                FactTextField {
                                    fact:               _atcRateYMax

                                    Layout.preferredWidth: _fieldWidth
                                    Layout.alignment:   Qt.AlignRight
                                    Layout.rightMargin: _margins
                                }

                                Column {
                                    Layout.fillWidth: true
                                    QGCLabel { text: qsTr("Max Angular Acceleration P") }
                                    QGCLabel {
                                        text:           "ATC_ACCEL_P_MAX"
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        color:          qgcPal.text
                                        opacity:        0.5
                                    }
                                    QGCLabel {
                                        text:           rangeString(_atcAccelPMax)
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        color:          qgcPal.text
                                        opacity:        0.5
                                    }
                                }
                                FactTextField {
                                    fact:               _atcAccelPMax

                                    Layout.preferredWidth: _fieldWidth
                                    Layout.alignment:   Qt.AlignRight
                                    Layout.rightMargin: _margins
                                }

                                Column {
                                    Layout.fillWidth: true
                                    QGCLabel { text: qsTr("Max Angular Acceleration R") }
                                    QGCLabel {
                                        text:           "ATC_ACCEL_R_MAX"
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        color:          qgcPal.text
                                        opacity:        0.5
                                    }
                                    QGCLabel {
                                        text:           rangeString(_atcAccelRMax)
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        color:          qgcPal.text
                                        opacity:        0.5
                                    }
                                }
                                FactTextField {
                                    fact:               _atcAccelRMax

                                    Layout.preferredWidth: _fieldWidth
                                    Layout.alignment:   Qt.AlignRight
                                    Layout.rightMargin: _margins
                                }

                                Column {
                                    Layout.fillWidth: true
                                    QGCLabel { text: qsTr("Max Angular Acceleration Y") }
                                    QGCLabel {
                                        text:           "ATC_ACCEL_Y_MAX"
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        color:          qgcPal.text
                                        opacity:        0.5
                                    }
                                    QGCLabel {
                                        text:           rangeString(_atcAccelYMax)
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        color:          qgcPal.text
                                        opacity:        0.5
                                    }
                                }
                                FactTextField {
                                    fact:               _atcAccelYMax

                                    Layout.preferredWidth: _fieldWidth
                                    Layout.alignment:   Qt.AlignRight
                                    Layout.rightMargin: _margins
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
