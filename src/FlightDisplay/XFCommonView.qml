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
import QGroundControl.Palette
import QGroundControl.ScreenTools

//通用页面主容器，覆盖整个窗口，显示通用配置界面
//包含左侧导航面板、右侧内容区域、顶部返回按钮
//左侧导航面板包含8个子页面项：连接、设备配置、飞行参数、安全、设备日志、Mavlink Console、Mavlink Analyze、软件设置
Rectangle {
    id:                 xfCommonView
    anchors.fill:       parent
    visible:            false
    color:              qgcPal.window
    z:                  QGroundControl.zOrderTopMost

    //当前选中的页面索引
    property int        currentPageIndex:          0

    //页面列表数据
    property var        pageList: [
        { name: qsTr("连接"), url: "qrc:/qml/QGroundControl/AppSettings/LinkSettings.qml" },
        { name: qsTr("设备配置"), url: "" },  // 特殊处理，有二级菜单
        { name: qsTr("飞行参数"), url: "qrc:/qml/QGroundControl/AppSettings/FlyViewSettings.qml" },
        { name: qsTr("安全"), url: "qrc:/qml/QGroundControl/AppSettings/RemoteIDSettings.qml" },
        { name: qsTr("设备日志"), url: "qrc:/qml/QGroundControl/AnalyzeView/LogDownloadPage.qml" },
        { name: qsTr("Mavlink Console"), url: "qrc:/qml/QGroundControl/AnalyzeView/MAVLinkConsolePage.qml" },
        { name: qsTr("Mavlink Analyze"), url: "qrc:/qml/QGroundControl/AnalyzeView/MAVLinkInspectorPage.qml" },
        { name: qsTr("软件设置"), url: "qrc:/qml/QGroundControl/AppSettings/GeneralSettings.qml" }
    ]

    //设备配置二级菜单页面列表
    property var        deviceConfigPages: [
        { name: qsTr("概况"), url: "qrc:/qml/QGroundControl/VehicleSetup/VehicleSummary.qml" },
        { name: qsTr("机架"), url: "" },  // 动态加载
        { name: qsTr("传感器"), url: "" },  // 动态加载
        { name: qsTr("通道设置"), url: "" },  // 动态加载
        { name: qsTr("电源"), url: "" },  // 动态加载
        { name: qsTr("电机"), url: "" },  // 动态加载
        { name: qsTr("遥控器"), url: "qrc:/qml/QGroundControl/VehicleSetup/JoystickConfig.qml" },
        { name: qsTr("PID调参"), url: "" },  // 动态加载
        { name: qsTr("参数"), url: "qrc:/qml/QGroundControl/VehicleSetup/SetupParameterEditor.qml" }
    ]

    //设备配置二级菜单是否展开
    property bool       deviceConfigExpanded:      false
    //当前设备配置二级菜单索引
    property int        currentDeviceConfigIndex:  0

    QGCPalette { id: qgcPal }

    //阻塞鼠标区域，防止点击事件穿透到下层
    DeadMouseArea {
        anchors.fill:   parent
    }

    //顶部返回按钮区域
    Rectangle {
        id:                 toolbar
        anchors.top:        parent.top
        anchors.left:       parent.left
        anchors.right:      parent.right
        height:             ScreenTools.toolbarHeight
        color:              qgcPal.toolbarBackground

        RowLayout {
            anchors.leftMargin:     ScreenTools.defaultFontPixelWidth
            anchors.left:           parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing:                ScreenTools.defaultFontPixelWidth

            //返回图标
            QGCLabel {
                text:               "<"
                font.pointSize:     ScreenTools.largeFontPointSize
            }

            //返回文字
            QGCLabel {
                text:               qsTr("Exit 通用配置")
                font.pointSize:     ScreenTools.largeFontPointSize
            }
        }

        //点击返回
        QGCMouseArea {
            anchors.fill:       parent
            onClicked: {
                if (mainWindow.allowViewSwitch()) {
                    xfCommonView.visible = false
                    mainWindow.showFlyView()
                }
            }
        }
    }

    //左侧导航面板
    XFCommonLeftPanel {
        id:                 leftPanel
        anchors.left:       parent.left
        anchors.top:        toolbar.bottom
        anchors.bottom:     parent.bottom
        width:              ScreenTools.defaultFontPixelWidth * 18

        currentPageIndex:       xfCommonView.currentPageIndex
        deviceConfigExpanded:   xfCommonView.deviceConfigExpanded
        currentDeviceConfigIndex: xfCommonView.currentDeviceConfigIndex

        onPageSelected: function(index) {
            xfCommonView.currentPageIndex = index
            xfCommonView.deviceConfigExpanded = false
            if (xfCommonView.pageList[index].url !== "") {
                contentLoader.source = xfCommonView.pageList[index].url
            }
        }

        onDeviceConfigSelected: function(subIndex) {
            xfCommonView.currentPageIndex = 1  // 设备配置页
            xfCommonView.deviceConfigExpanded = true
            xfCommonView.currentDeviceConfigIndex = subIndex
            if (xfCommonView.deviceConfigPages[subIndex].url !== "") {
                contentLoader.source = xfCommonView.deviceConfigPages[subIndex].url
            }
        }

        onBackToMainPage: function() {
            xfCommonView.deviceConfigExpanded = false
        }
    }

    //分隔线
    Rectangle {
        anchors.left:       leftPanel.right
        anchors.top:        toolbar.bottom
        anchors.bottom:     parent.bottom
        width:              1
        color:              qgcPal.windowShade
    }

    //右侧内容区域
    Item {
        anchors.left:       leftPanel.right
        anchors.leftMargin: ScreenTools.defaultFontPixelWidth
        anchors.right:      parent.right
        anchors.top:        toolbar.bottom
        anchors.topMargin:  ScreenTools.defaultFontPixelWidth
        anchors.bottom:     parent.bottom

        //内容加载器
        Loader {
            id:                 contentLoader
            anchors.fill:       parent
            source:             xfCommonView.pageList[0].url  // 默认加载连接页面

            //显示当前页面名称（占位符）
            QGCLabel {
                anchors.centerIn:   parent
                text:               xfCommonView.pageList[xfCommonView.currentPageIndex].name
                font.pointSize:     ScreenTools.largeFontPointSize
                visible:            contentLoader.status !== Loader.Ready
            }
        }
    }
}