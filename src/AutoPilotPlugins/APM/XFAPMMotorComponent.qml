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
import QGroundControl.Controllers

SetupPage {
    id:             motorPage
    pageComponent:  pageComponent
    pageName:       ""
    pageDescription: ""

    readonly property int _motorTimeoutSecs: 3

    APMAirframeComponentController { id: airframeController }

    FactPanelController {
        id: controller
    }

    function frameClassToGeometryName(frameClassValue) {
        switch (frameClassValue) {
        case 0:  return qsTr("Undefined")
        case 1:  return qsTr("Quadrotor")
        case 2:  return qsTr("Hexarotor")
        case 3:  return qsTr("Octorotor")
        case 4:  return qsTr("Octa-Quad")
        case 5:  return qsTr("Y6")
        case 6:  return qsTr("Helicopter")
        case 7:  return qsTr("Tricopter")
        case 8:  return qsTr("Single Copter")
        case 9:  return qsTr("Coax Copter")
        case 10: return qsTr("Bicopter")
        case 11: return qsTr("Heli Dual")
        case 12: return qsTr("Dodeca Hexa")
        case 13: return qsTr("Heli Quad")
        default: return qsTr("Unknown")
        }
    }

    function frameClassToImage(frameClassValue) {
        switch (frameClassValue) {
        case 1:  return "/qmlimages/Airframe/QuadRotorX.svg"
        case 2:  return "/qmlimages/Airframe/HexaRotorX.svg"
        case 3:  return "/qmlimages/Airframe/OctoRotorX.svg"
        case 4:  return "/qmlimages/Airframe/OctoRotorXCoaxial.svg"
        case 5:  return "/qmlimages/Airframe/Y6B.svg"
        case 6:  return "/qmlimages/Airframe/Helicopter.svg"
        case 7:  return "/qmlimages/Airframe/YPlus.svg"
        case 8:  return "/qmlimages/Airframe/AirframeUnknown.svg"
        case 9:  return "/qmlimages/Airframe/HelicopterCoaxial.svg"
        case 10: return "/qmlimages/Airframe/AirframeUnknown.svg"
        case 11: return "/qmlimages/Airframe/Helicopter.svg"
        case 12: return "/qmlimages/Airframe/OctoRotorX.svg"
        case 13: return "/qmlimages/Airframe/Helicopter.svg"
        default: return "/qmlimages/Airframe/AirframeUnknown.svg"
        }
    }

    function motorTestIndexForPhysicalMotor(physicalMotor, frameClassValue, frameTypeValue) {
        if (frameClassValue === 2 && frameTypeValue === 1) {
            // ArduPilot HEXA X motor-test order to physical output order is 5,1,4,6,2,3.
            return [2, 5, 6, 3, 1, 4][physicalMotor - 1]
        }

        return physicalMotor
    }

    Component {
        id: pageComponent

        ColumnLayout {
            id:                 mainLayout
            x:                  ScreenTools.defaultFontPixelWidth * 2
            width:              availableWidth - ScreenTools.defaultFontPixelWidth * 2
            spacing:            ScreenTools.defaultFontPixelHeight

            property Fact _frameClass: airframeController.getParameterFact(-1, "FRAME_CLASS")
            property Fact _frameType:  airframeController.getParameterFact(-1, "FRAME_TYPE", false)

            QGCLabel {
                text:           qsTr("Geometry: %1").arg(frameClassToGeometryName(_frameClass.rawValue))
                font.pointSize: ScreenTools.smallFontPointSize
                color:          qgcPal.text
            }

            RowLayout {
                Layout.fillWidth:   true
                Layout.fillHeight:  true
                spacing:            ScreenTools.defaultFontPixelWidth * 4

                Rectangle {
                    Layout.preferredWidth:  ScreenTools.defaultFontPixelHeight * 12
                    Layout.fillHeight:      true
                    Layout.minimumHeight:   ScreenTools.defaultFontPixelHeight * 10
                    color:                  qgcPal.windowShade
                    radius:                 ScreenTools.defaultFontPixelWidth * 0.5

                    Image {
                        anchors.fill:           parent
                        anchors.margins:        ScreenTools.defaultFontPixelWidth * 2
                        fillMode:               Image.PreserveAspectFit
                        smooth:                 true
                        antialiasing:           true
                        source:                 frameClassToImage(_frameClass.rawValue)
                    }
                }

                ColumnLayout {
                    Layout.fillWidth:   true
                    Layout.alignment:   Qt.AlignTop
                    spacing:            ScreenTools.defaultFontPixelHeight

                    RowLayout {
                        Layout.fillWidth:   true
                        spacing:            ScreenTools.defaultFontPixelWidth * 2

                        QGCLabel {
                            text:               qsTr("Throttle")
                            Layout.alignment:   Qt.AlignVCenter
                        }

                        QGCTextField {
                            id:                 throttleField
                            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                            text:               "0"
                            inputMethodHints:   Qt.ImhFormattedNumbersOnly
                            validator:          IntValidator { bottom: 0; top: 100 }
                        }

                        QGCLabel {
                            text:               qsTr("%")
                            Layout.alignment:   Qt.AlignVCenter
                        }

                        Item { Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }

                        QGCLabel {
                            text:               qsTr("Duration")
                            Layout.alignment:   Qt.AlignVCenter
                        }

                        QGCTextField {
                            id:                 durationField
                            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                            text:               "3"
                            inputMethodHints:   Qt.ImhFormattedNumbersOnly
                            validator:          IntValidator { bottom: 0; top: 30 }
                        }

                        QGCLabel {
                            text:               qsTr("s")
                            Layout.alignment:   Qt.AlignVCenter
                        }
                    }

                    RowLayout {
                        Layout.fillWidth:   true
                        spacing:            ScreenTools.defaultFontPixelWidth * 2

                        QGCButton {
                            text:       qsTr("Start All")
                            enabled:    safetySwitch.checked
                            onClicked:  {
                                var throttleValue = parseInt(throttleField.text) || 0
                                var durationValue = parseInt(durationField.text) || 0
                                for (var motorIndex = 0; motorIndex < buttonRepeater.count; motorIndex++) {
                                    controller.vehicle.motorTest(motorTestIndexForPhysicalMotor(motorIndex + 1, _frameClass.rawValue, _frameType ? _frameType.rawValue : -1),
                                                                  throttleValue, throttleValue === 0 ? 0 : durationValue, true)
                                }
                            }
                        }

                        QGCButton {
                            text:       qsTr("Stop All")
                            enabled:    safetySwitch.checked
                            onClicked:  {
                                for (var motorIndex = 0; motorIndex < buttonRepeater.count; motorIndex++) {
                                    controller.vehicle.motorTest(motorTestIndexForPhysicalMotor(motorIndex + 1, _frameClass.rawValue, _frameType ? _frameType.rawValue : -1), 0, 0, true)
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth:   true
                        spacing:            ScreenTools.defaultFontPixelWidth * 2

                        Repeater {
                            id:         buttonRepeater
                            model:      controller.vehicle.motorCount === -1 ? 8 : controller.vehicle.motorCount

                            QGCButton {
                                text:       qsTr("Motor %1").arg(index + 1)
                                enabled:    safetySwitch.checked
                                onClicked:  {
                                    var throttleValue = parseInt(throttleField.text) || 0
                                    var durationValue = parseInt(durationField.text) || 0
                                    controller.vehicle.motorTest(motorTestIndexForPhysicalMotor(index + 1, _frameClass.rawValue, _frameType ? _frameType.rawValue : -1),
                                                                  throttleValue, throttleValue === 0 ? 0 : durationValue, true)
                                }
                            }
                        }
                    }

                    Row {
                        spacing: ScreenTools.defaultFontPixelWidth

                        Switch {
                            id: safetySwitch
                            onClicked: {
                                if (!checked) {
                                    throttleField.text = "0"
                                }
                            }
                        }

                        QGCLabel {
                            anchors.verticalCenter: parent.verticalCenter
                            color:                  qgcPal.warningText
                            text:                   safetySwitch.checked ?
                                                        qsTr("Careful: Motors are enabled") :
                                                        qsTr("Propellers are removed - Enable slider and motors")
                        }
                    }
                }
            }
        }
    }
}
