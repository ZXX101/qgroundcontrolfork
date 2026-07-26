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

import QtLocation
import QtPositioning
import QtQuick.Window
import QtQml.Models

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Controllers
import QGroundControl.Controls
import QGroundControl.FactSystem
import QGroundControl.FlightDisplay
import QGroundControl.FlightMap
import QGroundControl.Palette
import QGroundControl.ScreenTools
import QGroundControl.Vehicle

// This is the ui overlay layer for the widgets/tools for Fly View
//飞行界面控件层，位于地图上方，显示飞行工具条、右上角面板、右下角布局、虚拟摇杆、地图比例尺等
//包含以下部件：
//  1. toolStrip 左侧工具条 - 飞行快捷操作按钮
//  2. topRightPanel 右上角面板 - 飞行仪表盘
//  3. bottomRightRowLayout 右下角布局 - 多机列表、引导动作按钮等
//  4. virtualJoystickMultiTouch 虚拟摇杆 - 触摸控制摇杆
//  5. mapScale 地图比例尺 - 地图缩放比例显示
Item {
    id: _root

    property var    parentToolInsets
    property var    totalToolInsets:        _totalToolInsets
    property var    mapControl
    property bool   isViewer3DOpen:         false

    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property var    _planMasterController:  globals.planMasterControllerFlyView
    property var    _missionController:     _planMasterController.missionController
    property var    _geoFenceController:    _planMasterController.geoFenceController
    property var    _rallyPointController:  _planMasterController.rallyPointController
    property var    _guidedController:      globals.guidedControllerFlyView
    property real   _margins:               ScreenTools.defaultFontPixelWidth / 2
    property real   _toolsMargin:           ScreenTools.defaultFontPixelWidth * 0.75
    property rect   _centerViewport:        Qt.rect(0, 0, width, height)
    property real   _rightPanelWidth:       ScreenTools.defaultFontPixelWidth * 30
    property alias  _gripperMenu:           gripperOptions
    property real   _layoutMargin:          ScreenTools.defaultFontPixelWidth * 0.75
    property bool   _layoutSpacing:         ScreenTools.defaultFontPixelWidth
    property bool   _showSingleVehicleUI:   true

    property bool utmspActTrigger

    //工具边距功能组件，管理UI元素的边距和避让区域
    QGCToolInsets {
        id:                     _totalToolInsets
        leftEdgeTopInset:       flightActionButtons.visible ? flightActionButtons.x + flightActionButtons.width : 0
        leftEdgeCenterInset:    leftEdgeTopInset
        leftEdgeBottomInset:    virtualJoystickMultiTouch.visible ? virtualJoystickMultiTouch.leftEdgeBottomInset : parentToolInsets.leftEdgeBottomInset
        rightEdgeTopInset:      topRightPanel.rightEdgeTopInset
        rightEdgeCenterInset:   topRightPanel.rightEdgeCenterInset
        rightEdgeBottomInset:   bottomRightRowLayout.rightEdgeBottomInset
        topEdgeLeftInset:       flightActionButtons.visible ? flightActionButtons.y + flightActionButtons.height : 0
        topEdgeCenterInset:     mapScale.topEdgeCenterInset
        topEdgeRightInset:      topRightPanel.topEdgeRightInset
        bottomEdgeLeftInset:    virtualJoystickMultiTouch.visible ? virtualJoystickMultiTouch.bottomEdgeLeftInset : parentToolInsets.bottomEdgeLeftInset
        bottomEdgeCenterInset:  bottomRightRowLayout.bottomEdgeCenterInset
        bottomEdgeRightInset:   virtualJoystickMultiTouch.visible ? virtualJoystickMultiTouch.bottomEdgeRightInset : bottomRightRowLayout.bottomEdgeRightInset
    }

    //右上角面板，显示飞行仪表盘（高度、速度、姿态球、指南针等）
    FlyViewTopRightPanel {
        id:                     topRightPanel
        anchors.top:            parent.top
        anchors.right:          parent.right
        anchors.topMargin:      _layoutMargin
        anchors.rightMargin:    _layoutMargin
        maximumHeight:          parent.height - (bottomRightRowLayout.height + _margins * 5)

        property real topEdgeRightInset:    height + _layoutMargin
        property real rightEdgeTopInset:    width + _layoutMargin
        property real rightEdgeCenterInset: rightEdgeTopInset
    }

    //右上角按钮行，包含任务按钮和通用按钮，直接位于右上角
    Row {
        id:                     topRightButtons
        anchors.top:            parent.top
        anchors.topMargin:      _layoutMargin
        anchors.right:          parent.right
        anchors.rightMargin:    _layoutMargin
        spacing:                ScreenTools.defaultFontPixelWidth * 0.5
        visible:                !QGroundControl.videoManager.fullScreen

        property real _buttonWidth:      ScreenTools.defaultFontPixelWidth * 7
        property real _imageScale:       0.5

        //任务按钮，位于通用按钮左侧
        Rectangle {
            id:                 missionButton
            width:              topRightButtons._buttonWidth
            height:             width
            radius:             ScreenTools.defaultFontPixelWidth / 2
            color:              (missionButtonMA.pressed || missionButtonMA.containsMouse) ?
                                    qgcPal.buttonHighlight : qgcPal.toolbarBackground

            Column {
                anchors.centerIn:   parent
                spacing:            ScreenTools.defaultFontPixelHeight * 0.1

                //任务图标
                Image {
                    width:                  topRightButtons._buttonWidth * topRightButtons._imageScale
                    height:                 width
                    source:                 "/xfressvg/mission.svg"
                    fillMode:               Image.PreserveAspectFit
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                //文字标签
                QGCLabel {
                    text:                       qsTr("Mission")
                    color:                      (missionButtonMA.pressed || missionButtonMA.containsMouse) ?
                                                qgcPal.buttonHighlightText : qgcPal.buttonText
                    font.pointSize:             ScreenTools.smallFontPointSize
                    anchors.horizontalCenter:   parent.horizontalCenter
                }
            }

            //点击区域
            QGCMouseArea {
                id:         missionButtonMA
                fillItem:   parent
                onClicked: {
                    mainWindow.showXFMissionView()
                }
            }
        }

        //通用按钮，位于右上角
        Rectangle {
            id:                 commonButton
            width:              topRightButtons._buttonWidth
            height:             width
            radius:             ScreenTools.defaultFontPixelWidth / 2
            color:              (commonButtonMA.pressed || commonButtonMA.containsMouse) ?
                                    qgcPal.buttonHighlight : qgcPal.toolbarBackground

            Column {
                anchors.centerIn:   parent
                spacing:            ScreenTools.defaultFontPixelHeight * 0.1

                //通用图标
                Image {
                    width:                  topRightButtons._buttonWidth * topRightButtons._imageScale
                    height:                 width
                    source:                 "/xfressvg/common.svg"
                    fillMode:               Image.PreserveAspectFit
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                //文字标签
                QGCLabel {
                    text:                       qsTr("Common")
                    color:                      (commonButtonMA.pressed || commonButtonMA.containsMouse) ?
                                                qgcPal.buttonHighlightText : qgcPal.buttonText
                    font.pointSize:             ScreenTools.smallFontPointSize
                    anchors.horizontalCenter:   parent.horizontalCenter
                }
            }

            //点击区域
            QGCMouseArea {
                id:         commonButtonMA
                fillItem:   parent
                onClicked: {
                    mainWindow.showXFCommonView()
                }
            }
        }
    }

    //右上角列布局，显示简化飞行仪表（当右上角面板隐藏时）
    FlyViewTopRightColumnLayout {
        id:                 topRightColumnLayout
        anchors.margins:    _layoutMargin
        anchors.top:        parent.top
        anchors.bottom:     bottomRightRowLayout.top
        anchors.right:      parent.right
        spacing:            _layoutSpacing
        visible:           false && !topRightPanel.visible

        property real topEdgeRightInset:    childrenRect.height + _layoutMargin
        property real rightEdgeTopInset:    width + _layoutMargin
        property real rightEdgeCenterInset: rightEdgeTopInset
    }

    //右下角行布局，显示多机列表、引导动作按钮等，位于底部中间
    FlyViewBottomRightRowLayout {
        id:                 bottomRightRowLayout
        anchors.bottomMargin: _layoutMargin
        anchors.bottom:     parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        spacing:            _layoutSpacing

        property real bottomEdgeCenterInset:    height + _layoutMargin
        property real bottomEdgeRightInset:     bottomEdgeCenterInset
        property real rightEdgeBottomInset:     0  // 不再在右侧，边距为0
    }

    FlyViewMissionCompleteDialog {
        missionController:      _missionController
        geoFenceController:     _geoFenceController
        rallyPointController:   _rallyPointController
    }

    GuidedActionConfirm {
        anchors.margins:            _toolsMargin
        anchors.top:                parent.top
        anchors.horizontalCenter:   parent.horizontalCenter
        z:                          QGroundControl.zOrderTopMost
        guidedController:           _guidedController
        guidedValueSlider:          _guidedValueSlider
        utmspSliderTrigger:         utmspActTrigger
    }

    //-- Virtual Joystick
    Loader {
        id:                         virtualJoystickMultiTouch
        z:                          QGroundControl.zOrderTopMost + 1
        anchors.right:              parent.right
        anchors.rightMargin:        anchors.leftMargin
        height:                     Math.min(parent.height * 0.25, ScreenTools.defaultFontPixelWidth * 16)
        visible:                    _virtualJoystickEnabled && !QGroundControl.videoManager.fullScreen && !(_activeVehicle ? _activeVehicle.usingHighLatencyLink : false)
        anchors.bottom:             parent.bottom
        anchors.bottomMargin:       bottomLoaderMargin
        anchors.left:               parent.left   
        anchors.leftMargin:         ( y > flightActionButtons.y + flightActionButtons.height ? flightActionButtons.width / 2 : flightActionButtons.width * 1.05 + flightActionButtons.x) 
        source:                     "qrc:/qml/QGroundControl/FlightDisplay/VirtualJoystick.qml"
        active:                     _virtualJoystickEnabled && !(_activeVehicle ? _activeVehicle.usingHighLatencyLink : false)

        property real bottomEdgeLeftInset:     parent.height-y
        property bool autoCenterThrottle:      QGroundControl.settingsManager.appSettings.virtualJoystickAutoCenterThrottle.rawValue
        property bool leftHandedMode:          QGroundControl.settingsManager.appSettings.virtualJoystickLeftHandedMode.rawValue
        property bool _virtualJoystickEnabled: QGroundControl.settingsManager.appSettings.virtualJoystick.rawValue
        property real bottomEdgeRightInset:    parent.height-y
        property var  _pipViewMargin:          _pipView.visible ? parentToolInsets.bottomEdgeLeftInset + ScreenTools.defaultFontPixelHeight * 2 : 
                                               bottomRightRowLayout.height + ScreenTools.defaultFontPixelHeight * 1.5

        property var  bottomLoaderMargin:      _pipViewMargin >= parent.height / 2 ? parent.height / 2 : _pipViewMargin

        // Width is difficult to access directly hence this hack which may not work in all circumstances
        property real leftEdgeBottomInset:  visible ? bottomEdgeLeftInset + width/18 - ScreenTools.defaultFontPixelHeight*2 : 0
        property real rightEdgeBottomInset: visible ? bottomEdgeRightInset + width/18 - ScreenTools.defaultFontPixelHeight*2 : 0
        property real rootWidth:            _root.width
        property var  itemX:                virtualJoystickMultiTouch.x   // real X on screen

        onRootWidthChanged: virtualJoystickMultiTouch.status == Loader.Ready && visible ? virtualJoystickMultiTouch.item.uiTotalWidth = rootWidth : undefined
        onItemXChanged:     virtualJoystickMultiTouch.status == Loader.Ready && visible ? virtualJoystickMultiTouch.item.uiRealX = itemX : undefined

        //Loader status logic
        onLoaded: {
            if (virtualJoystickMultiTouch.visible) {
                virtualJoystickMultiTouch.item.calibration = true 
                virtualJoystickMultiTouch.item.uiTotalWidth = rootWidth
                virtualJoystickMultiTouch.item.uiRealX = itemX
            } else {
                virtualJoystickMultiTouch.item.calibration = false
            }
        }
    }

    //左侧飞行操作按钮（检查、起飞/降落、返航），位于左上角
    Column {
        id:                     flightActionButtons
        anchors.leftMargin:     _toolsMargin + parentToolInsets.leftEdgeCenterInset
        anchors.topMargin:      _toolsMargin + parentToolInsets.topEdgeLeftInset
        anchors.left:           parent.left
        anchors.top:            parent.top
        z:                      QGroundControl.zOrderWidgets
        spacing:                ScreenTools.defaultFontPixelWidth * 0.25
        visible:                !QGroundControl.videoManager.fullScreen

        property var    _guidedController: globals.guidedControllerFlyView
        property real   _buttonWidth:      ScreenTools.defaultFontPixelWidth * 7
        property real   _imageScale:       0.5
        property bool   _checkPopupVisible: false

        //检查按钮，显示系统状态检查，点击弹出检查详情面板（第一个位置）
        Rectangle {
            id:                 checkButton
            width:              flightActionButtons._buttonWidth
            height:             width
            radius:             ScreenTools.defaultFontPixelWidth / 2
            color:              (checkButtonMA.pressed || checkButtonMA.containsMouse) ?
                                    qgcPal.buttonHighlight : qgcPal.toolbarBackground

            property var    _activeVehicle:             QGroundControl.multiVehicleManager.activeVehicle
            property bool   _communicationLost:         _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
            property bool   _healthAndArmingSupported:  _activeVehicle ? _activeVehicle.healthAndArmingCheckReport.supported : false

            //状态颜色名称（字符串）
            property string _statusColorName: "default"

            //状态颜色对象（根据名称转换）
            property color _statusColorObj: {
                if (_statusColorName === "red") return "red"
                if (_statusColorName === "yellow") return "yellow"
                if (_statusColorName === "green") return "green"
                return qgcPal.toolbarBackground
            }

            //状态颜色更新函数，与toolbar的updateMainStatusBGColor逻辑一致
            function updateStatusColor() {
                if (!_activeVehicle) {
                    _statusColorName = "default"
                    return
                }
                if (_communicationLost) {
                    _statusColorName = "red"
                    return
                }
                if (_healthAndArmingSupported) {
                    if (!_activeVehicle.healthAndArmingCheckReport.canArm) {
                        _statusColorName = "red"
                    } else if (_activeVehicle.healthAndArmingCheckReport.hasWarningsOrErrors) {
                        _statusColorName = "yellow"
                    } else {
                        _statusColorName = "green"
                    }
                } else {
                    //当不支持healthAndArming检查时，默认显示绿色
                    _statusColorName = "green"
                }
            }

            //状态图标路径，根据颜色名称返回对应的check图标
            property string _statusIcon: {
                if (_statusColorName === "red") return "/xfressvg/checkRed.svg"
                if (_statusColorName === "yellow") return "/xfressvg/checkOrange.svg"
                if (_statusColorName === "green") return "/xfressvg/checkGreen.svg"
                return "/xfressvg/checkWhite.svg"
            }

            visible:            true

            Connections {
                target: _activeVehicle
                function onArmedChanged() { checkButton.updateStatusColor() }
                function onFlyingChanged() { checkButton.updateStatusColor() }
            }

            Connections {
                target: _activeVehicle ? _activeVehicle.healthAndArmingCheckReport : null
                function onUpdated() { checkButton.updateStatusColor() }
            }

            Connections {
                target: QGroundControl.multiVehicleManager
                function onActiveVehicleChanged() { checkButton.updateStatusColor() }
            }

            Component.onCompleted: checkButton.updateStatusColor()

            Column {
                anchors.centerIn:   parent
                spacing:            ScreenTools.defaultFontPixelHeight * 0.1

                //检查图标（使用XF图标，颜色随状态变化）
                Image {
                    width:                  flightActionButtons._buttonWidth * flightActionButtons._imageScale
                    height:                 width
                    source:                 checkButton._statusIcon
                    fillMode:               Image.PreserveAspectFit
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                //文字标签
                QGCLabel {
                    text:                       qsTr("Check")
                    color:                      (checkButtonMA.pressed || checkButtonMA.containsMouse) ?
                                                qgcPal.buttonHighlightText : qgcPal.text
                    font.pointSize:             ScreenTools.smallFontPointSize
                    anchors.horizontalCenter:   parent.horizontalCenter
                }
            }

            //点击区域
            QGCMouseArea {
                id:         checkButtonMA
                fillItem:   parent
                onClicked: {
                    flightActionButtons._checkPopupVisible = !flightActionButtons._checkPopupVisible
                }
            }
        }

        //起飞/降落切换按钮，根据飞行状态切换显示，显示图标+文字
        Rectangle {
            id:                 takeoffLandButton
            width:              flightActionButtons._buttonWidth
            height:             width
            radius:             ScreenTools.defaultFontPixelWidth / 2
            color:              (takeoffLandButtonMA.pressed || takeoffLandButtonMA.containsMouse) ?
                                    qgcPal.buttonHighlight : qgcPal.toolbarBackground

            property bool _showTakeoff: flightActionButtons._guidedController.showTakeoff
            property bool _showLand:    flightActionButtons._guidedController.showLand
            property string _buttonText: _showTakeoff ? qsTr("Takeoff") : qsTr("Land")

            visible:            takeoffLandButton._showTakeoff || takeoffLandButton._showLand

            Column {
                anchors.centerIn:   parent
                spacing:            ScreenTools.defaultFontPixelHeight * 0.1

                //起飞/降落图标（使用XF图标）
                Image {
                    width:                  flightActionButtons._buttonWidth * flightActionButtons._imageScale
                    height:                 width
                    source:                 takeoffLandButton._showTakeoff ? "/xfressvg/takeoff-enabled.svg" : "/xfressvg/land.svg"
                    fillMode:               Image.PreserveAspectFit
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                //文字标签
                QGCLabel {
                    text:                       takeoffLandButton._buttonText
                    color:                      (takeoffLandButtonMA.pressed || takeoffLandButtonMA.containsMouse) ?
                                                qgcPal.buttonHighlightText : qgcPal.buttonText
                    font.pointSize:             ScreenTools.smallFontPointSize
                    anchors.horizontalCenter:   parent.horizontalCenter
                }
            }

            //点击区域
            QGCMouseArea {
                id:         takeoffLandButtonMA
                fillItem:   parent
                onClicked: {
                    flightActionButtons._checkPopupVisible = false  //关闭检查弹窗
                    flightActionButtons._guidedController.closeAll()
                    if (takeoffLandButton._showTakeoff) {
                        flightActionButtons._guidedController.confirmAction(flightActionButtons._guidedController.actionTakeoff)
                    } else {
                        flightActionButtons._guidedController.confirmAction(flightActionButtons._guidedController.actionLand)
                    }
                }
            }
        }

        //返航按钮，触发返航操作，显示图标+文字
        Rectangle {
            id:                 rtlButton
            width:              flightActionButtons._buttonWidth
            height:             width
            radius:             ScreenTools.defaultFontPixelWidth / 2
            color:              (rtlButtonMA.pressed || rtlButtonMA.containsMouse) ?
                                    qgcPal.buttonHighlight : qgcPal.toolbarBackground

            property bool _showRTL: flightActionButtons._guidedController.showRTL

            visible:            true
            opacity:            rtlButton._showRTL ? 1 : 0.5

            Column {
                anchors.centerIn:   parent
                spacing:            ScreenTools.defaultFontPixelHeight * 0.1

                //返航图标（使用XF图标）
                Image {
                    width:                  flightActionButtons._buttonWidth * flightActionButtons._imageScale
                    height:                 width
                    source:                 rtlButton._showRTL ? "/xfressvg/rtl-flying.svg" : "/xfres/rtl-not-flying.png"
                    fillMode:               Image.PreserveAspectFit
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                //文字标签
                QGCLabel {
                    text:                       qsTr("RTL")
                    color:                      (rtlButtonMA.pressed || rtlButtonMA.containsMouse) ?
                                                qgcPal.buttonHighlightText : qgcPal.buttonText
                    font.pointSize:             ScreenTools.smallFontPointSize
                    anchors.horizontalCenter:   parent.horizontalCenter
                }
            }

            //点击区域
            QGCMouseArea {
                id:         rtlButtonMA
                fillItem:   parent
                enabled:    rtlButton._showRTL
                onClicked: {
                    flightActionButtons._checkPopupVisible = false  //关闭检查弹窗
                    flightActionButtons._guidedController.closeAll()
                    flightActionButtons._guidedController.confirmAction(flightActionButtons._guidedController.actionRTL)
                }
            }
        }
    }

    //检查详情弹窗，直接显示在按钮右侧，无边框无底色
    Rectangle {
        id:                     flightCheckPopup
        anchors.left:           flightActionButtons.right
        anchors.top:            flightActionButtons.top
        anchors.leftMargin:     ScreenTools.defaultFontPixelWidth * 0.5
        z:                      QGroundControl.zOrderTopMost
        visible:                flightActionButtons._checkPopupVisible
        width:                  checkContent.width + ScreenTools.defaultFontPixelWidth * 2
        height:                 Math.min(_root.height - y, checkContent.height + ScreenTools.defaultFontPixelHeight)
        color:                  "transparent"
        border.width:           0

        MouseArea {
            anchors.fill:       parent
            onPressed: {
            }
        }

        QGCFlickable {
            id:                 checkFlickable
            anchors.fill:       parent
            flickableDirection: Flickable.VerticalFlick
            contentWidth:       checkContent.width
            contentHeight:      checkContent.height

            WheelHandler {
                onWheel: (event) => event.accepted = true
            }

            FlightCheckContent {
                id:             checkContent
                activeVehicle:  QGroundControl.multiVehicleManager.activeVehicle
            }
        }
    }

    //全局遮罩，点击弹窗外部区域时关闭弹窗
    MouseArea {
        anchors.fill:       parent
        z:                  QGroundControl.zOrderWidgets
        visible:            flightActionButtons._checkPopupVisible
        onPressed: {
            flightActionButtons._checkPopupVisible = false
        }
        //允许点击事件传递到下层控件（除了弹窗区域）
        propagateComposedEvents: true
    }

    //悬浮工具栏，可拖动，展开/收起切换，自动判断延伸方向
    FlyViewFloatingToolBar {
        id:                     floatingToolBar
        visible:                !QGroundControl.videoManager.fullScreen
        anchors.left:            flightActionButtons.left
        anchors.top:             flightActionButtons.bottom
        anchors.topMargin:       _toolsMargin

        onCenterOnVehicle: {
            if (_activeVehicle && _activeVehicle.coordinate.isValid) {
                mapControl._disableVehicleTracking = false
                mapControl.animatedMapRecenter(mapControl.center, _activeVehicle.coordinate)
            }
        }

        onCenterOnGCS: {
            var gcsPos = QGroundControl.qgcPositionManger.gcsPosition
            if (gcsPos.isValid) {
                mapControl._disableVehicleTracking = true
                mapControl.animatedMapRecenter(mapControl.center, gcsPos)
            }
        }

        onMeasureDistance: (active) => {
            mapControl.measureMode = active
        }
    }

    //原左侧工具条（已隐藏）
    FlyViewToolStrip {
        id:                     toolStrip
        anchors.leftMargin:     _toolsMargin + parentToolInsets.leftEdgeCenterInset
        anchors.topMargin:      _toolsMargin + parentToolInsets.topEdgeLeftInset
        anchors.left:           parent.left
        anchors.top:            parent.top
        z:                      QGroundControl.zOrderWidgets
        maxHeight:              parent.height - y - parentToolInsets.bottomEdgeLeftInset - _toolsMargin
        visible:                false  //隐藏原工具条，使用自定义按钮

        onDisplayPreFlightChecklist: {
            if (!preFlightChecklistLoader.active) {
                preFlightChecklistLoader.active = true
            }
            preFlightChecklistLoader.item.open()
        }

        property real topEdgeLeftInset:     visible ? y + height : 0
        property real leftEdgeTopInset:     visible ? x + width : 0
        property real leftEdgeCenterInset:  leftEdgeTopInset
    }

    GripperMenu {
        id: gripperOptions
    }

    VehicleWarnings {
        anchors.centerIn:   parent
        z:                  QGroundControl.zOrderTopMost
    }

    MapScale {
        id:                 mapScale
        anchors.margins:    _toolsMargin
        anchors.left:       flightActionButtons.right
        anchors.top:        parent.top
        mapControl:         _mapControl
        buttonsOnLeft:      true
        zoomButtonsVisible: false
        visible:            false

        property real topEdgeCenterInset: visible ? y + height : 0
    }

    Loader {
        id: preFlightChecklistLoader
        sourceComponent: preFlightChecklistPopup
        active: false
    }

    Component {
        id: preFlightChecklistPopup
        FlyViewPreFlightChecklistPopup {
        }
    }
}
