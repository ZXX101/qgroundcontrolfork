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
            anchors.leftMargin: ScreenTools.defaultFontPixelWidth
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: ScreenTools.defaultFontPixelWidth

            QGCLabel {
                text: qsTr("XF Mission")
                font.pointSize: ScreenTools.largeFontPointSize
            }
            QGCButton {
                text: qsTr("Back")
                onClicked: {
                    if (mainWindow.allowViewSwitch()) {
                        xfMissionView.visible = false;
                        flyView.visible = true;
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
            var nextIndex = _missionController.currentPlanViewVIIndex + 1;

            if (_missionController.visualItems.count === 1) {
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
    }

    XFMissionToolStrip {
        id: toolStrip
        anchors.left: parent.left
        anchors.top: toolbar.bottom
        anchors.margins: ScreenTools.defaultFontPixelWidth

        onWaypointClicked: {
            _addMode = _addMode === "waypoint" ? "" : "waypoint";
        }
        onRoiClicked: {
            _addMode = _addMode === "roi" ? "" : "roi";
        }
        onVehicleClicked: {
            if (_activeVehicle) {
                missionMap.center = _activeVehicle.coordinate;
            }
        }
        onFenceClicked: {
            missionInfoPopup.fenceEnabled = !missionInfoPopup.fenceEnabled;
            missionInfoPopup.currentTab = "basic";
        }

        property string _addMode: ""
        property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    }

    XFMissionInfoPopup {
        id: missionInfoPopup
        anchors.right: parent.right
        anchors.top: toolbar.bottom
        anchors.margins: ScreenTools.defaultFontPixelWidth
        width: missionInfoPopup.expanded ? ScreenTools.defaultFontPixelWidth * 40 : ScreenTools.defaultFontPixelWidth * 10
        anchors.bottom: parent.bottom
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
                                         qsTr("Are you sure you want to remove all mission items and clear the mission from the vehicle?"),
                                         Dialog.Yes | Dialog.Cancel,
                                         function() {
                                             _planMasterController.removeAllFromVehicle();
                                             _missionController.setCurrentPlanViewSeqNum(0, true);
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
