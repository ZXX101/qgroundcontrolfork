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
import QtQuick.Dialogs
import QtLocation
import QtPositioning
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controllers
import QGroundControl.Controls
import QGroundControl.FactSystem
import QGroundControl.FlightDisplay
import QGroundControl.FlightMap
import QGroundControl.Palette
import QGroundControl.ScreenTools
import QGroundControl.Vehicle

Item {
    id: xfMissionView
    anchors.fill: parent
    visible: false
    z: QGroundControl.zOrderTopMost

    QGCPalette {
        id: qgcPal
    }

    property var _planMasterController: planMasterController
    property var _missionController: _planMasterController ? _planMasterController.missionController : null
    property var _geoFenceController: _planMasterController ? _planMasterController.geoFenceController : null
    property string missionName: "Mission"
    property bool _fenceMode: missionInfoPopup.fenceEnabled

    PlanMasterController {
        id: planMasterController
        flyView: false
        Component.onCompleted: {
            start();
            _missionController.setCurrentPlanViewSeqNum(0, true);
        }
    }

    Rectangle {
        id: toolbar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: ScreenTools.toolbarHeight
        color: qgcPal.toolbarBackground

        RowLayout {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: ScreenTools.defaultFontPixelWidth

            QGCToolBarButton {
                Layout.preferredHeight: toolbar.height
                icon.source:            "/xfressvg/logo-groundstation.svg"
                logo:                   true
                onClicked:              mainWindow.showToolSelectDialog()
            }

            QGCLabel {
                text: qsTr("XF Mission")
                font.pointSize: ScreenTools.largeFontPointSize
                font.family: ScreenTools.tecentFontFamily
            }
            QGCButton {
                id:         buttonBack
                text:       qsTr("Back")
                iconSource: "qrc:/xfressvg/back.svg"
                onClicked: {
                    if (mainWindow.allowViewSwitch()) {
                        xfMissionView.visible = false;
                        mainWindow.showFlyView();
                    }
                }
            }
        }
    }

    QGCFileDialog {
        id:             fileDialog
        folder:         QGroundControl.settingsManager.appSettings.missionSavePath

        property bool planFiles: true

        onAcceptedForSave: file => {
            if (planFiles) {
                _planMasterController.saveToFile(file)
            } else {
                _planMasterController.saveToKml(file)
            }
            close()
        }

        onAcceptedForLoad: file => {
            _planMasterController.loadFromFile(file)
            var fileName = file.split('/').pop()
            fileName = fileName.replace(/\.[^/.]+$/, "")
            missionName = fileName
            close()
        }
    }

    FlightMap {
        id: missionMap
        anchors.topMargin: ScreenTools.toolbarHeight
        anchors.fill: parent
        mapName: "MissionEditor"
        allowGCSLocationCenter: true
        allowVehicleLocationCenter: true
        planView: true

        zoomLevel: QGroundControl.flightMapZoom
        center: QGroundControl.flightMapPosition

        Component.onCompleted: center = QGroundControl.flightMapPosition

        onZoomLevelChanged: QGroundControl.flightMapZoom = missionMap.zoomLevel
        onCenterChanged: QGroundControl.flightMapPosition = missionMap.center

        onMapClicked: mouse => {
            if (!mainWindow.allowViewSwitch()) {
                return;
            }
            if (_fenceMode) {
                return;
            }
            var coordinate = missionMap.toCoordinate(Qt.point(mouse.x, mouse.y), false);

            if (xfMissionView._currentMode === "measure") {
                measureTool.addPoint(coordinate);
                return;
            }

            var nextIndex = _missionController.currentPlanViewVIIndex + 1;

            if (xfMissionView._currentMode === "roi") {
                _missionController.insertROIMissionItem(coordinate, nextIndex, true);
                xfMissionView._currentMode = "waypoint";
            } else if (_missionController.visualItems.count === 1) {
                _missionController.insertTakeoffItem(coordinate, nextIndex, true);
            } else {
                _missionController.insertSimpleMissionItem(coordinate, nextIndex, true);
            }
        }

        Repeater {
            model: _missionController.visualItems
            delegate: MissionItemMapVisual {
                map: missionMap
                opacity: _fenceMode ? 0.5 : 1
                interactive: !_fenceMode
                vehicle: _planMasterController.controllerVehicle
                onClicked: sequenceNumber => {
                    _missionController.setCurrentPlanViewSeqNum(sequenceNumber, false);
                }
            }
        }

        MissionLineView {
            model: _missionController.simpleFlightPathSegments
            opacity: _fenceMode ? 0.5 : 1
        }

        MapItemView {
            model: !_fenceMode ? _missionController.directionArrows : undefined
            delegate: MapLineArrow {
                fromCoord: object ? object.coordinate1 : undefined
                toCoord: object ? object.coordinate2 : undefined
                arrowPosition: 3
                z: QGroundControl.zOrderWaypointLines + 1
            }
        }

        GeoFenceMapVisuals {
            map:                    missionMap
            myGeoFenceController:   _geoFenceController
            interactive:            _fenceMode
            homePosition:           _missionController.plannedHomePosition
            planView:               true
            opacity:                _fenceMode ? 1 : 0.5
        }

        MapItemView {
            model: QGroundControl.multiVehicleManager.vehicles
            delegate: VehicleMapItem {
                vehicle: object
                coordinate: object.coordinate
                map: missionMap
                size: ScreenTools.defaultFontPixelHeight * 3
                z: QGroundControl.zOrderMapItems - 1
            }
        }

        FlyViewMeasureTool {
            id:                 measureTool
            mapControl:         missionMap
            active:             xfMissionView._currentMode === "measure"
        }
    }

    property string _currentMode: "waypoint"

    Column {
        id: missionButtons
        anchors.left: parent.left
        anchors.top: toolbar.bottom
        anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 0.75
        anchors.topMargin: ScreenTools.defaultFontPixelWidth * 0.75
        spacing: ScreenTools.defaultFontPixelWidth * 0.25

        property real _buttonWidth: ScreenTools.defaultFontPixelWidth * 7
        property real _imageScale:  0.5

        Rectangle {
            id: waypointButton
            width: missionButtons._buttonWidth
            height: width
            radius: ScreenTools.defaultFontPixelWidth / 2
            color: qgcPal.toolbarBackground

            Column {
                anchors.centerIn: parent
                spacing: ScreenTools.defaultFontPixelHeight * 0.1

                Image {
                    width: missionButtons._buttonWidth * missionButtons._imageScale
                    height: width
                    source: xfMissionView._currentMode === "waypoint" ?
                                "qrc:/xfressvg/waypointSelected.svg" :
                                "qrc:/xfressvg/waypoint.svg"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                QGCLabel {
                    text: qsTr("Waypoint")
                    font.pointSize: ScreenTools.smallFontPointSize
                    color: qgcPal.buttonText
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            QGCMouseArea {
                id: waypointMA
                fillItem: parent
                onClicked: xfMissionView._currentMode = "waypoint"
            }
        }

        Rectangle {
            id: roiButton
            width: missionButtons._buttonWidth
            height: width
            radius: ScreenTools.defaultFontPixelWidth / 2
            color: qgcPal.toolbarBackground

            Column {
                anchors.centerIn: parent
                spacing: ScreenTools.defaultFontPixelHeight * 0.1

                Image {
                    width: missionButtons._buttonWidth * missionButtons._imageScale
                    height: width
                    source: (_missionController && _missionController.isROIActive) ?
                                "qrc:/xfressvg/roiSelected.svg" :
                                (xfMissionView._currentMode === "roi" ?
                                     "qrc:/xfressvg/roiSelected.svg" :
                                     "qrc:/xfressvg/roi.svg")
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                QGCLabel {
                    text: (_missionController && _missionController.isROIActive) ? qsTr("Cancel ROI") : qsTr("ROI")
                    font.pointSize: ScreenTools.smallFontPointSize
                    color: qgcPal.buttonText
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            QGCMouseArea {
                id: roiMA
                fillItem: parent
                onClicked: {
                    if (_missionController && _missionController.isROIActive) {
                        var nextIndex = _missionController.currentPlanViewVIIndex + 1
                        _missionController.insertCancelROIMissionItem(nextIndex, true)
                        xfMissionView._currentMode = "waypoint"
                    } else {
                        xfMissionView._currentMode = "roi"
                    }
                }
            }
        }
    }

    FlyViewFloatingToolBar {
        id:                     floatingToolBar
        visible:                true
        anchors.left:             parent.left
        anchors.leftMargin:       ScreenTools.defaultFontPixelWidth
        anchors.top:              missionButtons.bottom
        anchors.topMargin:        ScreenTools.defaultFontPixelWidth / 2

        onCenterOnVehicle: {
            var activeVehicle = QGroundControl.multiVehicleManager.activeVehicle
            if (activeVehicle && activeVehicle.coordinate.isValid) {
                missionMap.center = activeVehicle.coordinate
            }
        }

        onCenterOnGCS: {
            var gcsPos = QGroundControl.qgcPositionManger.gcsPosition
            if (gcsPos.isValid) {
                missionMap.center = gcsPos
            }
        }

        onMeasureDistance: (active) => {
            if (active) {
                xfMissionView._currentMode = "measure"
            } else {
                xfMissionView._currentMode = "waypoint"
            }
        }
    }

    XFMissionInfoPopup {
        id: missionInfoPopup
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: missionInfoPopup.expanded ? ScreenTools.defaultFontPixelWidth * 48 : ScreenTools.defaultFontPixelWidth * 8
        visible: true

        missionController: _missionController
        planMasterController: _planMasterController
        missionName: xfMissionView.missionName
        geoFenceController: _geoFenceController
        flightMap: missionMap

        property bool _planFiles: true

        Connections {
            target: _missionController
            onCurrentPlanViewSeqNumChanged: {
                var seqNum = _missionController.currentPlanViewSeqNum
                missionInfoPopup.currentSequenceNumber = seqNum
                if (seqNum > 0) {
                    missionInfoPopup.syncToSequenceNumber(seqNum)
                }
            }
        }

        function upload() {
            if (!checkReadyForSaveUpload(false)) {
                return;
            }
            switch (_missionController.sendToVehiclePreCheck()) {
            case MissionController.SendToVehiclePreCheckStateOk:
                _planMasterController.sendToVehicle();
                break;
            case MissionController.SendToVehiclePreCheckStateActiveMission:
                mainWindow.showMessageDialog(qsTr("Send To Vehicle"), qsTr("Current mission must be paused prior to uploading a new Plan"));
                break;
            case MissionController.SendToVehiclePreCheckStateFirwmareVehicleMismatch:
                mainWindow.showMessageDialog(qsTr("Plan Upload"), qsTr("This Plan was created for a different firmware or vehicle type."), Dialog.Ok | Dialog.Cancel, function () {
                    _planMasterController.sendToVehicle();
                });
                break;
            }
        }

        function checkReadyForSaveUpload(save) {
            if (_planMasterController.readyForSaveState() == VisualMissionItem.NotReadyForSaveData) {
                var saveOrUpload = save ? qsTr("Save") : qsTr("Upload");
                mainWindow.showMessageDialog(qsTr("Unable to %1").arg(saveOrUpload), qsTr("Plan has incomplete items."));
                return false;
            }
            return true;
        }

        function loadFromSelectedFile() {
            fileDialog.title = qsTr("Select Plan File");
            fileDialog.planFiles = true;
            fileDialog.nameFilters = _planMasterController.loadNameFilters;
            fileDialog.openForLoad();
        }

        function downloadClicked(title) {
            if (_planMasterController.dirty) {
                mainWindow.showMessageDialog(title,
                                             qsTr("You have unsaved/unsent changes. Loading from the Vehicle will lose these changes. Are you sure you want to load from the Vehicle?"),
                                             Dialog.Yes | Dialog.Cancel,
                                             function() { _planMasterController.loadFromVehicle() })
            } else {
                _planMasterController.loadFromVehicle()
            }
        }

        function clearButtonClicked() {
            mainWindow.showMessageDialog(qsTr("Clear"),
                                         qsTr("Are you sure you want to clear the mission from the vehicle? The local mission will be kept."),
                                         Dialog.Yes | Dialog.Cancel,
                                         function() {
                                             _missionController.removeMissionFromVehicleOnly();
                                         })
        }

        function saveToSelectedFile() {
            if (!checkReadyForSaveUpload(true)) {
                return;
            }
            fileDialog.title = qsTr("Save Plan");
            fileDialog.planFiles = true;
            fileDialog.nameFilters = _planMasterController.saveNameFilters;
            fileDialog.defaultFileName = missionName;
            fileDialog.openForSave();
        }
    }
}
