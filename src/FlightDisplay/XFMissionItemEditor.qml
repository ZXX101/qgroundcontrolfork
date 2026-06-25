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

Item {
    id: rootLayout

    QGCPalette {
        id: qgcPal
    }

    property var missionItem
    property var _camera: missionItem ? missionItem.cameraSection : null
    property var _speed: missionItem ? missionItem.speedSection : null

    property var _commandModel: [
        {
            text: qsTr("Waypoint"),
            value: 16
        },
        {
            text: qsTr("Land"),
            value: 21
        },
        {
            text: qsTr("Takeoff"),
            value: 22
        },
        {
            text: qsTr("RTL"),
            value: 20
        }
    ]

    property var _cameraActionModel: [
        {
            text: qsTr("No change"),
            value: 0
        },
        {
            text: qsTr("Take photo"),
            value: 6
        },
        {
            text: qsTr("Start recording video"),
            value: 4
        },
        {
            text: qsTr("Stop recording video"),
            value: 5
        }
    ]

    function getCoord() {
        if (!missionItem || !missionItem.coordinate) {
            return QtPositioning.coordinate(0, 0, 0);
        }
        var coord = missionItem.coordinate;
        var lat = isNaN(coord.latitude) ? 0 : coord.latitude;
        var lon = isNaN(coord.longitude) ? 0 : coord.longitude;
        var alt = isNaN(coord.altitude) ? missionItem.altitude.rawValue : coord.altitude;
        if (isNaN(alt)) {
            alt = 0;
        }
        return QtPositioning.coordinate(lat, lon, alt);
    }

    function setCoord(lat, lon, alt) {
        if (!missionItem)
            return;
        var currentCoord = missionItem.coordinate;
        var currentAlt = missionItem.altitude ? missionItem.altitude.rawValue : 0;
        if (isNaN(currentAlt)) currentAlt = 0;

        var newLat = !isNaN(lat) ? lat : (isNaN(currentCoord.latitude) ? 0 : currentCoord.latitude);
        var newLon = !isNaN(lon) ? lon : (isNaN(currentCoord.longitude) ? 0 : currentCoord.longitude);
        var newAlt = !isNaN(alt) ? alt : currentAlt;

        missionItem.coordinate = QtPositioning.coordinate(newLat, newLon, newAlt);
        missionItem.altitude.rawValue = newAlt;
    }

    function getSpeed() {
        if (!_speed || !_speed.specifyFlightSpeed || !_speed.flightSpeed) {
            return 5.0;
        }
        var v = _speed.flightSpeed.rawValue;
        return isNaN(v) ? 5.0 : v;
    }

    function getSpeedEnabled() {
        return _speed ? _speed.specifyFlightSpeed : false;
    }

    function setSpeedEnabled(enabled) {
        if (_speed) {
            _speed.specifyFlightSpeed = enabled;
        }
    }

    function setSpeedValue(val) {
        if (_speed && _speed.flightSpeed) {
            _speed.flightSpeed.rawValue = val;
        }
    }

    QGCFlickable {
        anchors.fill: parent
        clip: true
        flickableDirection: Flickable.VerticalFlick
        contentHeight: contentColumn.height

        ColumnLayout {
            id: contentColumn
            width: parent.width
            spacing: ScreenTools.defaultFontPixelHeight / 2

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
                        if (!missionItem)
                            return -1;
                        var cmd = missionItem.command;
                        for (var i = 0; i < _commandModel.length; i++) {
                            if (_commandModel[i].value == cmd)
                                return i;
                        }
                        return 0;
                    }
                    onActivated: {
                        if (missionItem && currentIndex >= 0) {
                            missionItem.command = _commandModel[currentIndex].value;
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
                    text: missionItem && missionItem.coordinate && !isNaN(missionItem.coordinate.longitude) ? missionItem.coordinate.longitude.toFixed(7) : "0"
                    onEditingFinished: {
                        var val = parseFloat(text);
                        if (!isNaN(val) && missionItem && missionItem.coordinate) {
                            var coord = missionItem.coordinate;
                            missionItem.coordinate = QtPositioning.coordinate(
                                isNaN(coord.latitude) ? 0 : coord.latitude,
                                val,
                                isNaN(coord.altitude) ? 0 : coord.altitude);
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
                    text: missionItem && missionItem.coordinate && !isNaN(missionItem.coordinate.latitude) ? missionItem.coordinate.latitude.toFixed(7) : "0"
                    onEditingFinished: {
                        var val = parseFloat(text);
                        if (!isNaN(val) && missionItem && missionItem.coordinate) {
                            var coord = missionItem.coordinate;
                            missionItem.coordinate = QtPositioning.coordinate(
                                val,
                                isNaN(coord.longitude) ? 0 : coord.longitude,
                                isNaN(coord.altitude) ? 0 : coord.altitude);
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
                FactTextField {
                    id: altField
                    fact: missionItem ? missionItem.altitude : null
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                }
                QGCButton {
                    text: "-10"
                    _horizontalPadding: 0
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
                    onClicked: {
                        var c = getCoord();
                        setCoord(NaN, NaN, c.altitude - 10);
                    }
                }
                QGCButton {
                    text: "+10"
                    _horizontalPadding: 0
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
                    onClicked: {
                        var c = getCoord();
                        setCoord(NaN, NaN, c.altitude + 10);
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                QGCCheckBox {
                    id: speedCheckBox
                    checked: _speed ? _speed.specifyFlightSpeed : false
                    onClicked: {
                        if (_speed) {
                            _speed.specifyFlightSpeed = checked;
                        }
                    }
                    visible: _speed ? _speed.available : false
                }
                QGCLabel {
                    text: qsTr("Speed")
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                }
                FactTextField {
                    id: speedField
                    fact: _speed ? _speed.flightSpeed : null
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                    enabled: speedCheckBox.checked
                }
                QGCButton {
                    text: "-1"
                    _horizontalPadding: 0
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
                    enabled: speedCheckBox.checked
                    onClicked: {
                        if (_speed && _speed.flightSpeed) {
                            _speed.specifyFlightSpeed = true;
                            var v = _speed.flightSpeed.rawValue;
                            var cur = isNaN(v) ? 0 : v;
                            _speed.flightSpeed.rawValue = Math.max(0, cur - 1);
                        }
                    }
                }
                QGCButton {
                    text: "+1"
                    _horizontalPadding: 0
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
                    enabled: speedCheckBox.checked
                    onClicked: {
                        if (_speed && _speed.flightSpeed) {
                            _speed.specifyFlightSpeed = true;
                            var v = _speed.flightSpeed.rawValue;
                            var cur = isNaN(v) ? 0 : v;
                            _speed.flightSpeed.rawValue = cur + 1;
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
                        if (!_camera)
                            return 0;
                        var rawVal = _camera.cameraAction.rawValue;
                        for (var i = 0; i < _cameraActionModel.length; i++) {
                            if (_cameraActionModel[i].value == rawVal)
                                return i;
                        }
                        return 0;
                    }
                    onActivated: {
                        if (_camera && currentIndex >= 0) {
                            _camera.cameraAction.rawValue = _cameraActionModel[currentIndex].value;
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
                            _camera.specifyGimbal = checked;
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
                FactTextField {
                    id: gimbalPitchField
                    fact: _camera ? _camera.gimbalPitch : null
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
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
                            var v = _camera.gimbalPitch.rawValue;
                            var cur = isNaN(v) ? 0 : v;
                            _camera.gimbalPitch.rawValue = Math.max(-90, cur - 10);
                        }
                    }
                }
                QGCButton {
                    text: "+10"
                    _horizontalPadding: 0
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
                    onClicked: {
                        if (_camera && _camera.gimbalPitch) {
                            var v = _camera.gimbalPitch.rawValue;
                            var cur = isNaN(v) ? 0 : v;
                            _camera.gimbalPitch.rawValue = Math.min(0, cur + 10);
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
                FactTextField {
                    id: gimbalYawField
                    fact: _camera ? _camera.gimbalYaw : null
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
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
                            var v = _camera.gimbalYaw.rawValue;
                            var cur = isNaN(v) ? 0 : v;
                            _camera.gimbalYaw.rawValue = Math.max(-180, cur - 10);
                        }
                    }
                }
                QGCButton {
                    text: "+10"
                    _horizontalPadding: 0
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
                    onClicked: {
                        if (_camera && _camera.gimbalYaw) {
                            _camera.gimbalYaw.rawValue = Math.min(180, _camera.gimbalYaw.rawValue + 10);
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
