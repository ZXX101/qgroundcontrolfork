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
            anchors.fill: parent
            spacing: ScreenTools.defaultFontPixelHeight

            TabBar {
                id: tabBar
                Layout.fillWidth: true
                spacing: 0
                background: Rectangle {
                    color: "transparent"
                }

                TabButton {
                    text: qsTr("速率")
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
                    text: qsTr("姿态")
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
                    text: qsTr("速度")
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
                    text: qsTr("位置")
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
                        spacing: ScreenTools.defaultFontPixelWidth * 4

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: ScreenTools.defaultFontPixelHeight * 0.5

                            QGCLabel {
                                text: qsTr("横滚(Roll)")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "P"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.3-3"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5 }
                                QGCTextField { placeholderText: "0.0"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                            }
                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "I"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.3-3"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5 }
                                QGCTextField { placeholderText: "0.0"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                            }
                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "D"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.3-3"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5 }
                                QGCTextField { placeholderText: "0.0"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: ScreenTools.defaultFontPixelHeight * 0.5

                            QGCLabel {
                                text: qsTr("俯仰(Pitch)")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "P"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.3-3"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5 }
                                QGCTextField { placeholderText: "0.0"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                            }
                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "I"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.3-3"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5 }
                                QGCTextField { placeholderText: "0.0"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                            }
                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "D"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.3-3"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5 }
                                QGCTextField { placeholderText: "0.0"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: ScreenTools.defaultFontPixelHeight * 0.5

                            QGCLabel {
                                text: qsTr("偏航(Yaw)")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "P"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.3-3"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5 }
                                QGCTextField { placeholderText: "0.0"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                            }
                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "I"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.3-3"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5 }
                                QGCTextField { placeholderText: "0.0"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                            }
                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "D"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.3-3"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5 }
                                QGCTextField { placeholderText: "0.0"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                            }
                        }
                    }

                    XFPIDTuning {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        availableWidth: width
                        availableHeight: height
                        title: qsTr("速率")
                        tuningMode: Vehicle.ModeDisabled
                        unit: qsTr("deg/s")
                        chartDisplaySec: 3

                        property var roll: QtObject {
                            property string name: qsTr("横滚")
                            property var plot: [
                                { name: "Response", value: globals.activeVehicle && globals.activeVehicle.rollRate ? globals.activeVehicle.rollRate.value : NaN },
                                { name: "Setpoint", value: globals.activeVehicle && globals.activeVehicle.setpoint ? globals.activeVehicle.setpoint.rollRate.value : NaN }
                            ]
                        }
                        property var pitch: QtObject {
                            property string name: qsTr("俯仰")
                            property var plot: [
                                { name: "Response", value: globals.activeVehicle && globals.activeVehicle.pitchRate ? globals.activeVehicle.pitchRate.value : NaN },
                                { name: "Setpoint", value: globals.activeVehicle && globals.activeVehicle.setpoint ? globals.activeVehicle.setpoint.pitchRate.value : NaN }
                            ]
                        }
                        property var yaw: QtObject {
                            property string name: qsTr("偏航")
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
                                text: qsTr("横滚(Roll)")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "P"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.3-3"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5 }
                                QGCTextField { placeholderText: "0.0"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                            }
                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "I"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.3-3"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5 }
                                QGCTextField { placeholderText: "0.0"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                            }
                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "D"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.3-3"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5 }
                                QGCTextField { placeholderText: "0.0"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: ScreenTools.defaultFontPixelHeight * 0.5

                            QGCLabel {
                                text: qsTr("俯仰(Pitch)")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "P"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.3-3"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5 }
                                QGCTextField { placeholderText: "0.0"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                            }
                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "I"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.3-3"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5 }
                                QGCTextField { placeholderText: "0.0"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                            }
                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "D"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.3-3"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5 }
                                QGCTextField { placeholderText: "0.0"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: ScreenTools.defaultFontPixelHeight * 0.5

                            QGCLabel {
                                text: qsTr("偏航(Yaw)")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "P"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.3-3"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5 }
                                QGCTextField { placeholderText: "0.0"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                            }
                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "I"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.3-3"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5 }
                                QGCTextField { placeholderText: "0.0"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                            }
                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "D"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                QGCLabel { text: "0.3-3"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5 }
                                QGCTextField { placeholderText: "0.0"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Item { Layout.fillHeight: true }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Item { Layout.fillHeight: true }
                }
            }
        }
    }
}
