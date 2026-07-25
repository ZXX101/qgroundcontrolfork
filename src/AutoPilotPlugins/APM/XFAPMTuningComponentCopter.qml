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
    pageName:       ""
    pageDescription: ""
    Component {
        id: tuningPageComponent

        ColumnLayout {
            width: availableWidth
            spacing: ScreenTools.defaultFontPixelHeight

            FactPanelController { id: controller }
            QGCPalette { id: qgcPal; colorGroupEnabled: true }

            property real _margins: ScreenTools.defaultFontPixelHeight / 2

            property Fact _rateRollP: controller.getParameterFact(-1, "ATC_RAT_RLL_P")
            property Fact _rateRollI: controller.getParameterFact(-1, "ATC_RAT_RLL_I")
            property Fact _rateRollD: controller.getParameterFact(-1, "ATC_RAT_RLL_D")
            property Fact _ratePitchP: controller.getParameterFact(-1, "ATC_RAT_PIT_P")
            property Fact _ratePitchI: controller.getParameterFact(-1, "ATC_RAT_PIT_I")
            property Fact _ratePitchD: controller.getParameterFact(-1, "ATC_RAT_PIT_D")
            property Fact _rateYawP: controller.getParameterFact(-1, "ATC_RAT_YAW_P")
            property Fact _rateYawI: controller.getParameterFact(-1, "ATC_RAT_YAW_I")
            property Fact _rateYawD: controller.getParameterFact(-1, "ATC_RAT_YAW_D")

            property Fact _angRollP: controller.getParameterFact(-1, "ATC_ANG_RLL_P")
            property Fact _angPitchP: controller.getParameterFact(-1, "ATC_ANG_PIT_P")
            property Fact _angYawP: controller.getParameterFact(-1, "ATC_ANG_YAW_P")

            property Fact _angRollAccel: controller.getParameterFact(-1, "ATC_ACCEL_R_MAX")
            property Fact _angPitchAccel: controller.getParameterFact(-1, "ATC_ACCEL_P_MAX")
            property Fact _angYawAccel: controller.getParameterFact(-1, "ATC_ACCEL_Y_MAX")

            property Fact _velXYP: controller.getParameterFact(-1, "PSC_VELXY_P")
            property Fact _velXYI: controller.getParameterFact(-1, "PSC_VELXY_I")
            property Fact _velXYD: controller.getParameterFact(-1, "PSC_VELXY_D")
            property Fact _velZP: controller.getParameterFact(-1, "PSC_VELZ_P")
            property Fact _velZI: controller.getParameterFact(-1, "PSC_VELZ_I")
            property Fact _velZD: controller.getParameterFact(-1, "PSC_VELZ_D")

            property Fact _posXYP: controller.getParameterFact(-1, "PSC_POSXY_P")
            property Fact _posZP: controller.getParameterFact(-1, "PSC_POSZ_P")

            property Fact _atcInputTC: controller.getParameterFact(-1, "ATC_INPUT_TC")

            TabBar {
                id: tabBar
                Layout.fillWidth: true
                Layout.leftMargin: _margins
                Layout.rightMargin: _margins
                spacing: 0
                background: Rectangle {
                    color: "transparent"
                }

                TabButton {
                    text: qsTr("Rate")
                    leftPadding: _margins * 2
                    rightPadding: _margins * 2
                    topPadding: _margins
                    bottomPadding: _margins
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
                    leftPadding: _margins * 2
                    rightPadding: _margins * 2
                    topPadding: _margins
                    bottomPadding: _margins
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
                    leftPadding: _margins * 2
                    rightPadding: _margins * 2
                    topPadding: _margins
                    bottomPadding: _margins
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
                    leftPadding: _margins * 2
                    rightPadding: _margins * 2
                    topPadding: _margins
                    bottomPadding: _margins
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
                Layout.leftMargin: _margins
                Layout.rightMargin: _margins
                currentIndex: tabBar.currentIndex

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: _margins * 2

                    Column {
                        Layout.fillWidth: true
                        spacing: _margins

                        QGCLabel {
                            text: qsTr("Rate Controller")
                            font.bold: true
                            font.pointSize: ScreenTools.mediumFontPointSize
                        }

                        Rectangle {
                            width: parent.width
                            height: rateParamsGrid.height + _margins * 2
                            color: qgcPal.windowShade
                            radius: ScreenTools.buttonBorderRadius

                            RowLayout {
                                id: rateParamsGrid
                                anchors.margins: _margins
                                anchors.left: parent.left
                                anchors.top: parent.top
                                width: parent.width - _margins * 2
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
                                        QGCLabel { text: "0.001-0.5"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                        FactTextField { fact: _rateRollP; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                                    }
                                    RowLayout {
                                        spacing: ScreenTools.defaultFontPixelWidth
                                        QGCLabel { text: "I"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                        QGCLabel { text: "0.01-2"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                        FactTextField { fact: _rateRollI; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                                    }
                                    RowLayout {
                                        spacing: ScreenTools.defaultFontPixelWidth
                                        QGCLabel { text: "D"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                        QGCLabel { text: "0.0-0.05"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                        FactTextField { fact: _rateRollD; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
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
                                        QGCLabel { text: "0.001-0.5"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                        FactTextField { fact: _ratePitchP; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                                    }
                                    RowLayout {
                                        spacing: ScreenTools.defaultFontPixelWidth
                                        QGCLabel { text: "I"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                        QGCLabel { text: "0.01-2"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                        FactTextField { fact: _ratePitchI; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                                    }
                                    RowLayout {
                                        spacing: ScreenTools.defaultFontPixelWidth
                                        QGCLabel { text: "D"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                        QGCLabel { text: "0.0-0.05"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                        FactTextField { fact: _ratePitchD; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
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
                                        QGCLabel { text: "0.1-2.5"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                        FactTextField { fact: _rateYawP; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                                    }
                                    RowLayout {
                                        spacing: ScreenTools.defaultFontPixelWidth
                                        QGCLabel { text: "I"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                        QGCLabel { text: "0.01-1"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                        FactTextField { fact: _rateYawI; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                                    }
                                    RowLayout {
                                        spacing: ScreenTools.defaultFontPixelWidth
                                        QGCLabel { text: "D"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                        QGCLabel { text: "0.0-0.05"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                        FactTextField { fact: _rateYawD; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                                    }
                                }
                            }
                        }
                    }

                    XFPIDTuning {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        availableWidth: width
                        availableHeight: height
                        title: qsTr("Rate")
                        tuningMode: Vehicle.ModeDisabled
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
                    spacing: _margins * 2

                    Column {
                        Layout.fillWidth: true
                        spacing: _margins

                        QGCLabel {
                            text: qsTr("Attitude Controller")
                            font.bold: true
                            font.pointSize: ScreenTools.mediumFontPointSize
                        }

                        Rectangle {
                            width: parent.width
                            height: attitudeParamsGrid.height + _margins * 2
                            color: qgcPal.windowShade
                            radius: ScreenTools.buttonBorderRadius

                            RowLayout {
                                id: attitudeParamsGrid
                                anchors.margins: _margins
                                anchors.left: parent.left
                                anchors.top: parent.top
                                width: parent.width - _margins * 2
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
                                        QGCLabel { text: "3-12"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                        FactTextField { fact: _angRollP; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                                    }
                                    RowLayout {
                                        spacing: ScreenTools.defaultFontPixelWidth
                                        QGCLabel { text: "A"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                        QGCLabel { text:"0.01-1"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                        FactTextField { fact: _angRollAccel;unitsLabel:""; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
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
                                        QGCLabel { text: "3-12"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                        FactTextField { fact: _angPitchP; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                                    }
                                    RowLayout {
                                        spacing: ScreenTools.defaultFontPixelWidth
                                        QGCLabel { text: "A"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                        QGCLabel { text: "0.01-1"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                        FactTextField { fact: _angPitchAccel;unitsLabel:""; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
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
                                        QGCLabel { text: "3-12"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                        FactTextField { fact: _angYawP; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                                    }
                                    RowLayout {
                                        spacing: ScreenTools.defaultFontPixelWidth
                                        QGCLabel { text: "A"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                        QGCLabel { text: "0.01-1"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                        FactTextField { fact: _angYawAccel;unitsLabel:""; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                                    }
                                }
                            }
                        }
                    }

                    XFPIDTuning {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        availableWidth: width
                        availableHeight: height
                        title: qsTr("Attitude")
                        tuningMode: Vehicle.ModeDisabled
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
                    spacing: _margins * 2

                    Column {
                        Layout.fillWidth: true
                        spacing: _margins

                        QGCLabel {
                            text: qsTr("Velocity Controller")
                            font.bold: true
                            font.pointSize: ScreenTools.mediumFontPointSize
                        }

                        Rectangle {
                            width: parent.width
                            height: velocityParamsGrid.height + _margins * 2
                            color: qgcPal.windowShade
                            radius: ScreenTools.buttonBorderRadius

                            RowLayout {
                                id: velocityParamsGrid
                                anchors.margins: _margins
                                anchors.left: parent.left
                                anchors.top: parent.top
                                width: parent.width - _margins * 2
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
                                        QGCLabel { text: "0.1-6.0"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                        FactTextField { fact: _velXYP; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                                    }
                                    RowLayout {
                                        spacing: ScreenTools.defaultFontPixelWidth
                                        QGCLabel { text: "I"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                        QGCLabel { text: "0.01-1.0"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                        FactTextField { fact: _velXYI; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                                    }
                                    RowLayout {
                                        spacing: ScreenTools.defaultFontPixelWidth
                                        QGCLabel { text: "D"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                        QGCLabel { text: "0.001-0.1"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                        FactTextField { fact: _velXYD; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
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
                                        QGCLabel { text: "0.1-6.0"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                        FactTextField { fact: _velZP; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                                    }
                                    RowLayout {
                                        spacing: ScreenTools.defaultFontPixelWidth
                                        QGCLabel { text: "I"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                        QGCLabel { text: "0.01-1.0"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                        FactTextField { fact: _velZI; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                                    }
                                    RowLayout {
                                        spacing: ScreenTools.defaultFontPixelWidth
                                        QGCLabel { text: "D"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                        QGCLabel { text: "0.001-0.1"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                        FactTextField { fact: _velZD; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                                    }
                                }
                            }
                        }
                    }

                    XFPIDTuning {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        availableWidth: width
                        availableHeight: height
                        title: qsTr("Velocity")
                        tuningMode: Vehicle.ModeDisabled
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
                    spacing: _margins * 2

                    Column {
                        Layout.fillWidth: true
                        spacing: _margins

                        QGCLabel {
                            text: qsTr("Position Controller")
                            font.bold: true
                            font.pointSize: ScreenTools.mediumFontPointSize
                        }

                        Rectangle {
                            width: parent.width
                            height: positionParamsGrid.height + _margins * 2
                            color: qgcPal.windowShade
                            radius: ScreenTools.buttonBorderRadius

                            RowLayout {
                                id: positionParamsGrid
                                anchors.margins: _margins
                                anchors.left: parent.left
                                anchors.top: parent.top
                                width: parent.width - _margins * 2
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
                                        QGCLabel { text: "0.1-3.0"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                        FactTextField { fact: _posXYP; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                                    }
                                    RowLayout {
                                        spacing: ScreenTools.defaultFontPixelWidth
                                        QGCLabel { text: "TC"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                        QGCLabel { text: "0-1"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                        FactTextField { fact: _atcInputTC; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
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
                                        QGCLabel { text: "0.1-3.0"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7 }
                                        FactTextField { fact: _posZP; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                                    }
                                }
                            }
                        }
                    }

                    XFPIDTuning {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        availableWidth: width
                        availableHeight: height
                        title: qsTr("Position")
                        tuningMode: Vehicle.ModeDisabled
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
