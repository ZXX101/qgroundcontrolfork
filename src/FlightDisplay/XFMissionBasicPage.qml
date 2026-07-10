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

    QGCPalette { id: qgcPal }

    property var _appSettings: QGroundControl.settingsManager.appSettings
    property var _defaultAltitude: _appSettings ? _appSettings.defaultMissionItemAltitude : null
    property var _missionSettings: missionController && missionController.visualItems.count > 0 ? missionController.visualItems.get(0) : null
    property string missionName: "Mission"
    property var geoFenceController: null
    property var flightMap: null
    property bool fenceEnabled: false

    function _addFencePolygon() {
        if (!geoFenceController || !flightMap) return
        var topLeftCoord, bottomRightCoord
        if (flightMap.centerViewport) {
            var rect = Qt.rect(flightMap.centerViewport.x, flightMap.centerViewport.y, flightMap.centerViewport.width, flightMap.centerViewport.height)
            topLeftCoord = flightMap.toCoordinate(Qt.point(rect.x, rect.y), false)
            bottomRightCoord = flightMap.toCoordinate(Qt.point(rect.x + rect.width, rect.y + rect.height), false)
        } else {
            var center = flightMap.center
            topLeftCoord = center.atDistanceAndAzimuth(1500, -45)
            bottomRightCoord = center.atDistanceAndAzimuth(1500, 135)
        }
        geoFenceController.addInclusionPolygon(topLeftCoord, bottomRightCoord)
    }

    function _addFenceCircle() {
        if (!geoFenceController || !flightMap) return
        var topLeftCoord, bottomRightCoord
        if (flightMap.centerViewport) {
            var rect = Qt.rect(flightMap.centerViewport.x, flightMap.centerViewport.y, flightMap.centerViewport.width, flightMap.centerViewport.height)
            topLeftCoord = flightMap.toCoordinate(Qt.point(rect.x, rect.y), false)
            bottomRightCoord = flightMap.toCoordinate(Qt.point(rect.x + rect.width, rect.y + rect.height), false)
        } else {
            var center = flightMap.center
            topLeftCoord = center.atDistanceAndAzimuth(750, -45)
            bottomRightCoord = center.atDistanceAndAzimuth(750, 135)
        }
        geoFenceController.addInclusionCircle(topLeftCoord, bottomRightCoord)
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
                    text: qsTr("Mission Name")
                }
                QGCTextField {
                    Layout.fillWidth: true
                    text: missionName
                    onTextChanged: {
                        missionName = text
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                QGCLabel {
                    text: qsTr("Flight Altitude")
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
                }
                QGCTextField {
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                    text: _defaultAltitude ? _defaultAltitude.rawValue : "50"
                    onEditingFinished: {
                        if (_defaultAltitude) {
                            _defaultAltitude.rawValue = parseFloat(text)
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
                        if (_defaultAltitude) {
                            _defaultAltitude.rawValue = Math.max(0, _defaultAltitude.rawValue - 10)
                        }
                    }
                }
                QGCButton {
                    text: "+10"
                    _horizontalPadding: 0
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
                    onClicked: {
                        if (_defaultAltitude) {
                            _defaultAltitude.rawValue = _defaultAltitude.rawValue + 10
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                QGCLabel {
                    text: qsTr("Flight Speed")
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
                }
                QGCTextField {
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                    text: "10"
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
                    }
                }
                QGCButton {
                    text: "+1"
                    _horizontalPadding: 0
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
                    onClicked: {
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                QGCLabel {
                    text: qsTr("End Action")
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
                }
                QGCComboBox {
                    model: [qsTr("RTL"), qsTr("Land"), qsTr("Hover")]
                    currentIndex: 0
                    Layout.fillWidth: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: qgcPal.windowShade
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: ScreenTools.defaultFontPixelWidth

                QGCLabel {
                    text: qsTr("Insert Fence")
                    font.bold: true
                }

                Rectangle {
                    id: fenceSwitch
                    width: ScreenTools.defaultFontPixelWidth * 8
                    height: ScreenTools.defaultFontPixelHeight * 1.6
                    radius: height / 2
                    color: fenceEnabled ? qgcPal.colorGreen : qgcPal.colorGrey
                    border.width: 1
                    border.color: qgcPal.windowShade

                    property bool _fenceOn: fenceEnabled

                    Rectangle {
                        id: fenceSwitchKnob
                        width: fenceSwitch.height - 4
                        height: width
                        radius: width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        x: fenceSwitch._fenceOn ? parent.width - width - 2 : 2
                        color: qgcPal.buttonText

                        Behavior on x {
                            NumberAnimation { duration: 150 }
                        }
                    }

                    QGCMouseArea {
                        fillItem: parent
                        onClicked: {
                            fenceEnabled = !fenceEnabled
                        }
                    }
                }

                QGCButton {
                    text: "+"
                    visible: fenceEnabled
                    _horizontalPadding: 0
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 3
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

                Item { Layout.fillWidth: true }
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: fenceEnabled && geoFenceController
                spacing: ScreenTools.defaultFontPixelHeight / 4

                Repeater {
                    model: geoFenceController ? geoFenceController.polygons : null

                    Rectangle {
                        Layout.fillWidth: true
                        height: fenceCardColumn.height + ScreenTools.defaultFontPixelHeight
                        color: qgcPal.missionItemEditor
                        radius: ScreenTools.defaultFontPixelWidth / 4
                        border.width: 1
                        border.color: qgcPal.windowShade

                        property var fenceObject: object
                        property bool isPolygon: true
                        property int fenceIndex: index

                        ColumnLayout {
                            id: fenceCardColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: ScreenTools.defaultFontPixelWidth / 2
                            spacing: ScreenTools.defaultFontPixelHeight / 4

                            RowLayout {
                                Layout.fillWidth: true

                                QGCLabel {
                                    text: qsTr("Type:")
                                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
                                }
                                QGCRadioButton {
                                    text: qsTr("Polygon")
                                    checked: true
                                    enabled: false
                                }
                                QGCRadioButton {
                                    text: qsTr("Circle")
                                    checked: false
                                    enabled: false
                                }
                                Item { Layout.fillWidth: true }
                                QGCButton {
                                    text: qsTr("Del")
                                    _horizontalPadding: 0
                                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 4
                                    onClicked: {
                                        if (geoFenceController) geoFenceController.deletePolygon(fenceIndex)
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                QGCLabel {
                                    text: qsTr("Nature:")
                                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
                                }
                                QGCRadioButton {
                                    text: qsTr("Inclusion")
                                    checked: fenceObject.inclusion
                                    onClicked: fenceObject.inclusion = true
                                }
                                QGCRadioButton {
                                    text: qsTr("Exclusion")
                                    checked: !fenceObject.inclusion
                                    onClicked: fenceObject.inclusion = false
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                QGCLabel {
                                    text: qsTr("Vertices:")
                                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
                                }
                                QGCLabel {
                                    text: fenceObject.count
                                }
                                Item { Layout.fillWidth: true }
                                QGCRadioButton {
                                    text: qsTr("Edit")
                                    checked: fenceObject.interactive
                                    onClicked: {
                                        if (geoFenceController) geoFenceController.clearAllInteractive()
                                        fenceObject.interactive = checked
                                    }
                                }
                            }
                        }
                    }
                }

                Repeater {
                    model: geoFenceController ? geoFenceController.circles : null

                    Rectangle {
                        Layout.fillWidth: true
                        height: fenceCircleCardColumn.height + ScreenTools.defaultFontPixelHeight
                        color: qgcPal.missionItemEditor
                        radius: ScreenTools.defaultFontPixelWidth / 4
                        border.width: 1
                        border.color: qgcPal.windowShade

                        property var fenceObject: object
                        property int fenceIndex: index

                        ColumnLayout {
                            id: fenceCircleCardColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: ScreenTools.defaultFontPixelWidth / 2
                            spacing: ScreenTools.defaultFontPixelHeight / 4

                            RowLayout {
                                Layout.fillWidth: true

                                QGCLabel {
                                    text: qsTr("Type:")
                                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
                                }
                                QGCRadioButton {
                                    text: qsTr("Polygon")
                                    checked: false
                                    enabled: false
                                }
                                QGCRadioButton {
                                    text: qsTr("Circle")
                                    checked: true
                                    enabled: false
                                }
                                Item { Layout.fillWidth: true }
                                QGCButton {
                                    text: qsTr("Del")
                                    _horizontalPadding: 0
                                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 4
                                    onClicked: {
                                        if (geoFenceController) geoFenceController.deleteCircle(fenceIndex)
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                QGCLabel {
                                    text: qsTr("Nature:")
                                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
                                }
                                QGCRadioButton {
                                    text: qsTr("Inclusion")
                                    checked: fenceObject.inclusion
                                    onClicked: fenceObject.inclusion = true
                                }
                                QGCRadioButton {
                                    text: qsTr("Exclusion")
                                    checked: !fenceObject.inclusion
                                    onClicked: fenceObject.inclusion = false
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                QGCLabel {
                                    text: qsTr("Radius:")
                                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
                                }
                                FactTextField {
                                    fact: fenceObject.radius
                                    Layout.fillWidth: true
                                }
                                QGCRadioButton {
                                    text: qsTr("Edit")
                                    checked: fenceObject.interactive
                                    onClicked: {
                                        if (geoFenceController) geoFenceController.clearAllInteractive()
                                        fenceObject.interactive = checked
                                    }
                                }
                            }
                        }
                    }
                }

                QGCLabel {
                    visible: geoFenceController && geoFenceController.polygons.count === 0 && geoFenceController.circles.count === 0
                    text: qsTr("No fences. Click + to add.")
                    font.pointSize: ScreenTools.smallFontPointSize
                    color: qgcPal.text
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
