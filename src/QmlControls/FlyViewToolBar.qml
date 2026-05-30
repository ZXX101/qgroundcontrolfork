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
import QtQuick.Dialogs

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.MultiVehicleManager
import QGroundControl.ScreenTools
import QGroundControl.Controllers
import QGroundControl.Toolbar

//顶部飞行工具栏，位于飞行界面顶部，显示Logo、飞行模式、消息指示器、GPS、电池、计时器等
//包含以下部件：
//  1. viewButtonRow 左侧按钮行 - Logo按钮、飞行模式指示器、消息指示器
//  2. rightIndicatorsRow 右侧指示器行 - GPS指示器、电池指示器、计时器指示器
//  3. toolsFlickable 中间滚动区域 - 显示动态工具指示器
//  4. background gradient 背景渐变 - 根据飞行状态改变颜色
Rectangle {
    id:     _root
    width:  parent.width
    height: ScreenTools.toolbarHeight
    color:  qgcPal.toolbarBackground

    property var    _activeVehicle:             QGroundControl.multiVehicleManager.activeVehicle
    property bool   _communicationLost:         _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property bool   _healthAndArmingSupported:  _activeVehicle ? _activeVehicle.healthAndArmingCheckReport.supported : false
    property color  _mainStatusBGColor:         qgcPal.brandingPurple

    function updateMainStatusBGColor() {
        if (!_activeVehicle) {
            _mainStatusBGColor = qgcPal.brandingPurple
            return
        }
        if (_communicationLost) {
            _mainStatusBGColor = "red"
            return
        }
        if (_activeVehicle.armed) {
            if (_healthAndArmingSupported && !_activeVehicle.healthAndArmingCheckReport.canArm) {
                _mainStatusBGColor = "red"
            } else if (_healthAndArmingSupported && _activeVehicle.healthAndArmingCheckReport.hasWarningsOrErrors) {
                _mainStatusBGColor = "yellow"
            } else {
                _mainStatusBGColor = "green"
            }
        } else {
            if (_healthAndArmingSupported && !_activeVehicle.healthAndArmingCheckReport.canArm) {
                _mainStatusBGColor = "red"
            } else if (_healthAndArmingSupported && _activeVehicle.healthAndArmingCheckReport.hasWarningsOrErrors) {
                _mainStatusBGColor = "yellow"
            } else {
                _mainStatusBGColor = "green"
            }
        }
    }

    Connections {
        target: _activeVehicle
        function onArmedChanged() { updateMainStatusBGColor() }
        function onFlyingChanged() { updateMainStatusBGColor() }
    }

    Connections {
        target: _activeVehicle ? _activeVehicle.healthAndArmingCheckReport : null
        function onUpdated() { updateMainStatusBGColor() }
    }

    Connections {
        target: QGroundControl.multiVehicleManager
        function onActiveVehicleChanged() { updateMainStatusBGColor() }
    }

    Component.onCompleted: updateMainStatusBGColor()

    function dropMainStatusIndicatorTool() {
        // flightModeIndicator.dropMainStatusIndicator();
    }

    QGCPalette { id: qgcPal }

    //底部单像素分隔线，仅浅色主题显示
    /// Bottom single pixel divider
    Rectangle {
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        height:         1
        color:          "black"
        visible:        qgcPal.globalTheme === QGCPalette.Light
    }

    //背景渐变矩形，根据飞行状态显示不同颜色（绿色=正常、黄色=警告、红色=错误）
    Rectangle {
        anchors.top:        viewButtonRow.top
        anchors.bottom:     viewButtonRow.bottom
        anchors.left:       viewButtonRow.left
        width:              viewButtonRow.width * 1.3

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0;                                                     color: _mainStatusBGColor }
            // GradientStop { position: (currentButton.x + currentButton.width) / width;      color: _mainStatusBGColor }
            GradientStop { position: viewButtonRow.width / width;                          color: _mainStatusBGColor }
            GradientStop { position: 1;                                                     color: _root.color }
        }
    }

    //左侧按钮行，包含Logo按钮、飞行模式指示器、消息指示器
    RowLayout {
        id:                     viewButtonRow
        anchors.bottomMargin:   1
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        spacing:                ScreenTools.defaultFontPixelWidth / 2

        //Logo按钮，显示应用Logo，点击弹出工具选择菜单
        QGCToolBarButton {
            id:                     currentButton
            Layout.preferredHeight: viewButtonRow.height
            icon.source:            "/xfres/LogoFull.png"
            logo:                   true
            onClicked:              mainWindow.showToolSelectDialog()
        }

        //飞行模式指示器，带背景色，显示当前飞行模式和状态
        FlightModeIndicator {
            id:                 flightModeIndicator
            Layout.preferredHeight: viewButtonRow.height
            fontPointSize:      ScreenTools.largeFontPointSize
        }

        //车辆消息指示器，显示车辆警告/错误消息
        VehicleMessagesIndicator {
            Layout.fillHeight:  true
            Layout.leftMargin:  ScreenTools.defaultFontPixelWidth * 5
        }

        //断开连接的按钮，只在连接断开时出现，保留。
        QGCButton {
            id:                 disconnectButton
            text:               qsTr("Disconnect")
            onClicked:          _activeVehicle.closeVehicle()
            visible:            false && _activeVehicle && _communicationLost
        }
    }

    //右侧固定指示器区域：GPS、电池、计时器，位于工具栏右侧
    Row {
        id:                     rightIndicatorsRow
        anchors.right:          parent.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.rightMargin:    ScreenTools.defaultFontPixelWidth / 2
        spacing:                ScreenTools.defaultFontPixelWidth

        //GPS指示器，显示卫星数和HDOP精度
        VehicleGPSIndicator {
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            showIndicator:      true
        }

        //电池指示器，显示电池电压和剩余电量
        BatteryIndicator {
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            showIndicator:      true
        }

        //计时器指示器，显示飞行计时
        TimerIndicator {
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
        }
    }

    //中间可滚动指示器区域，显示动态工具指示器，位于左侧按钮行和右侧指示器之间
    //这里放的是主状态指示器右侧的所有控件，现在统一移动到右侧，并且常驻显示。
    QGCFlickable {
        id:                     toolsFlickable
        anchors.leftMargin:     ScreenTools.defaultFontPixelWidth * ScreenTools.largeFontPointRatio * 1.5
        anchors.rightMargin:    ScreenTools.defaultFontPixelWidth / 2
        anchors.left:           viewButtonRow.right
        anchors.bottomMargin:   1
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.right:          rightIndicatorsRow.left
        contentWidth:           toolIndicators.width
        flickableDirection:     Flickable.HorizontalFlick

        //工具栏指示器集合，显示车辆状态指示器
        FlyViewToolBarIndicators { id: toolIndicators }
    }

    //-------------------------------------------------------------------------
    //-- Branding Logo
    //品牌Logo图片，位于工具栏右侧，显示自定义或车辆品牌图片（已隐藏）
    Image {
        anchors.right:          parent.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.margins:        ScreenTools.defaultFontPixelHeight * 0.66
        visible:                false && _activeVehicle && !_communicationLost && x > (toolsFlickable.x + toolsFlickable.contentWidth + ScreenTools.defaultFontPixelWidth)
        fillMode:               Image.PreserveAspectFit
        source:                 _outdoorPalette ? _brandImageOutdoor : _brandImageIndoor
        mipmap:                 true

        property bool   _outdoorPalette:        qgcPal.globalTheme === QGCPalette.Light
        property bool   _corePluginBranding:    QGroundControl.corePlugin.brandImageIndoor.length != 0
        property string _userBrandImageIndoor:  QGroundControl.settingsManager.brandImageSettings.userBrandImageIndoor.value
        property string _userBrandImageOutdoor: QGroundControl.settingsManager.brandImageSettings.userBrandImageOutdoor.value
        property bool   _userBrandingIndoor:    QGroundControl.settingsManager.brandImageSettings.visible && _userBrandImageIndoor.length != 0
        property bool   _userBrandingOutdoor:   QGroundControl.settingsManager.brandImageSettings.visible && _userBrandImageOutdoor.length != 0
        property string _brandImageIndoor:      brandImageIndoor()
        property string _brandImageOutdoor:     brandImageOutdoor()

        function brandImageIndoor() {
            if (_userBrandingIndoor) {
                return _userBrandImageIndoor
            } else {
                if (_userBrandingOutdoor) {
                    return _userBrandImageOutdoor
                } else {
                    if (_corePluginBranding) {
                        return QGroundControl.corePlugin.brandImageIndoor
                    } else {
                        return _activeVehicle ? _activeVehicle.brandImageIndoor : ""
                    }
                }
            }
        }

        function brandImageOutdoor() {
            if (_userBrandingOutdoor) {
                return _userBrandImageOutdoor
            } else {
                if (_userBrandingIndoor) {
                    return _userBrandImageIndoor
                } else {
                    if (_corePluginBranding) {
                        return QGroundControl.corePlugin.brandImageOutdoor
                    } else {
                        return _activeVehicle ? _activeVehicle.brandImageOutdoor : ""
                    }
                }
            }
        }
    }

    // Small parameter download progress bar
    //参数下载进度条（小），位于工具栏底部，显示参数下载进度
    Rectangle {
        anchors.bottom: parent.bottom
        height:         _root.height * 0.05
        width:          _activeVehicle ? _activeVehicle.loadProgress * parent.width : 0
        color:          qgcPal.colorGreen
        visible:        !largeProgressBar.visible
    }

    // Large parameter download progress bar
    //参数下载进度条（大），覆盖整个工具栏，显示初始参数下载进度
    Rectangle {
        id:             largeProgressBar
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        height:         parent.height
        color:          qgcPal.window
        visible:        _showLargeProgress

        property bool _initialDownloadComplete: _activeVehicle ? _activeVehicle.initialConnectComplete : true
        property bool _userHide:                false
        property bool _showLargeProgress:       !_initialDownloadComplete && !_userHide && qgcPal.globalTheme === QGCPalette.Light

        Connections {
            target:                 QGroundControl.multiVehicleManager
            function onActiveVehicleChanged(activeVehicle) { largeProgressBar._userHide = false }
        }

        //进度条内容，显示下载进度百分比
        Rectangle {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            width:          _activeVehicle ? _activeVehicle.loadProgress * parent.width : 0
            color:          qgcPal.colorGreen
        }

        //下载状态标签，显示"Downloading"
        QGCLabel {
            anchors.centerIn:   parent
            text:               qsTr("Downloading")
            font.pointSize:     ScreenTools.largeFontPointSize
        }

        //隐藏提示标签，显示"Click anywhere to hide"
        QGCLabel {
            anchors.margins:    _margin
            anchors.right:      parent.right
            anchors.bottom:     parent.bottom
            text:               qsTr("Click anywhere to hide")

            property real _margin: ScreenTools.defaultFontPixelWidth / 2
        }

        //点击隐藏区域，点击后隐藏进度条
        MouseArea {
            anchors.fill:   parent
            onClicked:      largeProgressBar._userHide = true
        }
    }
}
