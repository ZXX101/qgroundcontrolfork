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
        anchors.margins: ScreenTools.defaultFontPixelWidth
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
                Item { Layout.fillWidth: true }
                QGCTextField {
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 16
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
                }
                Item { Layout.fillWidth: true }
                QGCLabel {
                    text: "m"
                }
                QGCButton {
                    text: "-10"
                    _horizontalPadding: 0
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
                    onClicked: {
                        if (_defaultAltitude) {
                            _defaultAltitude.rawValue = Math.max(0, _defaultAltitude.rawValue - 10)
                        }
                    }
                }
                QGCButton {
                    text: "+10"
                    _horizontalPadding: 0
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
                    onClicked: {
                        if (_defaultAltitude) {
                            _defaultAltitude.rawValue = _defaultAltitude.rawValue + 10
                        }
                    }
                }
                QGCTextField {
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                    text: _defaultAltitude ? _defaultAltitude.rawValue : "50"
                    horizontalAlignment: Text.AlignRight
                    onEditingFinished: {
                        if (_defaultAltitude) {
                            _defaultAltitude.rawValue = parseFloat(text)
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                QGCLabel {
                    text: qsTr("Flight Speed")
                }
                Item { Layout.fillWidth: true }
                QGCLabel {
                    text: "m/s"
                }
                QGCButton {
                    text: "-1"
                    _horizontalPadding: 0
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
                    onClicked: {
                    }
                }
                QGCButton {
                    text: "+1"
                    _horizontalPadding: 0
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
                    onClicked: {
                    }
                }
                QGCTextField {
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                    text: "10"
                    horizontalAlignment: Text.AlignRight
                }
            }

            RowLayout {
                Layout.fillWidth: true

                QGCLabel {
                    text: qsTr("End Action")
                }
                Item { Layout.fillWidth: true }
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
                Item { Layout.fillWidth: true }
                QGCCheckBoxSlider {
                    checked: fenceEnabled
                    onClicked: fenceEnabled = !fenceEnabled
                }

                QGCButton {
                    text: "+"
                    visible: fenceEnabled
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
