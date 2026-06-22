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
import QGroundControl.Controls
import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.Palette
import QGroundControl.ScreenTools

ColumnLayout {
    spacing:            ScreenTools.defaultFontPixelHeight / 2
    anchors.margins:    ScreenTools.defaultFontPixelWidth

    QGCPalette { id: qgcPal }

    property var _appSettings: QGroundControl.settingsManager.appSettings
    property var _defaultAltitude: _appSettings ? _appSettings.defaultMissionItemAltitude : null
    property var _missionSettings: missionController && missionController.visualItems.count > 0 ? missionController.visualItems.get(0) : null

    RowLayout {
        QGCLabel { text: qsTr("Mission Name") }
        QGCTextField {
            Layout.fillWidth: true
            text: _missionSettings && _missionSettings.missionName ? _missionSettings.missionName : ""
            onTextChanged: {
                if (_missionSettings) {
                    try {
                        _missionSettings.missionName = text
                    } catch(e) {}
                }
            }
        }
    }

    RowLayout {
        QGCLabel { text: qsTr("Flight Altitude") }
        QGCTextField {
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
            text: _defaultAltitude ? _defaultAltitude.rawValue : "50"
            onEditingFinished: {
                if (_defaultAltitude) {
                    _defaultAltitude.rawValue = parseFloat(text)
                }
            }
        }
        QGCLabel { text: "m" }
        QGCButton {
            text: "-10"
            onClicked: {
                if (_defaultAltitude) {
                    _defaultAltitude.rawValue = Math.max(0, _defaultAltitude.rawValue - 10)
                }
            }
        }
        QGCButton {
            text: "+10"
            onClicked: {
                if (_defaultAltitude) {
                    _defaultAltitude.rawValue = _defaultAltitude.rawValue + 10
                }
            }
        }
    }

    RowLayout {
        QGCLabel { text: qsTr("Flight Speed") }
        QGCTextField {
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
            text: "10"
        }
        QGCLabel { text: "m/s" }
        QGCButton {
            text: "-1"
            onClicked: {
            }
        }
        QGCButton {
            text: "+1"
            onClicked: {
            }
        }
    }

    RowLayout {
        QGCLabel { text: qsTr("End Action") }
        QGCComboBox {
            model: [qsTr("RTL"), qsTr("Land"), qsTr("Hover")]
            currentIndex: 0
        }
    }

    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: qgcPal.windowShade
    }

    RowLayout {
        QGCLabel { text: qsTr("Total Distance") }
        QGCLabel {
            text: missionController ? (missionController.missionTotalDistance / 1000).toFixed(2) + " km" : "0 km"
            font.bold: true
        }
    }

    RowLayout {
        QGCLabel { text: qsTr("Waypoints") }
        QGCLabel {
            text: missionController ? (missionController.visualItems.count - 1).toString() : "0"
            font.bold: true
        }
    }
}