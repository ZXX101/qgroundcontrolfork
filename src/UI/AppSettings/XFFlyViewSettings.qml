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
import QtQuick.Layouts

import QGroundControl
import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.MultiVehicleManager
import QGroundControl.Palette
import QGroundControl.Controllers

ColumnLayout {
    property var    _settingsManager:                       QGroundControl.settingsManager
    property var    _flyViewSettings:                       _settingsManager.flyViewSettings
    property var    _mavlinkActionsSettings:                _settingsManager.mavlinkActionsSettings
    property Fact   _virtualJoystick:                       _settingsManager.appSettings.virtualJoystick
    property Fact   _virtualJoystickAutoCenterThrottle:     _settingsManager.appSettings.virtualJoystickAutoCenterThrottle
    property Fact   _virtualJoystickLeftHandedMode:         _settingsManager.appSettings.virtualJoystickLeftHandedMode
    property Fact   _enableMultiVehiclePanel:               _settingsManager.appSettings.enableMultiVehiclePanel
    property Fact   _showAdditionalIndicatorsCompass:       _flyViewSettings.showAdditionalIndicatorsCompass
    property Fact   _lockNoseUpCompass:                     _flyViewSettings.lockNoseUpCompass
    property Fact   _guidedMinimumAltitude:                 _flyViewSettings.guidedMinimumAltitude
    property Fact   _guidedMaximumAltitude:                 _flyViewSettings.guidedMaximumAltitude
    property Fact   _maxGoToLocationDistance:               _flyViewSettings.maxGoToLocationDistance
    property Fact   _forwardFlightGoToLocationLoiterRad:    _flyViewSettings.forwardFlightGoToLocationLoiterRad
    property Fact   _goToLocationRequiresConfirmInGuided:   _flyViewSettings.goToLocationRequiresConfirmInGuided
    property var    _viewer3DSettings:                      _settingsManager.viewer3DSettings
    property Fact   _viewer3DEnabled:                       _viewer3DSettings.enabled
    property Fact   _viewer3DOsmFilePath:                   _viewer3DSettings.osmFilePath
    property Fact   _viewer3DBuildingLevelHeight:           _viewer3DSettings.buildingLevelHeight
    property Fact   _viewer3DAltitudeBias:                  _viewer3DSettings.altitudeBias

    QGCFileDialogController { id: fileController }

    function mavlinkActionList() {
        var fileModel = fileController.getFiles(_settingsManager.appSettings.mavlinkActionsSavePath, "*.json")
        fileModel.unshift(qsTr("<None>"))
        return fileModel
    }

    SettingsGroupLayout {
        Layout.fillWidth:   true
        heading:            qsTr("General")

        FactCheckBoxSlider {
            id:                 useCheckList
            Layout.fillWidth:   true
            text:               qsTr("Use Preflight Checklist")
            fact:               _useChecklist
            visible:            _useChecklist.visible && QGroundControl.corePlugin.options.preFlightChecklistUrl.toString().length
            property Fact _useChecklist:      _settingsManager.appSettings.useChecklist
        }

        FactCheckBoxSlider {
            Layout.fillWidth:   true
            text:               qsTr("Update return to home position based on device location.")
            fact:               _updateHomePosition
            visible:            _updateHomePosition.visible
            property Fact _updateHomePosition: _flyViewSettings.updateHomePosition
        }
        LabelledFactTextField {
            Layout.fillWidth:   true
            label:              qsTr("Minimum Altitude")
            fact:               _guidedMinimumAltitude
            visible:            fact.visible
        }

        LabelledFactTextField {
            Layout.fillWidth:   true
            label:              qsTr("Maximum Altitude")
            fact:               _guidedMaximumAltitude
            visible:            fact.visible
        }

        FactCheckBoxSlider {
            Layout.fillWidth:   true
            text:               qsTr("Lock Compass Nose-Up")
            visible:            _lockNoseUpCompass.visible
            fact:               _lockNoseUpCompass
        }

    }

}
