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

//顶部规划工具栏，位于规划界面顶部，显示退出按钮、规划状态指示器、同步进度条等
//包含以下部件：
//  1. viewButtonRow 左侧按钮行 - 退出按钮，点击返回飞行界面
//  2. toolsFlickable 中间滚动区域 - 显示规划状态指示器
//  3. progressBar 进度条 - 显示任务同步进度
Rectangle {
    id:     _root
    width:  parent.width
    height: ScreenTools.toolbarHeight
    color:  qgcPal.toolbarBackground

    property var    planMasterController

    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property real   _controllerProgressPct: planMasterController.missionController.progressPct

    //全局调色板功能组件，提供UI颜色方案
    QGCPalette { id: qgcPal }

    /// Bottom single pixel divider
    //底部单像素分隔线，仅浅色主题显示
    Rectangle {
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        height:         1
        color:          "black"
        visible:        qgcPal.globalTheme === QGCPalette.Light
    }

    //左侧按钮行，包含退出按钮，点击返回飞行界面
    RowLayout {
        id:                     viewButtonRow
        anchors.bottomMargin:   1
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        spacing:                ScreenTools.defaultFontPixelWidth / 2

        //退出箭头标签
        QGCLabel {
            font.pointSize: ScreenTools.largeFontPointSize
            text:           "<"
        }

        //退出文字标签
        QGCLabel {
            text:           qsTr("Exit Plan")
            font.pointSize: ScreenTools.largeFontPointSize
        }
    }

    //退出按钮点击区域，点击返回飞行界面
    QGCMouseArea {
        anchors.fill:   viewButtonRow
        onClicked:      mainWindow.showFlyView()
    }

    //中间可滚动指示器区域，显示规划状态指示器
    QGCFlickable {
        id:                     toolsFlickable
        //anchors.leftMargin:     ScreenTools.defaultFontPixelWidth * ScreenTools.largeFontPointRatio * 1.5
        anchors.left:           viewButtonRow.right
        anchors.bottomMargin:   1
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.right:          parent.right
        contentWidth:           toolIndicators.width
        flickableDirection:     Flickable.HorizontalFlick

        //规划工具栏指示器集合，显示规划状态信息
        PlanToolBarIndicators {
            id:                     toolIndicators
            anchors.top:            parent.top
            anchors.bottom:         parent.bottom
            planMasterController:   _root.planMasterController
        }
    }

    // Small mission download progress bar
    //任务同步进度条（小），位于工具栏底部，显示同步进度
    Rectangle {
        id:             progressBar
        anchors.left:   parent.left
        anchors.bottom: parent.bottom
        height:         4
        width:          _controllerProgressPct * parent.width
        color:          qgcPal.colorGreen
        visible:        false

        onVisibleChanged: {
            if (visible) {
                largeProgressBar._userHide = false
            }
        }
    }

    // Large mission download progress bar
    //任务同步进度条（大），覆盖整个工具栏，显示详细同步状态
    Rectangle {
        id:             largeProgressBar
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        height:         parent.height
        color:          qgcPal.window
        visible:        _showLargeProgress

        property bool _userHide:                false
        property bool _showLargeProgress:       progressBar.visible && !_userHide && qgcPal.globalTheme === QGCPalette.Light

        Connections {
            target:                 QGroundControl.multiVehicleManager
            onActiveVehicleChanged: largeProgressBar._userHide = false
        }

        //进度条内容，显示同步进度百分比
        Rectangle {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            width:          _controllerProgressPct * parent.width
            color:          qgcPal.colorGreen
        }

        //同步状态标签，显示"Syncing Mission"
        QGCLabel {
            anchors.centerIn:   parent
            text:               qsTr("Syncing Mission")
            font.pointSize:     ScreenTools.largeFontPointSize
            visible:            _controllerProgressPct !== 1
        }

        //完成状态标签，显示"Done"
        QGCLabel {
            anchors.centerIn:   parent
            text:               qsTr("Done")
            font.pointSize:     ScreenTools.largeFontPointSize
            visible:            _controllerProgressPct === 1
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
    // Progress bar
    //进度条信号连接，监听任务同步进度变化
    Connections {
        target: planMasterController.missionController

        onProgressPctChanged: {
            if (_controllerProgressPct === 1) {
                if (_root.visible) {
                    resetProgressTimer.start()
                } else {
                    progressBar.visible = false
                }
            } else if (_controllerProgressPct > 0) {
                progressBar.visible = true
            }
        }
    }

    //进度重置定时器，同步完成后延迟隐藏进度条
    Timer {
        id:             resetProgressTimer
        interval:       3000
        onTriggered:    progressBar.visible = false
    }
}
