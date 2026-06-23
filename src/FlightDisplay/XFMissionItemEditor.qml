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
                var cmd = missionItem.command
                for (var i = 0; i < _commandModel.length; i++) {
                    if (_commandModel[i].value == cmd) return i
                }
                return 0
            }
            onActivated: {
                if (missionItem && currentIndex >= 0) {
                    missionItem.command = _commandModel[currentIndex].value
                }
            }
        }
    }

    function getCoord() {
        if (!missionItem || !missionItem.coordinate) return QtPositioning.coordinate(0, 0, 0)
        var coord = missionItem.coordinate
        var lat = isNaN(coord.latitude) ? 0 : coord.latitude
        var lon = isNaN(coord.longitude) ? 0 : coord.longitude
        var alt = isNaN(coord.altitude) ? 0 : coord.altitude
        return QtPositioning.coordinate(lat, lon, alt)
    }

    function setCoord(lat, lon, alt) {
        if (!missionItem) return
        var c = getCoord()
        var newLat = !isNaN(lat) ? lat : c.latitude
        var newLon = !isNaN(lon) ? lon : c.longitude
        var newAlt = !isNaN(alt) ? alt : c.altitude
        missionItem.coordinate = QtPositioning.coordinate(newLat, newLon, newAlt)
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
            text: {
                var c = getCoord()
                return c.longitude.toFixed(7)
            }
            onEditingFinished: {
                setCoord(NaN, parseFloat(text), NaN)
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
            text: {
                var c = getCoord()
                return c.latitude.toFixed(7)
            }
            onEditingFinished: {
                setCoord(parseFloat(text), NaN, NaN)
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
            text: {
                var c = getCoord()
                return c.altitude.toFixed(1)
            }
            onEditingFinished: {
                setCoord(NaN, NaN, parseFloat(text))
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
                var c = getCoord()
                setCoord(NaN, NaN, c.altitude - 10)
            }
        }
        QGCButton {
            text: "+10"
            _horizontalPadding: 0
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
            onClicked: {
                var c = getCoord()
                setCoord(NaN, NaN, c.altitude + 10)
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
            text: {
                if (_speed && _speed.specifyFlightSpeed && _speed.flightSpeed) {
                    var v = _speed.flightSpeed.rawValue
                    return isNaN(v) ? "0" : v.toFixed(1)
                }
                return "0"
            }
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
                if (_speed) {
                    _speed.specifyFlightSpeed = true
                    if (!_speed.flightSpeed) return
                    var v = _speed.flightSpeed.rawValue
                    var cur = isNaN(v) ? 0 : v
                    _speed.flightSpeed.rawValue = Math.max(0, cur - 1)
                }
            }
        }
        QGCButton {
            text: "+1"
            _horizontalPadding: 0
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
            onClicked: {
                if (_speed) {
                    _speed.specifyFlightSpeed = true
                    if (!_speed.flightSpeed) return
                    var v = _speed.flightSpeed.rawValue
                    var cur = isNaN(v) ? 0 : v
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
                if (!_camera) return 0
                var rawVal = _camera.cameraAction.rawValue
                for (var i = 0; i < _cameraActionModel.length; i++) {
                    if (_cameraActionModel[i].value == rawVal) return i
                }
                return 0
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
            text: {
                if (_camera && _camera.gimbalPitch) {
                    var v = _camera.gimbalPitch.rawValue
                    return isNaN(v) ? "0" : v.toFixed(0)
                }
                return "0"
            }
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
                    var v = _camera.gimbalPitch.rawValue
                    var cur = isNaN(v) ? 0 : v
                    _camera.gimbalPitch.rawValue = Math.max(-90, cur - 10)
                }
            }
        }
        QGCButton {
            text: "+10"
            _horizontalPadding: 0
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
            onClicked: {
                if (_camera && _camera.gimbalPitch) {
                    var v = _camera.gimbalPitch.rawValue
                    var cur = isNaN(v) ? 0 : v
                    _camera.gimbalPitch.rawValue = Math.min(0, cur + 10)
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
            text: {
                if (_camera && _camera.gimbalYaw) {
                    var v = _camera.gimbalYaw.rawValue
                    return isNaN(v) ? "0" : v.toFixed(0)
                }
                return "0"
            }
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
                    var v = _camera.gimbalYaw.rawValue
                    var cur = isNaN(v) ? 0 : v
                    _camera.gimbalYaw.rawValue = Math.max(-180, cur - 10)
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
