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

import QGroundControl
import QGroundControl.FactSystem
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.MultiVehicleManager
import QGroundControl.Palette
import QGroundControl.AutoPilotPlugins.PX4
import QGroundControl.AutoPilotPlugins.APM

//根组件: 概况页面容器 - 显示飞控各组件的设置状态概览
Rectangle {
    id:             _summaryRoot
    anchors.fill:   parent
    anchors.rightMargin: ScreenTools.defaultFontPixelWidth
    anchors.leftMargin:  ScreenTools.defaultFontPixelWidth
    color:          qgcPal.window

    //功能组件: 尺寸计算器 - 根据窗口宽度动态计算每个组件块的宽度
    property real _minSummaryW:     ScreenTools.isTinyScreen ? ScreenTools.defaultFontPixelWidth * 28 : ScreenTools.defaultFontPixelWidth * 36
    property real _summaryBoxWidth: _minSummaryW
    property real _summaryBoxSpace: ScreenTools.defaultFontPixelWidth * 2

    //功能组件: 计算摘要框大小 - 自适应布局
    function computeSummaryBoxSize() {
        var sw  = 0
        var rw  = 0
        var idx = Math.floor(_summaryRoot.width / (_minSummaryW + ScreenTools.defaultFontPixelWidth))
        if(idx < 1) {
            _summaryBoxWidth = _summaryRoot.width
            _summaryBoxSpace = 0
        } else {
            _summaryBoxSpace = 0
            if(idx > 1) {
                _summaryBoxSpace = ScreenTools.defaultFontPixelWidth * 2
                sw = _summaryBoxSpace * (idx - 1)
            }
            rw = _summaryRoot.width - sw
            _summaryBoxWidth = rw / idx
        }
    }

    //功能组件: 首字母大写转换 - 用于格式化组件名称显示
    function capitalizeWords(sentence) {
        return sentence.replace(/(?:^|\s)\S/g, function(a) { return a.toUpperCase(); });
    }

    //调色板组件: 提供QGC标准配色
    QGCPalette {
        id:                 qgcPal
        colorGroupEnabled:  enabled
    }

    Component.onCompleted: {
        computeSummaryBoxSize()
    }

    onWidthChanged: {
        computeSummaryBoxSize()
    }

    //显示控件: 可滚动区域 - 支持垂直滚动查看所有组件状态
    QGCFlickable {
        clip:               true
        anchors.fill:       parent
        contentHeight:      summaryColumn.height
        contentWidth:       _summaryRoot.width
        flickableDirection: Flickable.VerticalFlick

        Column {
            id:             summaryColumn
            width:          _summaryRoot.width
            spacing:        ScreenTools.defaultFontPixelHeight

            //显示控件: 状态提示标签 - 显示设置完成状态或警告信息
            QGCLabel {
                width:			parent.width
                wrapMode:		Text.WordWrap
                color:			setupComplete ? qgcPal.text : qgcPal.warningText
                font.bold:      true
                horizontalAlignment: Text.AlignHCenter
                text:           setupComplete ?
                    qsTr("Below you will find a summary of the settings for your vehicle. To the left are the setup menus for each component.") :
                    qsTr("WARNING: Your vehicle requires setup prior to flight. Please resolve the items marked in red using the menu on the left.")

                //功能组件: 设置完成状态检查 - 判断所有组件是否已完成配置
                property bool setupComplete: QGroundControl.multiVehicleManager.activeVehicle ? QGroundControl.multiVehicleManager.activeVehicle.autopilotPlugin.setupComplete : false
            }

            //显示控件: 组件卡片流式布局 - 以流式布局显示各组件的状态卡片
            Flow {
                id:         _flowCtl
                width:      _summaryRoot.width
                spacing:    _summaryBoxSpace

                //功能组件: 组件列表循环器 - 循环显示每个飞控组件的设置状态
                Repeater {
                    model: QGroundControl.multiVehicleManager.activeVehicle ? QGroundControl.multiVehicleManager.activeVehicle.autopilotPlugin.vehicleComponents : undefined

                    //显示控件: 组件状态卡片 - 单个组件的设置状态概览
                    Rectangle {
                        width:      _summaryBoxWidth
                        height:     ScreenTools.defaultFontPixelHeight * 13
                        color:      qgcPal.windowShade
                        visible:    modelData.summaryQmlSource.toString() !== ""
                        border.width: 1
                        border.color: qgcPal.text
                        Component.onCompleted: {
                            border.color = Qt.rgba(border.color.r, border.color.g, border.color.b, 0.1)
                        }

                        readonly property real titleHeight: ScreenTools.defaultFontPixelHeight * 2

                        //显示控件: 组件标题栏 - 显示组件名称和设置状态指示器
                        QGCButton {
                            id:     titleBar
                            width:  parent.width
                            height: titleHeight
                            text:   capitalizeWords(modelData.name)

                            //显示控件: 设置状态指示器 - 绿色表示已完成，红色表示未完成
                            Rectangle {
                                anchors.rightMargin:    ScreenTools.defaultFontPixelWidth
                                anchors.right:          parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                width:                  ScreenTools.defaultFontPixelWidth * 1.75
                                height:                 width
                                radius:                 width / 2
                                color:                  modelData.setupComplete ? "#00d932" : "red"
                                visible:                modelData.requiresSetup && modelData.setupSource !== ""
                            }

                            //功能组件: 组件点击事件 - 点击跳转至对应设置页面
                            onClicked : {
                                //console.log(modelData.setupSource)
                                if (modelData.setupSource !== "") {
                                    setupView.showVehicleComponentPanel(modelData)
                                }
                            }
                        }
                        //显示控件: 组件摘要内容加载器 - 动态加载各组件的摘要QML
                        Rectangle {
                            anchors.top:    titleBar.bottom
                            width:          parent.width
                            Loader {
                                anchors.fill:       parent
                                anchors.margins:    ScreenTools.defaultFontPixelWidth
                                source:             modelData.summaryQmlSource

                                property var vehicleComponent: modelData
                            }
                        }
                    }
                }
            }
        }
    }
}
