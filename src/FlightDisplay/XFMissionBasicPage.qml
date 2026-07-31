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

Item {
    id: rootLayout

    Rectangle {
        anchors.fill: parent
        color: "#101010"
    }

    QGCPalette {
        id: qgcPal
    }

    property var _appSettings: QGroundControl.settingsManager.appSettings
    property var _defaultAltitude: _appSettings ? _appSettings.defaultMissionItemAltitude : null
    property var _missionSettings: missionController && missionController.visualItems.count > 0 ? missionController.visualItems.get(0) : null
    property bool _updatingFlightSpeedText: false
    property string missionName: "Mission"
    property var geoFenceController: null
    property var flightMap: null
    property int editingFenceIndex: -1
    property int editingFenceType: -1
    property bool fenceEnabled: _hasFences && editingFenceIndex >= 0

    property bool _hasFences: geoFenceController && (geoFenceController.polygons.count > 0 || geoFenceController.circles.count > 0)

    property real _missionPlannedDistance: missionController ? missionController.missionPlannedDistance : NaN
    property real _missionMaxTelemetry: missionController ? missionController.missionMaxTelemetry : NaN
    property real _missionTime: missionController ? missionController.missionTime : 0

    property string _missionPlannedDistanceText: isNaN(_missionPlannedDistance) ? "-.-" : QGroundControl.unitsConversion.metersToAppSettingsHorizontalDistanceUnits(_missionPlannedDistance).toFixed(0) + " " + QGroundControl.unitsConversion.appSettingsHorizontalDistanceUnitsString
    property string _missionMaxTelemetryText: isNaN(_missionMaxTelemetry) ? "-.-" : QGroundControl.unitsConversion.metersToAppSettingsHorizontalDistanceUnits(_missionMaxTelemetry).toFixed(0) + " " + QGroundControl.unitsConversion.appSettingsHorizontalDistanceUnitsString

    function _syncFlightSpeedText() {
        if (!missionController || !flightSpeedField)
            return;
        var speed = missionController.basicFlightSpeed;
        if (!isNaN(speed) && speed > 0) {
            _updatingFlightSpeedText = true;
            flightSpeedField.text = Number(speed).toFixed(1);
            _updatingFlightSpeedText = false;
        }
    }

    Component.onCompleted: {
        if (missionController) {
            missionController.ensureBasicFlightSpeedItem();
            _syncFlightSpeedText();
        }
    }

    Connections {
        target: missionController

        function onBasicFlightSpeedChanged() {
            _syncFlightSpeedText();
        }
    }

    function _getMissionTime() {
        if (!_missionTime)
            return "00:00:00";
        var t = new Date(2021, 0, 0, 0, 0, Number(_missionTime));
        var days = Qt.formatDateTime(t, 'dd');
        if (days == 31) {
            days = '0';
            return Qt.formatTime(t, 'hh:mm:ss');
        } else {
            return days + " days " + Qt.formatTime(t, 'hh:mm:ss');
        }
    }

    function _selectFenceForEdit(index, type) {
        if (editingFenceIndex === index && editingFenceType === type) {
            editingFenceIndex = -1;
            editingFenceType = -1;
            if (geoFenceController)
                geoFenceController.clearAllInteractive();
        } else {
            editingFenceIndex = index;
            editingFenceType = type;
            if (geoFenceController)
                geoFenceController.clearAllInteractive();
            if (type === 0 && geoFenceController && index < geoFenceController.polygons.count) {
                geoFenceController.polygons.get(index).interactive = true;
            } else if (type === 1 && geoFenceController && index < geoFenceController.circles.count) {
                geoFenceController.circles.get(index).interactive = true;
            }
        }
    }

    on_HasFencesChanged: {
        if (!_hasFences) {
            editingFenceIndex = -1;
            editingFenceType = -1;
        }
    }

    function _addFencePolygon() {
        if (!geoFenceController || !flightMap)
            return;
        var topLeftCoord, bottomRightCoord;
        if (flightMap.centerViewport) {
            var rect = Qt.rect(flightMap.centerViewport.x, flightMap.centerViewport.y, flightMap.centerViewport.width, flightMap.centerViewport.height);
            topLeftCoord = flightMap.toCoordinate(Qt.point(rect.x, rect.y), false);
            bottomRightCoord = flightMap.toCoordinate(Qt.point(rect.x + rect.width, rect.y + rect.height), false);
        } else {
            var center = flightMap.center;
            topLeftCoord = center.atDistanceAndAzimuth(1500, -45);
            bottomRightCoord = center.atDistanceAndAzimuth(1500, 135);
        }
        geoFenceController.addInclusionPolygon(topLeftCoord, bottomRightCoord);
        _selectFenceForEdit(geoFenceController.polygons.count - 1, 0);
    }

    function _addFenceCircle() {
        if (!geoFenceController || !flightMap)
            return;
        var topLeftCoord, bottomRightCoord;
        if (flightMap.centerViewport) {
            var rect = Qt.rect(flightMap.centerViewport.x, flightMap.centerViewport.y, flightMap.centerViewport.width, flightMap.centerViewport.height);
            topLeftCoord = flightMap.toCoordinate(Qt.point(rect.x, rect.y), false);
            bottomRightCoord = flightMap.toCoordinate(Qt.point(rect.x + rect.width, rect.y + rect.height), false);
        } else {
            var center = flightMap.center;
            topLeftCoord = center.atDistanceAndAzimuth(750, -45);
            bottomRightCoord = center.atDistanceAndAzimuth(750, 135);
        }
        geoFenceController.addInclusionCircle(topLeftCoord, bottomRightCoord);
        _selectFenceForEdit(geoFenceController.circles.count - 1, 1);
    }

    QGCFlickable {
        anchors.fill: parent
        anchors.margins: ScreenTools.defaultFontPixelWidth
        clip: true
        flickableDirection: Flickable.VerticalFlick
        contentHeight: contentColumn.height

        ColumnLayout {
            id: contentColumn
            width: parent.width - ScreenTools.minTouchPixels / 2
            spacing: ScreenTools.defaultFontPixelHeight / 2

            RowLayout {
                Layout.fillWidth: true

                QGCLabel {
                    text: qsTr("Mission Name")
                }
                Item {
                    Layout.fillWidth: true
                }
                QGCTextField {
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 16
                    text: missionName
                    onTextChanged: {
                        missionName = text;
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                QGCLabel {
                    text: qsTr("Flight Altitude")
                }
                Item {
                    Layout.fillWidth: true
                }
                QGCLabel {
                    text: "m"
                }
                QGCButton {
                    text: "-10"
                    _horizontalPadding: 0
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
                    onClicked: {
                        if (_defaultAltitude) {
                            _defaultAltitude.rawValue = Math.max(0, _defaultAltitude.rawValue - 10);
                        }
                    }
                }
                QGCButton {
                    text: "+10"
                    _horizontalPadding: 0
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
                    onClicked: {
                        if (_defaultAltitude) {
                            _defaultAltitude.rawValue = _defaultAltitude.rawValue + 10;
                        }
                    }
                }
                QGCTextField {
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                    text: _defaultAltitude ? _defaultAltitude.rawValue : "50"
                    horizontalAlignment: Text.AlignRight
                    onEditingFinished: {
                        if (_defaultAltitude) {
                            _defaultAltitude.rawValue = parseFloat(text);
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: true
                QGCCheckBox {
                    checked: missionController ? missionController.basicFlightSpeedEnabled : false
                    onClicked: {
                        if (missionController)
                            missionController.basicFlightSpeedEnabled = checked;
                    }
                }
                QGCLabel {
                    text: qsTr("Flight Speed")
                }
                Item {
                    Layout.fillWidth: true
                }
                QGCLabel {
                    text: "m/s"
                }
                QGCButton {
                    text: "-1"
                    _horizontalPadding: 0
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
                    enabled: missionController ? missionController.basicFlightSpeedEnabled : false
                    onClicked: {
                        if (missionController)
                            missionController.basicFlightSpeed = Math.max(0.1, missionController.basicFlightSpeed - 1);
                    }
                }
                QGCButton {
                    text: "+1"
                    _horizontalPadding: 0
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
                    enabled: missionController ? missionController.basicFlightSpeedEnabled : false
                    onClicked: {
                        if (missionController)
                            missionController.basicFlightSpeed = missionController.basicFlightSpeed + 1;
                    }
                }
                QGCTextField {
                    id: flightSpeedField
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                    text: "--"
                    enabled: missionController ? missionController.basicFlightSpeedEnabled : false
                    horizontalAlignment: Text.AlignRight
                    onEditingFinished: {
                        if (_updatingFlightSpeedText || !missionController)
                            return;
                        var speed = Number(text);
                        if (!isNaN(speed) && speed > 0)
                            missionController.basicFlightSpeed = speed;
                        _syncFlightSpeedText();
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                QGCLabel {
                    text: qsTr("End Action")
                }
                Item {
                    Layout.fillWidth: true
                }
                QGCComboBox {
                    model: [qsTr("RTL"), qsTr("Land"), qsTr("Hover")]
                    currentIndex: 0
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 12
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: qgcPal.windowShade
            }

            RowLayout {
                Layout.fillWidth: true

                QGCLabel {
                    text: qsTr("Insert Fence")
                    font.bold: true
                }
                Item {
                    Layout.fillWidth: true
                }

                QGCButton {
                    text: "+"
                    _horizontalPadding: 0
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
                    onClicked: addFenceMenu.popup()
                }

                QGCMenu {
                    id: addFenceMenu

                    QGCMenuItem {
                        text: qsTr("Polygon Fence")
                        onTriggered: _addFencePolygon()
                    }
                    QGCMenuItem {
                        text: qsTr("Circular Fence")
                        onTriggered: _addFenceCircle()
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: _hasFences
                spacing: ScreenTools.defaultFontPixelHeight / 4

                Repeater {
                    model: geoFenceController ? geoFenceController.polygons : null

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: fenceCardBg.height

                        property var fenceObject: object
                        property int fenceIndex: index
                        property int fenceType: 0
                        property bool isEditing: editingFenceIndex === index && editingFenceType === 0

                        Rectangle {
                            id: fenceCardBg
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: fenceCardColumn.height + ScreenTools.defaultFontPixelHeight
                            color: "black"
                            radius: ScreenTools.defaultFontPixelWidth / 4
                            border.width: 1
                            border.color: qgcPal.windowShade
                        }

                        ColumnLayout {
                            id: fenceCardColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.rightMargin: ScreenTools.minTouchPixels / 2
                            anchors.verticalCenter: fenceCardBg.verticalCenter
                            anchors.leftMargin: ScreenTools.defaultFontPixelWidth / 2
                            spacing: ScreenTools.defaultFontPixelHeight / 4

                            RowLayout {
                                Layout.fillWidth: true

                                QGCLabel {
                                    text: qsTr("Type:")
                                }
                                Item {
                                    Layout.fillWidth: true
                                }
                                QGCLabel {
                                    text: qsTr("Polygon")
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                QGCLabel {
                                    text: qsTr("Nature:")
                                }
                                Item {
                                    Layout.fillWidth: true
                                }
                                QGCRadioButton {
                                    id: polyInclusionRadio
                                    text: qsTr("Inclusion")
                                    checked: fenceObject.inclusion
                                    property real _indicatorSize: ScreenTools.defaultFontPixelWidth * 2
                                    indicator: Rectangle {
                                        implicitWidth: polyInclusionRadio._indicatorSize
                                        implicitHeight: polyInclusionRadio._indicatorSize
                                        radius: height / 2
                                        color: "transparent"
                                        border.color: "#1484FC"
                                        border.width: 1
                                        x: polyInclusionRadio.leftPadding
                                        y: parent.height / 2 - height / 2
                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: parent.width * 0.5
                                            height: width
                                            radius: height / 2
                                            color: "#1484FC"
                                            visible: polyInclusionRadio.checked
                                        }
                                    }
                                    onClicked: fenceObject.inclusion = true
                                }
                                QGCRadioButton {
                                    id: polyExclusionRadio
                                    text: qsTr("Exclusion")
                                    checked: !fenceObject.inclusion
                                    property real _indicatorSize: ScreenTools.defaultFontPixelWidth * 2
                                    indicator: Rectangle {
                                        implicitWidth: polyExclusionRadio._indicatorSize
                                        implicitHeight: polyExclusionRadio._indicatorSize
                                        radius: height / 2
                                        color: "transparent"
                                        border.color: "#1484FC"
                                        border.width: 1
                                        x: polyExclusionRadio.leftPadding
                                        y: parent.height / 2 - height / 2
                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: parent.width * 0.5
                                            height: width
                                            radius: height / 2
                                            color: "#1484FC"
                                            visible: polyExclusionRadio.checked
                                        }
                                    }
                                    onClicked: fenceObject.inclusion = false
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                QGCLabel {
                                    text: qsTr("Vertices:")
                                }
                                Item {
                                    Layout.fillWidth: true
                                }
                                QGCLabel {
                                    text: fenceObject.count
                                }
                                QGCCheckBox {
                                    text: qsTr("Edit")
                                    checked: isEditing
                                    onClicked: _selectFenceForEdit(fenceIndex, fenceType)
                                }
                            }
                        }

                        Image {
                            z: 1
                            height: ScreenTools.minTouchPixels * 0.7
                            width: height
                            sourceSize.height: height
                            fillMode: Image.PreserveAspectFit
                            source: "/xfressvg/deleteProtocol.svg"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: fenceCardBg.right
                            anchors.leftMargin: -width / 2

                            QGCMouseArea {
                                fillItem: parent
                                onClicked: {
                                    if (geoFenceController)
                                        geoFenceController.deletePolygon(fenceIndex);
                                }
                            }
                        }
                    }
                }

                Repeater {
                    model: geoFenceController ? geoFenceController.circles : null

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: fenceCircleCardBg.height

                        property var fenceObject: object
                        property int fenceIndex: index
                        property int fenceType: 1
                        property bool isEditing: editingFenceIndex === index && editingFenceType === 1

                        Rectangle {
                            id: fenceCircleCardBg
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: fenceCircleCardColumn.height + ScreenTools.defaultFontPixelHeight
                            color: "black"
                            radius: ScreenTools.defaultFontPixelWidth / 4
                            border.width: 1
                            border.color: qgcPal.windowShade
                        }

                        ColumnLayout {
                            id: fenceCircleCardColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.rightMargin: ScreenTools.minTouchPixels / 2
                            anchors.verticalCenter: fenceCircleCardBg.verticalCenter
                            anchors.leftMargin: ScreenTools.defaultFontPixelWidth / 2
                            spacing: ScreenTools.defaultFontPixelHeight / 4

                            RowLayout {
                                Layout.fillWidth: true

                                QGCLabel {
                                    text: qsTr("Type:")
                                }
                                Item {
                                    Layout.fillWidth: true
                                }
                                QGCLabel {
                                    text: qsTr("Circle")
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                QGCLabel {
                                    text: qsTr("Nature:")
                                }
                                Item {
                                    Layout.fillWidth: true
                                }
                                QGCRadioButton {
                                    id: circleInclusionRadio
                                    text: qsTr("Inclusion")
                                    checked: fenceObject.inclusion
                                    property real _indicatorSize: ScreenTools.defaultFontPixelWidth * 2
                                    indicator: Rectangle {
                                        implicitWidth: circleInclusionRadio._indicatorSize
                                        implicitHeight: circleInclusionRadio._indicatorSize
                                        radius: height / 2
                                        color: "transparent"
                                        border.color: "#1484FC"
                                        border.width: 1
                                        x: circleInclusionRadio.leftPadding
                                        y: parent.height / 2 - height / 2
                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: parent.width * 0.5
                                            height: width
                                            radius: height / 2
                                            color: "#1484FC"
                                            visible: circleInclusionRadio.checked
                                        }
                                    }
                                    onClicked: fenceObject.inclusion = true
                                }
                                QGCRadioButton {
                                    id: circleExclusionRadio
                                    text: qsTr("Exclusion")
                                    checked: !fenceObject.inclusion
                                    property real _indicatorSize: ScreenTools.defaultFontPixelWidth * 2
                                    indicator: Rectangle {
                                        implicitWidth: circleExclusionRadio._indicatorSize
                                        implicitHeight: circleExclusionRadio._indicatorSize
                                        radius: height / 2
                                        color: "transparent"
                                        border.color: "#1484FC"
                                        border.width: 1
                                        x: circleExclusionRadio.leftPadding
                                        y: parent.height / 2 - height / 2
                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: parent.width * 0.5
                                            height: width
                                            radius: height / 2
                                            color: "#1484FC"
                                            visible: circleExclusionRadio.checked
                                        }
                                    }
                                    onClicked: fenceObject.inclusion = false
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                QGCLabel {
                                    text: qsTr("Radius:")
                                }
                                Item {
                                    Layout.fillWidth: true
                                }
                                FactTextField {
                                    fact: fenceObject.radius
                                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                                }
                                QGCCheckBox {
                                    text: qsTr("Edit")
                                    checked: isEditing
                                    onClicked: _selectFenceForEdit(fenceIndex, fenceType)
                                }
                            }
                        }

                        Image {
                            z: 1
                            height: ScreenTools.minTouchPixels * 0.7
                            width: height
                            sourceSize.height: height
                            fillMode: Image.PreserveAspectFit
                            source: "/xfressvg/deleteProtocol.svg"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: fenceCircleCardBg.right
                            anchors.leftMargin: -width / 2

                            QGCMouseArea {
                                fillItem: parent
                                onClicked: {
                                    if (geoFenceController)
                                        geoFenceController.deleteCircle(fenceIndex);
                                }
                            }
                        }
                    }
                }
            }

            QGCLabel {
                visible: !_hasFences
                text: qsTr("No fences. Click + to add.")
                font.pointSize: ScreenTools.smallFontPointSize
                color: qgcPal.text
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: qgcPal.windowShade
            }
            ColumnLayout {
                Layout.fillWidth: true
                QGCLabel {
                    text: qsTr("Global Info")
                    font.bold: true
                }
                //信息区域
                Rectangle {
                    Layout.fillWidth: true
                    height: infoColumn.height + ScreenTools.defaultFontPixelHeight
                    color: "black"
                    radius: ScreenTools.defaultFontPixelWidth / 4
                    border.width: 1
                    border.color: qgcPal.windowShade

                    ColumnLayout {
                        id: infoColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: ScreenTools.defaultFontPixelWidth / 2
                        anchors.rightMargin: ScreenTools.minTouchPixels / 2
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: ScreenTools.defaultFontPixelHeight / 4

                        RowLayout {
                            Layout.fillWidth: true

                            QGCLabel {
                                text: qsTr("Distance:")
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                            QGCLabel {
                                text: _missionPlannedDistanceText
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            QGCLabel {
                                text: qsTr("Max Telemetry Distance:")
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                            QGCLabel {
                                text: _missionMaxTelemetryText
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            QGCLabel {
                                text: qsTr("Time:")
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                            QGCLabel {
                                text: _getMissionTime()
                            }
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
