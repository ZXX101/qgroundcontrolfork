import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import QGroundControl
import QGroundControl.ScreenTools
import QGroundControl.Vehicle
import QGroundControl.Controls
import QGroundControl.FactControls
import QGroundControl.Palette
import QGroundControl.FlightMap

//显示类组件 - 走廊扫描编辑器
//编辑走廊扫描任务的参数，包括：
//  1. 走廊宽度 - 扫描区域的宽度
//  2. 转向距离 - 边缘转向距离
//  3. 相机触发距离 - 触发拍照的距离间隔
//继承自 TransectStyleComplexItemEditor
TransectStyleComplexItemEditor {
    transectAreaDefinitionComplete: _missionItem.corridorPolyline.isValid
    transectAreaDefinitionHelp:     qsTr("Use the Polyline Tools to create the polyline which defines the corridor.")
    transectValuesHeaderName:       qsTr("Corridor")
    transectValuesComponent:        _transectValuesComponent
    presetsTransectValuesComponent: _transectValuesComponent

    // The following properties must be available up the hierarchy chain
    //  property real   availableWidth    ///< Width for control
    //  property var    missionItem       ///< Mission Item for editor

    property real   _margin:        ScreenTools.defaultFontPixelWidth / 2
    property var    _missionItem:   missionItem

    Component {
        id: _transectValuesComponent

        GridLayout {
            columnSpacing:  _margin
            rowSpacing:     _margin
            columns:        2

            QGCLabel { text: qsTr("Width") }
            FactTextField {
                fact:               _missionItem.corridorWidth
                Layout.fillWidth:   true
            }

            QGCLabel {
                text:       qsTr("Turnaround dist")
                visible:    !forPresets
            }
            FactTextField {
                fact:               _missionItem.turnAroundDistance
                Layout.fillWidth:   true
                visible:            !forPresets
            }

            FactCheckBox {
                Layout.columnSpan:  2
                text:               qsTr("Images in turnarounds")
                fact:               _missionItem.cameraTriggerInTurnAround
                enabled:            _missionItem.hoverAndCaptureAllowed ? !_missionItem.hoverAndCapture.rawValue : true
                visible:            !forPresets
            }
        }
    }
}
