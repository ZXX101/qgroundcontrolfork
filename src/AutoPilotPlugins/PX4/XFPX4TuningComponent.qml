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
import QtCharts

import QGroundControl
import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.Palette
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Vehicle

SetupPage {
    id: tuningPage
    pageComponent: tuningPageComponent

    Component {
        id: tuningPageComponent

        ColumnLayout {
            width: availableWidth
            spacing: ScreenTools.defaultFontPixelHeight

            FactPanelController { id: controller }

            property Fact _rateRollK:       controller.getParameterFact(-1, "MC_ROLLRATE_K", false)
            property Fact _rateRollD:       controller.getParameterFact(-1, "MC_ROLLRATE_D", false)
            property Fact _rateRollI:       controller.getParameterFact(-1, "MC_ROLLRATE_I", false)
            property Fact _ratePitchK:      controller.getParameterFact(-1, "MC_PITCHRATE_K", false)
            property Fact _ratePitchD:      controller.getParameterFact(-1, "MC_PITCHRATE_D", false)
            property Fact _ratePitchI:      controller.getParameterFact(-1, "MC_PITCHRATE_I", false)
            property Fact _rateYawK:        controller.getParameterFact(-1, "MC_YAWRATE_K", false)
            property Fact _rateYawI:        controller.getParameterFact(-1, "MC_YAWRATE_I", false)

            property Fact _angRollP:        controller.getParameterFact(-1, "MC_ROLL_P", false)
            property Fact _angPitchP:       controller.getParameterFact(-1, "MC_PITCH_P", false)
            property Fact _angYawP:         controller.getParameterFact(-1, "MC_YAW_P", false)

            property Fact _velXYP:          controller.getParameterFact(-1, "MPC_XY_VEL_P_ACC", false)
            property Fact _velXYI:          controller.getParameterFact(-1, "MPC_XY_VEL_I_ACC", false)
            property Fact _velXYD:          controller.getParameterFact(-1, "MPC_XY_VEL_D_ACC", false)
            property Fact _velZP:           controller.getParameterFact(-1, "MPC_Z_VEL_P_ACC", false)
            property Fact _velZI:           controller.getParameterFact(-1, "MPC_Z_VEL_I_ACC", false)
            property Fact _velZD:           controller.getParameterFact(-1, "MPC_Z_VEL_D_ACC", false)

            property Fact _posXYP:          controller.getParameterFact(-1, "MPC_XY_P", false)
            property Fact _posZP:           controller.getParameterFact(-1, "MPC_Z_P", false)

            property Fact _airmode:         controller.getParameterFact(-1, "MC_AIRMODE", false)
            property Fact _thrustModelFactor: controller.getParameterFact(-1, "THR_MDL_FAC", false)
            property Fact _mcPosMode:       controller.getParameterFact(-1, "MPC_POS_MODE", false)

            TabBar {
                id: tabBar
                Layout.fillWidth: true
                spacing: 0
                background: Rectangle {
                    color: "transparent"
                }

                TabButton {
                    text: qsTr("Rate")
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: qgcPal.buttonText
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: "transparent"
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width * 0.8
                            height: 2
                            color: "#154D25"
                            visible: parent.parent.checked
                        }
                    }
                }
                TabButton {
                    text: qsTr("Attitude")
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: qgcPal.buttonText
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: "transparent"
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width * 0.8
                            height: 2
                            color: "#154D25"
                            visible: parent.parent.checked
                        }
                    }
                }
                TabButton {
                    text: qsTr("Velocity")
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: qgcPal.buttonText
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: "transparent"
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width * 0.8
                            height: 2
                            color: "#154D25"
                            visible: parent.parent.checked
                        }
                    }
                }
                TabButton {
                    text: qsTr("Position")
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: qgcPal.buttonText
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: "transparent"
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width * 0.8
                            height: 2
                            color: "#154D25"
                            visible: parent.parent.checked
                        }
                    }
                }
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: tabBar.currentIndex

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: ScreenTools.defaultFontPixelHeight

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: ScreenTools.defaultFontPixelWidth * 2
                        visible: _airmode || _thrustModelFactor

                        QGCLabel {
                            textFormat: Text.RichText
                            text: qsTr("Airmode (disable during tuning)")
                            visible: _airmode
                        }
                        FactComboBox {
                            fact: _airmode
                            indexModel: false
                            visible: _airmode
                        }

                        Item { width: 1; height: 1 }

                        QGCLabel {
                            text: qsTr("Thrust curve")
                            visible: _thrustModelFactor
                        }
                        FactTextField {
                            fact: _thrustModelFactor
                            visible: _thrustModelFactor
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: ScreenTools.defaultFontPixelWidth * 4

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: ScreenTools.defaultFontPixelHeight * 0.5

                            QGCLabel {
                                text: qsTr("Roll")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "K"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.3-3"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                FactTextField { fact: _rateRollK; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10; visible: _rateRollK }
                            }
                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "D"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.0004-0.01"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                FactTextField { fact: _rateRollD; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10; visible: _rateRollD }
                            }
                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "I"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.1-0.5"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                FactTextField { fact: _rateRollI; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10; visible: _rateRollI }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: ScreenTools.defaultFontPixelHeight * 0.5

                            QGCLabel {
                                text: qsTr("Pitch")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "K"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.3-3"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                FactTextField { fact: _ratePitchK; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10; visible: _ratePitchK }
                            }
                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "D"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.0004-0.01"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                FactTextField { fact: _ratePitchD; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10; visible: _ratePitchD }
                            }
                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "I"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.1-0.5"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                FactTextField { fact: _ratePitchI; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10; visible: _ratePitchI }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: ScreenTools.defaultFontPixelHeight * 0.5

                            QGCLabel {
                                text: qsTr("Yaw")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "K"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.3-3"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                FactTextField { fact: _rateYawK; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10; visible: _rateYawK }
                            }
                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "I"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.04-0.4"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                FactTextField { fact: _rateYawI; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10; visible: _rateYawI }
                            }
                        }
                    }

                    XFPIDTuning {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        availableWidth: width
                        availableHeight: height
                        title: qsTr("Rate")
                        tuningMode: Vehicle.ModeRateAndAttitude
                        unit: qsTr("deg/s")
                        chartDisplaySec: 3

                        property var roll: QtObject {
                            property string name: qsTr("Roll")
                            property var plot: [
                                { name: "Response", value: globals.activeVehicle && globals.activeVehicle.rollRate ? globals.activeVehicle.rollRate.value : NaN },
                                { name: "Setpoint", value: globals.activeVehicle && globals.activeVehicle.setpoint ? globals.activeVehicle.setpoint.rollRate.value : NaN }
                            ]
                        }
                        property var pitch: QtObject {
                            property string name: qsTr("Pitch")
                            property var plot: [
                                { name: "Response", value: globals.activeVehicle && globals.activeVehicle.pitchRate ? globals.activeVehicle.pitchRate.value : NaN },
                                { name: "Setpoint", value: globals.activeVehicle && globals.activeVehicle.setpoint ? globals.activeVehicle.setpoint.pitchRate.value : NaN }
                            ]
                        }
                        property var yaw: QtObject {
                            property string name: qsTr("Yaw")
                            property var plot: [
                                { name: "Response", value: globals.activeVehicle && globals.activeVehicle.yawRate ? globals.activeVehicle.yawRate.value : NaN },
                                { name: "Setpoint", value: globals.activeVehicle && globals.activeVehicle.setpoint ? globals.activeVehicle.setpoint.yawRate.value : NaN }
                            ]
                        }
                        axis: [roll, pitch, yaw]
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: ScreenTools.defaultFontPixelHeight

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: ScreenTools.defaultFontPixelWidth * 4

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: ScreenTools.defaultFontPixelHeight * 0.5

                            QGCLabel {
                                text: qsTr("Roll")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "P"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "1-14"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                FactTextField { fact: _angRollP; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10; visible: _angRollP }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: ScreenTools.defaultFontPixelHeight * 0.5

                            QGCLabel {
                                text: qsTr("Pitch")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "P"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "1-14"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                FactTextField { fact: _angPitchP; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10; visible: _angPitchP }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: ScreenTools.defaultFontPixelHeight * 0.5

                            QGCLabel {
                                text: qsTr("Yaw")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "P"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "1-5"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                FactTextField { fact: _angYawP; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10; visible: _angYawP }
                            }
                        }
                    }

                    XFPIDTuning {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        availableWidth: width
                        availableHeight: height
                        title: qsTr("Attitude")
                        tuningMode: Vehicle.ModeRateAndAttitude
                        unit: qsTr("deg")
                        chartDisplaySec: 8

                        property var roll: QtObject {
                            property string name: qsTr("Roll")
                            property var plot: [
                                { name: "Response", value: globals.activeVehicle && globals.activeVehicle.roll ? globals.activeVehicle.roll.value : NaN },
                                { name: "Setpoint", value: globals.activeVehicle && globals.activeVehicle.setpoint ? globals.activeVehicle.setpoint.roll.value : NaN }
                            ]
                        }
                        property var pitch: QtObject {
                            property string name: qsTr("Pitch")
                            property var plot: [
                                { name: "Response", value: globals.activeVehicle && globals.activeVehicle.pitch ? globals.activeVehicle.pitch.value : NaN },
                                { name: "Setpoint", value: globals.activeVehicle && globals.activeVehicle.setpoint ? globals.activeVehicle.setpoint.pitch.value : NaN }
                            ]
                        }
                        property var yaw: QtObject {
                            property string name: qsTr("Yaw")
                            property var plot: [
                                { name: "Response", value: globals.activeVehicle && globals.activeVehicle.heading ? globals.activeVehicle.heading.value : NaN },
                                { name: "Setpoint", value: globals.activeVehicle && globals.activeVehicle.setpoint ? globals.activeVehicle.setpoint.yaw.value : NaN }
                            ]
                        }
                        axis: [roll, pitch, yaw]
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: ScreenTools.defaultFontPixelHeight

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: ScreenTools.defaultFontPixelWidth * 2
                        visible: _mcPosMode

                        QGCLabel {
                            text: qsTr("Position control mode (set to 'simple' during tuning):")
                        }
                        FactComboBox {
                            fact: _mcPosMode
                            indexModel: false
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: ScreenTools.defaultFontPixelWidth * 4

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: ScreenTools.defaultFontPixelHeight * 0.5

                            QGCLabel {
                                text: qsTr("Horizontal")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "P"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "1.2-5"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                FactTextField { fact: _velXYP; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10; visible: _velXYP }
                            }
                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "I"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.2-10"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                FactTextField { fact: _velXYI; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10; visible: _velXYI }
                            }
                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "D"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.1-2"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                FactTextField { fact: _velXYD; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10; visible: _velXYD }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: ScreenTools.defaultFontPixelHeight * 0.5

                            QGCLabel {
                                text: qsTr("Vertical")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "P"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "2-15"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                FactTextField { fact: _velZP; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10; visible: _velZP }
                            }
                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "I"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.2-3"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                FactTextField { fact: _velZI; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10; visible: _velZI }
                            }
                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "D"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0-2"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                FactTextField { fact: _velZD; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10; visible: _velZD }
                            }
                        }
                    }

                    XFPIDTuning {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        availableWidth: width
                        availableHeight: height
                        title: qsTr("Velocity")
                        tuningMode: Vehicle.ModeVelocityAndPosition
                        unit: qsTr("m/s")
                        chartDisplaySec: 8

                        property var horizontal: QtObject {
                            property string name: qsTr("Horizontal")
                            property var plot: [
                                { name: "Response", value: globals.activeVehicle && globals.activeVehicle.localPosition ? globals.activeVehicle.localPosition.vy.value : NaN },
                                { name: "Setpoint", value: globals.activeVehicle && globals.activeVehicle.localPositionSetpoint ? globals.activeVehicle.localPositionSetpoint.vy.value : NaN }
                            ]
                        }
                        property var vertical: QtObject {
                            property string name: qsTr("Vertical")
                            property var plot: [
                                { name: "Response", value: globals.activeVehicle && globals.activeVehicle.localPosition ? globals.activeVehicle.localPosition.vz.value : NaN },
                                { name: "Setpoint", value: globals.activeVehicle && globals.activeVehicle.localPositionSetpoint ? globals.activeVehicle.localPositionSetpoint.vz.value : NaN }
                            ]
                        }
                        axis: [horizontal, vertical]
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: ScreenTools.defaultFontPixelHeight

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: ScreenTools.defaultFontPixelWidth * 2
                        visible: _mcPosMode

                        QGCLabel {
                            text: qsTr("Position control mode (set to 'simple' during tuning):")
                        }
                        FactComboBox {
                            fact: _mcPosMode
                            indexModel: false
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: ScreenTools.defaultFontPixelWidth * 4

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: ScreenTools.defaultFontPixelHeight * 0.5

                            QGCLabel {
                                text: qsTr("Horizontal")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "P"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0-2"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                FactTextField { fact: _posXYP; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10; visible: _posXYP }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: ScreenTools.defaultFontPixelHeight * 0.5

                            QGCLabel {
                                text: qsTr("Vertical")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "P"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0-2"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                FactTextField { fact: _posZP; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10; visible: _posZP }
                            }
                        }
                    }

                    XFPIDTuning {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        availableWidth: width
                        availableHeight: height
                        title: qsTr("Position")
                        tuningMode: Vehicle.ModeVelocityAndPosition
                        unit: qsTr("m")
                        chartDisplaySec: 50

                        property var horizontal: QtObject {
                            property string name: qsTr("Horizontal")
                            property var plot: [
                                { name: "Response", value: globals.activeVehicle && globals.activeVehicle.localPosition ? globals.activeVehicle.localPosition.y.value : NaN },
                                { name: "Setpoint", value: globals.activeVehicle && globals.activeVehicle.localPositionSetpoint ? globals.activeVehicle.localPositionSetpoint.y.value : NaN }
                            ]
                        }
                        property var vertical: QtObject {
                            property string name: qsTr("Vertical")
                            property var plot: [
                                { name: "Response", value: globals.activeVehicle && globals.activeVehicle.localPosition ? globals.activeVehicle.localPosition.z.value : NaN },
                                { name: "Setpoint", value: globals.activeVehicle && globals.activeVehicle.localPositionSetpoint ? globals.activeVehicle.localPositionSetpoint.z.value : NaN }
                            ]
                        }
                        axis: [horizontal, vertical]
                    }
                }
            }
        }
    }
}
