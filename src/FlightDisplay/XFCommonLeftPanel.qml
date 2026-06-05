/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.ScreenTools

//通用页面左侧导航面板，显示页面切换列表
//包含8个主页面项和设备配置的二级菜单
Rectangle {
    id:                 leftPanel
    color:              qgcPal.windowShadeDark

    //当前选中的页面索引
    property int        currentPageIndex:          0

    //设备配置二级菜单是否展开
    property bool       deviceConfigExpanded:      false

    //当前设备配置二级菜单索引
    property int        currentDeviceConfigIndex:  0

    //页面选中信号
    signal pageSelected(int index)

    //设备配置子页面选中信号
    signal deviceConfigSelected(int subIndex)

    //返回主页面信号
    signal backToMainPage()

    //页面列表数据（与 XFCommonView.qml 保持一致）
    property var        pageList: [
        { name: qsTr("连接") },
        { name: qsTr("设备配置") },
        { name: qsTr("飞行参数") },
        { name: qsTr("安全") },
        { name: qsTr("设备日志") },
        { name: qsTr("Mavlink Console") },
        { name: qsTr("Mavlink Analyze") },
        { name: qsTr("软件设置") }
    ]

    //设备配置二级菜单页面列表
    property var        deviceConfigPages: [
        { name: qsTr("概况") },
        { name: qsTr("机架") },
        { name: qsTr("传感器") },
        { name: qsTr("通道设置") },
        { name: qsTr("电源") },
        { name: qsTr("电机") },
        { name: qsTr("遥控器") },
        { name: qsTr("PID调参") },
        { name: qsTr("参数") }
    ]

    QGCPalette { id: qgcPal }

    //页面列表滚动区域
    QGCFlickable {
        id:                 pageListFlickable
        anchors.fill:       parent
        anchors.margins:    ScreenTools.defaultFontPixelWidth / 2
        flickableDirection: Flickable.VerticalFlick
        clip:               true

        ColumnLayout {
            id:                 pageListColumn
            spacing:            ScreenTools.defaultFontPixelHeight / 4
            width:              pageListFlickable.width - ScreenTools.defaultFontPixelWidth

            //主页面列表
            Repeater {
                model: pageList

                //页面按钮
                Rectangle {
                    id:                 pageButton
                    Layout.fillWidth:   true
                    height:             ScreenTools.defaultFontPixelHeight * 2.5
                    radius:             ScreenTools.defaultFontPixelWidth / 4
                    color:              (currentPageIndex === index && !deviceConfigExpanded) ?
                                            qgcPal.buttonHighlight :
                                            (pageButtonMA.containsMouse ? qgcPal.button : qgcPal.windowShade)

                    RowLayout {
                        anchors.fill:       parent
                        anchors.margins:    ScreenTools.defaultFontPixelWidth / 2
                        spacing:            ScreenTools.defaultFontPixelWidth / 2

                        //页面名称
                        QGCLabel {
                            text:               modelData.name
                            color:              (currentPageIndex === index && !deviceConfigExpanded) ?
                                                qgcPal.buttonHighlightText : qgcPal.buttonText
                            font.pointSize:     ScreenTools.defaultFontPointSize
                            Layout.fillWidth:   true
                        }

                        //设备配置页显示展开/收起图标
                        QGCLabel {
                            visible:            index === 1  // 设备配置页
                            text:               deviceConfigExpanded ? "◀" : "▶"
                            color:              qgcPal.buttonText
                        }
                    }

                    QGCMouseArea {
                        id:                 pageButtonMA
                        anchors.fill:       parent
                        hoverEnabled:       true

                        onClicked: {
                            if (index === 1) {
                                // 设备配置页：切换展开/收起
                                if (deviceConfigExpanded) {
                                    backToMainPage()
                                } else {
                                    pageSelected(index)
                                    deviceConfigExpanded = true
                                    // 默认选中概况
                                    deviceConfigSelected(0)
                                }
                            } else {
                                // 其他页面：直接选中
                                pageSelected(index)
                            }
                        }
                    }
                }
            }

            //设备配置二级菜单（展开时显示）
            ColumnLayout {
                visible:                deviceConfigExpanded
                spacing:                ScreenTools.defaultFontPixelHeight / 8
                Layout.fillWidth:       true
                Layout.topMargin:       ScreenTools.defaultFontPixelHeight / 4

                //二级菜单标题
                QGCLabel {
                    text:                   qsTr("设备配置")
                    font.pointSize:         ScreenTools.smallFontPointSize
                    color:                  qgcPal.text
                    Layout.leftMargin:      ScreenTools.defaultFontPixelWidth
                }

                //二级菜单项
                Repeater {
                    model: deviceConfigPages

                    Rectangle {
                        id:                 subPageButton
                        Layout.fillWidth:   true
                        Layout.leftMargin:  ScreenTools.defaultFontPixelWidth * 1.5
                        height:             ScreenTools.defaultFontPixelHeight * 2
                        radius:             ScreenTools.defaultFontPixelWidth / 4
                        color:              (currentDeviceConfigIndex === index) ?
                                            qgcPal.buttonHighlight :
                                            (subPageButtonMA.containsMouse ? qgcPal.button : qgcPal.windowShadeDark)

                        QGCLabel {
                            anchors.centerIn:   parent
                            text:               modelData.name
                            color:              (currentDeviceConfigIndex === index) ?
                                                qgcPal.buttonHighlightText : qgcPal.buttonText
                            font.pointSize:     ScreenTools.defaultFontPointSize * 0.9
                        }

                        QGCMouseArea {
                            id:                 subPageButtonMA
                            anchors.fill:       parent
                            hoverEnabled:       true

                            onClicked: {
                                deviceConfigSelected(index)
                            }
                        }
                    }
                }
            }

            //底部空白区域（填充）
            Item {
                Layout.fillHeight:   true
            }
        }
    }
}