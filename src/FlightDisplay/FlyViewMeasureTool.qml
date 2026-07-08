import QtQuick
import QtLocation
import QtPositioning

import QGroundControl
import QGroundControl.Palette
import QGroundControl.ScreenTools
import QGroundControl.FlightMap

Item {
    id: root

    property var mapControl
    property bool active: false

    property var _points: []
    property var _pointData: []

    property var _unitsConversion: QGroundControl.unitsConversion

    onActiveChanged: {
        if (!active) clear()
    }

    Component.onDestruction: {
        clear()
    }

    function addPoint(coordinate) {
        var coord = QtPositioning.coordinate(coordinate.latitude, coordinate.longitude)
        var ptIndex = _points.length
        _points.push(coord)

        var pointMarker = _pointMarkerComponent.createObject(mapControl, { "coordinate": coord })
        mapControl.addMapItem(pointMarker)

        var dragArea = _dragAreaComponent.createObject(mapControl, {
            "itemIndicator": pointMarker,
            "itemCoordinate": coord
        })
        dragArea._ptIndex = ptIndex

        var ptData = {
            "marker": pointMarker,
            "drag": dragArea,
            "prevLine": null,
            "prevLabel": null,
            "nextLine": null,
            "nextLabel": null
        }

        if (ptIndex >= 1) {
            var prevCoord = _points[ptIndex - 1]

            var line = _lineComponent.createObject(mapControl)
            line.path = [prevCoord, coord]
            mapControl.addMapItem(line)

            var dist = prevCoord.distanceTo(coord)
            var azimuth = prevCoord.azimuthTo(coord)
            var midCoord = prevCoord.atDistanceAndAzimuth(dist / 2, azimuth)

            var distLabel = _distLabelComponent.createObject(mapControl, {
                "coordinate": midCoord
            })
            distLabel._distance = dist
            mapControl.addMapItem(distLabel)

            _pointData[ptIndex - 1].nextLine = line
            _pointData[ptIndex - 1].nextLabel = distLabel
            ptData.prevLine = line
            ptData.prevLabel = distLabel
        }

        _pointData.push(ptData)
    }

    function _updateSegmentsForPoint(ptIndex) {
        if (ptIndex < 0 || ptIndex >= _points.length) return

        var coord = _points[ptIndex]
        var pd = _pointData[ptIndex]

        if (pd.marker) {
            pd.marker.coordinate = coord
        }

        if (ptIndex > 0) {
            var prevCoord = _points[ptIndex - 1]
            if (pd.prevLine) {
                pd.prevLine.path = [prevCoord, coord]
            }
            if (pd.prevLabel) {
                var dist = prevCoord.distanceTo(coord)
                var azimuth = prevCoord.azimuthTo(coord)
                var midCoord = prevCoord.atDistanceAndAzimuth(dist / 2, azimuth)
                pd.prevLabel.coordinate = midCoord
                pd.prevLabel._distance = dist
            }
        }

        if (ptIndex < _points.length - 1) {
            var nextCoord = _points[ptIndex + 1]
            if (pd.nextLine) {
                pd.nextLine.path = [coord, nextCoord]
            }
            if (pd.nextLabel) {
                var dist2 = coord.distanceTo(nextCoord)
                var azimuth2 = coord.azimuthTo(nextCoord)
                var midCoord2 = coord.atDistanceAndAzimuth(dist2 / 2, azimuth2)
                pd.nextLabel.coordinate = midCoord2
                pd.nextLabel._distance = dist2
            }
        }
    }

    function _onPointDragged(ptIndex, newCoord) {
        if (ptIndex < 0 || ptIndex >= _points.length) return
        _points[ptIndex] = QtPositioning.coordinate(newCoord.latitude, newCoord.longitude)
        _updateSegmentsForPoint(ptIndex)
    }

    function clear() {
        for (var i = 0; i < _pointData.length; i++) {
            var pd = _pointData[i]
            _removeMapItemSafe(pd.marker)
            _removeMapItemSafe(pd.drag)
            _removeMapItemSafe(pd.prevLine)
            _removeMapItemSafe(pd.prevLabel)
        }
        _pointData = []
        _points = []
    }

    function _removeMapItemSafe(item) {
        if (item) {
            mapControl.removeMapItem(item)
            item.destroy()
        }
    }

    Component {
        id: _pointMarkerComponent

        MapQuickItem {
            anchorPoint.x: sourceItem.width / 2
            anchorPoint.y: sourceItem.height / 2
            z: QGroundControl.zOrderMapItems

            sourceItem: Rectangle {
                width: ScreenTools.defaultFontPixelHeight * 0.75
                height: width
                radius: width / 2
                color: "white"
                border.color: "#2C2C2C"
                border.width: 1

                Rectangle {
                    width: parent.width * 0.5
                    height: width
                    radius: width / 2
                    anchors.centerIn: parent
                    color: "#2C2C2C"
                }
            }
        }
    }

    Component {
        id: _dragAreaComponent

        MissionItemIndicatorDrag {
            id: dragArea
            mapControl: root.mapControl
            z: QGroundControl.zOrderMapItems + 2

            property int _ptIndex: -1

            onItemCoordinateChanged: {
                if (_ptIndex >= 0 && itemCoordinate.isValid) {
                    root._onPointDragged(_ptIndex, itemCoordinate)
                }
            }
        }
    }

    Component {
        id: _lineComponent

        MapPolyline {
            line.width: 3
            line.color: "#FF6B35"
            z: QGroundControl.zOrderWaypointLines
        }
    }

    Component {
        id: _distLabelComponent

        MapQuickItem {
            anchorPoint.x: sourceItem.width / 2
            anchorPoint.y: sourceItem.height / 2
            z: QGroundControl.zOrderMapItems + 1

            property real _distance: 0

            sourceItem: Rectangle {
                color: "#FF6B35"
                border.color: "white"
                border.width: 1
                radius: ScreenTools.defaultFontPixelHeight * 0.2
                width: _label.width + ScreenTools.defaultFontPixelWidth * 0.8
                height: _label.height + ScreenTools.defaultFontPixelHeight * 0.2

                Text {
                    id: _label
                    anchors.centerIn: parent
                    text: root._unitsConversion.metersToAppSettingsHorizontalDistanceUnits(_distance).toFixed(1) + " " +
                          root._unitsConversion.appSettingsHorizontalDistanceUnitsString
                    color: "white"
                    font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.6
                    font.bold: true
                }
            }
        }
    }
}
