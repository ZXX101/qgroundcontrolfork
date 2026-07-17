/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.MultiVehicleManager
import QGroundControl.ScreenTools
import QGroundControl.Palette
import QGroundControl.FactSystem
import QGroundControl.FactControls

// This indicator page is used both when showing RTK status only with no vehicle connect and when showing GPS/RTK status with a vehicle connected

ToolIndicatorPage {
    showExpand: true

    property var    activeVehicle:      QGroundControl.multiVehicleManager.activeVehicle
    property string na:                 qsTr("N/A", "No data to display")
    property string valueNA:            qsTr("--.--", "No data to display")
    property var    rtkSettings:        QGroundControl.settingsManager.rtkSettings
    property bool   useFixedPosition:   rtkSettings.useFixedBasePosition.rawValue

    contentComponent: Component {
        ColumnLayout {
            spacing: ScreenTools.defaultFontPixelHeight / 2

            SettingsGroupLayout {
                heading: qsTr("Vehicle GPS Status")
                visible: activeVehicle

                LabelledLabel {
                    label:      qsTr("Satellites")
                    labelText:  activeVehicle ? activeVehicle.gps.count.valueString : na
                }

                LabelledLabel {
                    label:      qsTr("GPS Lock")
                    labelText:  activeVehicle ? activeVehicle.gps.lock.enumStringValue : na
                }

                LabelledLabel {
                    label:      qsTr("HDOP")
                    labelText:  activeVehicle ? activeVehicle.gps.hdop.valueString : valueNA
                }

                LabelledLabel {
                    label:      qsTr("VDOP")
                    labelText:  activeVehicle ? activeVehicle.gps.vdop.valueString : valueNA
                }

                LabelledLabel {
                    label:      qsTr("Course Over Ground")
                    labelText:  activeVehicle ? activeVehicle.gps.courseOverGround.valueString : valueNA
                }
            }

            SettingsGroupLayout {
                heading:    qsTr("RTK GPS Status")
                visible:    QGroundControl.gpsRtk.connected.value || QGroundControl.gpsRtk.ntripConnected.value

                QGCLabel {
                    text: (QGroundControl.gpsRtk.active.value) ? qsTr("Survey-in Active") : qsTr("RTK Streaming")
                }

                LabelledLabel {
                    label:      qsTr("Satellites")
                    labelText:  QGroundControl.gpsRtk.numSatellites.value
                }

                LabelledLabel {
                    label:      qsTr("Duration")
                    labelText:  QGroundControl.gpsRtk.currentDuration.value + ' s'
                }

                LabelledLabel {
                    label:      QGroundControl.gpsRtk.valid.value ? qsTr("Accuracy") : qsTr("Current Accuracy")
                    labelText:  QGroundControl.gpsRtk.currentAccuracy.valueString + " " + QGroundControl.unitsConversion.appSettingsHorizontalDistanceUnitsString
                    visible:    QGroundControl.gpsRtk.currentAccuracy.value > 0
                }
            }
        }
    }

    expandedComponent: Component {
        SettingsGroupLayout {
            heading:        qsTr("RTK GPS Settings")

            property real sliderWidth: ScreenTools.defaultFontPixelWidth * 40

            QGCPalette { id: qgcPal }

            SettingsGroupLayout {
                heading: qsTr("NTRIP Network RTK")

                FactCheckBoxSlider {
                    Layout.fillWidth:   true
                    text:               qsTr("Enable NTRIP")
                    fact:               rtkSettings.ntripEnabled
                    visible:            fact.visible
                }

                LabelledFactTextField {
                    label:              qsTr("Server URL")
                    fact:               rtkSettings.ntripURL
                    visible:            rtkSettings.ntripEnabled.rawValue && fact.visible
                }

                QGCLabel {
                    text:               qsTr("Format: ntrip://user:pass@host:port/mountpoint")
                    font.pointSize:     ScreenTools.smallFontPointSize
                    visible:            rtkSettings.ntripEnabled.rawValue
                    Layout.fillWidth:   true
                    wrapMode:           Text.WordWrap
                }

                FactCheckBoxSlider {
                    Layout.fillWidth:   true
                    text:               qsTr("Send GGA Position (VRS)")
                    fact:               rtkSettings.ntripSendGGA
                    visible:            rtkSettings.ntripEnabled.rawValue && fact.visible
                }

                FactCheckBoxSlider {
                    Layout.fillWidth:   true
                    text:               qsTr("Use NTRIP v1 Protocol")
                    fact:               rtkSettings.ntripV1
                    visible:            rtkSettings.ntripEnabled.rawValue && fact.visible
                }

                RowLayout {
                    visible:            rtkSettings.ntripEnabled.rawValue
                    Layout.fillWidth:   true

                    QGCLabel {
                        text:           qsTr("Status:")
                    }

                    QGCLabel {
                        text:           QGroundControl.gpsRtk.ntripConnected.value
                                        ? qsTr("● Connected")
                                        : qsTr("○ Disconnected")
                        color:          QGroundControl.gpsRtk.ntripConnected.value
                                        ? qgcPal.colorGreen
                                        : qgcPal.colorRed
                    }
                }
            }

            FactCheckBoxSlider {
                Layout.fillWidth:   true
                text:               qsTr("AutoConnect")
                fact:               QGroundControl.settingsManager.autoConnectSettings.autoConnectRTKGPS
                visible:            fact.visible
            }

            RowLayout {
                visible: rtkSettings.useFixedBasePosition.visible

                QGCRadioButton {
                    text:       qsTr("Survey-In")
                    checked:    !useFixedPosition
                    onClicked:  rtkSettings.useFixedBasePosition.rawValue = false
                }

                QGCRadioButton {
                    text: qsTr("Specify position")
                    checked:    useFixedPosition
                    onClicked:  rtkSettings.useFixedBasePosition.rawValue = true
                }
            }

            FactSlider {
                Layout.fillWidth:       true
                Layout.preferredWidth:  sliderWidth
                label:                  qsTr("Accuracy (u-blox only)")
                fact:                   QGroundControl.settingsManager.rtkSettings.surveyInAccuracyLimit
                majorTickStepSize:      0.1
                visible:                !useFixedPosition && rtkSettings.surveyInAccuracyLimit.visible
            }

            FactSlider {
                Layout.fillWidth:       true
                Layout.preferredWidth:  sliderWidth
                label:                  qsTr("Min Duration")
                fact:                   rtkSettings.surveyInMinObservationDuration
                majorTickStepSize:      10
                visible:                !useFixedPosition && rtkSettings.surveyInMinObservationDuration.visible
            }

            LabelledFactTextField {
                label:                  rtkSettings.fixedBasePositionLatitude.shortDescription
                fact:                   rtkSettings.fixedBasePositionLatitude
                visible:                useFixedPosition && rtkSettings.fixedBasePositionLatitude.visible
            }

            LabelledFactTextField {
                label:              rtkSettings.fixedBasePositionLongitude.shortDescription
                fact:               rtkSettings.fixedBasePositionLongitude
                visible:            useFixedPosition && rtkSettings.fixedBasePositionLongitude.visible
            }

            LabelledFactTextField {
                label:              rtkSettings.fixedBasePositionAltitude.shortDescription
                fact:               rtkSettings.fixedBasePositionAltitude
                visible:            useFixedPosition && rtkSettings.fixedBasePositionAltitude.visible
            }

            LabelledFactTextField {
                label:              rtkSettings.fixedBasePositionAccuracy.shortDescription
                fact:               rtkSettings.fixedBasePositionAccuracy
                visible:            useFixedPosition && rtkSettings.fixedBasePositionAccuracy.visible
            }

            LabelledButton {
                label:              qsTr("Current Base Position")
                buttonText:         enabled ? qsTr("Save") : qsTr("Not Yet Valid")
                visible:            useFixedPosition
                enabled:            QGroundControl.gpsRtk.valid.value

                onClicked: {
                    rtkSettings.fixedBasePositionLatitude.rawValue  = QGroundControl.gpsRtk.currentLatitude.rawValue
                    rtkSettings.fixedBasePositionLongitude.rawValue = QGroundControl.gpsRtk.currentLongitude.rawValue
                    rtkSettings.fixedBasePositionAltitude.rawValue  = QGroundControl.gpsRtk.currentAltitude.rawValue
                    rtkSettings.fixedBasePositionAccuracy.rawValue  = QGroundControl.gpsRtk.currentAccuracy.rawValue
                }
            }
        }
    }
}
