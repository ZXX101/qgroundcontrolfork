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
import QtPositioning

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.Palette
import QGroundControl.ScreenTools

ColumnLayout {
    id: rootLayout

    QGCPalette { id: qgcPal }

    property var missionItem
    property var _camera: missionItem ? missionItem.cameraSection : null
    property var _speed: missionItem ? missionItem.speedSection : null

    property var _commandModel: [
        { text: qsTr("Waypoint"),  value: 16 },
        { text: qsTr("Land"),      value: 21 },
        { text: qsTr("Takeoff"),   value: 22 },
        { text: qsTr("RTL"),       value: 20 }
    ]

    property var _cameraActionModel: [
        { text: qsTr("No change"),            value: 0 },
        { text: qsTr("Take photo"),           value: 6 },
        { text: qsTr("Start recording video"), value: 4 },
        { text: qsTr("Stop recording video"),  value: 5 }
    ]

    RowLayout {
        Layout.fillWidth: true

        QGCLabel {
            text: qsTr("Command")
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
        }
        QGCComboBox {
            id: commandCombo
            model: _commandModel
            textRole: "text"
            Layout.fillWidth: true
            currentIndex: {
                if (!missionItem) return -1
                for (var i = 0; i < _commandModel.length; i++) {
                    if (_commandModel[i].value === missionItem.command) return i
                }
                return -1
            }
            onActivated: {
                if (missionItem && currentIndex >= 0) {
                    missionItem.command = _commandModel[currentIndex].value
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true

        QGCLabel {
            text: qsTr("Longitude")
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
        }
        QGCTextField {
            id: lonField
            Layout.fillWidth: true
            text: (missionItem && missionItem.coordinate && !isNaN(missionItem.coordinate.longitude))
                  ? missionItem.coordinate.longitude.toFixed(7) : ""
            onEditingFinished: {
                if (missionItem) {
                    var val = parseFloat(text)
                    if (!isNaN(val)) {
                        var coord = QtPositioning.coordinate(missionItem.coordinate.latitude, val, missionItem.coordinate.altitude)
                        missionItem.coordinate = coord
                    }
                }
            }
        }
        QGCLabel {
            text: "°"
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2
        }
    }

    RowLayout {
        Layout.fillWidth: true

        QGCLabel {
            text: qsTr("Latitude")
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
        }
        QGCTextField {
            id: latField
            Layout.fillWidth: true
            text: (missionItem && missionItem.coordinate && !isNaN(missionItem.coordinate.latitude))
                  ? missionItem.coordinate.latitude.toFixed(7) : ""
            onEditingFinished: {
                if (missionItem) {
                    var val = parseFloat(text)
                    if (!isNaN(val)) {
                        var coord = QtPositioning.coordinate(val, missionItem.coordinate.longitude, missionItem.coordinate.altitude)
                        missionItem.coordinate = coord
                    }
                }
            }
        }
        QGCLabel {
            text: "°"
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2
        }
    }

    RowLayout {
        Layout.fillWidth: true

        QGCLabel {
            text: qsTr("Altitude")
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
        }
        QGCTextField {
            id: altField
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
            text: (missionItem && missionItem.coordinate && !isNaN(missionItem.coordinate.altitude))
                  ? missionItem.coordinate.altitude.toFixed(1) : "0"
            onEditingFinished: {
                if (missionItem) {
                    var val = parseFloat(text)
                    if (!isNaN(val)) {
                        var coord = QtPositioning.coordinate(missionItem.coordinate.latitude, missionItem.coordinate.longitude, val)
                        missionItem.coordinate = coord
                    }
                }
            }
        }
        QGCLabel {
            text: "m"
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
        }
        QGCButton {
            text: "-10"
            _horizontalPadding: 0
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
            onClicked: {
                if (missionItem && !isNaN(missionItem.coordinate.altitude)) {
                    var coord = QtPositioning.coordinate(
                        missionItem.coordinate.latitude,
                        missionItem.coordinate.longitude,
                        missionItem.coordinate.altitude - 10)
                    missionItem.coordinate = coord
                }
            }
        }
        QGCButton {
            text: "+10"
            _horizontalPadding: 0
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
            onClicked: {
                if (missionItem && !isNaN(missionItem.coordinate.altitude)) {
                    var coord = QtPositioning.coordinate(
                        missionItem.coordinate.latitude,
                        missionItem.coordinate.longitude,
                        missionItem.coordinate.altitude + 10)
                    missionItem.coordinate = coord
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true

        QGCLabel {
            text: qsTr("Speed")
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
        }
        QGCTextField {
            id: speedField
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
            text: (_speed && _speed.specifyFlightSpeed && _speed.flightSpeed && !isNaN(_speed.flightSpeed.rawValue))
                  ? _speed.flightSpeed.rawValue.toFixed(1) : "--"
            onEditingFinished: {
                if (_speed) {
                    var val = parseFloat(text)
                    if (!isNaN(val)) {
                        _speed.specifyFlightSpeed = true
                        _speed.flightSpeed.rawValue = val
                    }
                }
            }
        }
        QGCLabel {
            text: "m/s"
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
        }
        QGCButton {
            text: "-1"
            _horizontalPadding: 0
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
            onClicked: {
                if (_speed && _speed.specifyFlightSpeed && !isNaN(_speed.flightSpeed.rawValue)) {
                    _speed.flightSpeed.rawValue = Math.max(0, _speed.flightSpeed.rawValue - 1)
                }
            }
        }
        QGCButton {
            text: "+1"
            _horizontalPadding: 0
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
            onClicked: {
                if (_speed && _speed.specifyFlightSpeed) {
                    var cur = isNaN(_speed.flightSpeed.rawValue) ? 0 : _speed.flightSpeed.rawValue
                    _speed.flightSpeed.rawValue = cur + 1
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true

        QGCLabel {
            text: qsTr("Camera Action")
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
        }
        QGCComboBox {
            id: cameraActionCombo
            model: _cameraActionModel
            textRole: "text"
            Layout.fillWidth: true
            currentIndex: {
                if (!_camera) return -1
                var rawVal = _camera.cameraAction.rawValue
                for (var i = 0; i < _cameraActionModel.length; i++) {
                    if (_cameraActionModel[i].value === rawVal) return i
                }
                return -1
            }
            onActivated: {
                if (_camera && currentIndex >= 0) {
                    _camera.cameraAction.rawValue = _cameraActionModel[currentIndex].value
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true

        QGCLabel {
            text: qsTr("Gimbal")
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
        }
        QGCCheckBoxSlider {
            id: gimbalCheckBox
            checked: _camera ? _camera.specifyGimbal : false
            onClicked: {
                if (_camera) {
                    _camera.specifyGimbal = checked
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: gimbalCheckBox.checked

        QGCLabel {
            text: qsTr("Pitch")
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
        }
        QGCTextField {
            id: gimbalPitchField
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
            text: (_camera && _camera.gimbalPitch && !isNaN(_camera.gimbalPitch.rawValue))
                  ? _camera.gimbalPitch.rawValue.toFixed(0) : "0"
            onEditingFinished: {
                if (_camera && _camera.gimbalPitch) {
                    var val = parseFloat(text)
                    if (!isNaN(val)) {
                        _camera.gimbalPitch.rawValue = Math.max(-90, Math.min(0, val))
                    }
                }
            }
        }
        QGCLabel {
            text: "°"
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2
        }
        QGCButton {
            text: "-10"
            _horizontalPadding: 0
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
            onClicked: {
                if (_camera && _camera.gimbalPitch) {
                    _camera.gimbalPitch.rawValue = Math.max(-90, _camera.gimbalPitch.rawValue - 10)
                }
            }
        }
        QGCButton {
            text: "+10"
            _horizontalPadding: 0
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
            onClicked: {
                if (_camera && _camera.gimbalPitch) {
                    _camera.gimbalPitch.rawValue = Math.min(0, _camera.gimbalPitch.rawValue + 10)
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: gimbalCheckBox.checked

        QGCLabel {
            text: qsTr("Yaw")
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
        }
        QGCTextField {
            id: gimbalYawField
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
            text: (_camera && _camera.gimbalYaw && !isNaN(_camera.gimbalYaw.rawValue))
                  ? _camera.gimbalYaw.rawValue.toFixed(0) : "0"
            onEditingFinished: {
                if (_camera && _camera.gimbalYaw) {
                    var val = parseFloat(text)
                    if (!isNaN(val)) {
                        _camera.gimbalYaw.rawValue = Math.max(-180, Math.min(180, val))
                    }
                }
            }
        }
        QGCLabel {
            text: "°"
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2
        }
        QGCButton {
            text: "-10"
            _horizontalPadding: 0
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
            onClicked: {
                if (_camera && _camera.gimbalYaw) {
                    _camera.gimbalYaw.rawValue = Math.max(-180, _camera.gimbalYaw.rawValue - 10)
                }
            }
        }
        QGCButton {
            text: "+10"
            _horizontalPadding: 0
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
            onClicked: {
                if (_camera && _camera.gimbalYaw) {
                    _camera.gimbalYaw.rawValue = Math.min(180, _camera.gimbalYaw.rawValue + 10)
                }
            }
        }
    }

    Item {
        Layout.fillHeight: true
    }
}
