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
                text: "Back"
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
            _planMasterController.fitViewportToItems()
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
            var coordinate = missionMap.toCoordinate(Qt.point(mouse.x, mouse.y), false);
            var nextIndex = _missionController.currentPlanViewVIIndex + 1;

            // 第一次点击（只有Mission Settings）：添加Takeoff
            // 后续点击：添加Waypoint
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
                opacity: 1
                interactive: true
                vehicle: _planMasterController.controllerVehicle
                onClicked: sequenceNumber => {
                    _missionController.setCurrentPlanViewSeqNum(sequenceNumber, false);
                }
            }
        }

        MissionLineView {
            model: _missionController.simpleFlightPathSegments
        }

        MapItemView {
            model: _missionController.directionArrows
            delegate: MapLineArrow {
                fromCoord: object ? object.coordinate1 : undefined
                toCoord: object ? object.coordinate2 : undefined
                arrowPosition: 3
                z: QGroundControl.zOrderWaypointLines + 1
            }
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

        property string _addMode: ""
        property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    }

    XFMissionInfoPopup {
        id: missionInfoPopup
        anchors.right: parent.right
        anchors.top: toolbar.bottom
        anchors.margins: ScreenTools.defaultFontPixelWidth
        width: ScreenTools.defaultFontPixelWidth * 40
        anchors.bottom: parent.bottom
        visible: true

        missionController: _missionController
        planMasterController: _planMasterController

        property bool _planFiles: true

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

        function saveToSelectedFile() {
            if (!checkReadyForSaveUpload(true)) {
                return;
            }
            fileDialog.title = qsTr("Save Plan");
            fileDialog.planFiles = true;
            fileDialog.nameFilters = _planMasterController.saveNameFilters;
            fileDialog.openForSave();
        }
    }
}
