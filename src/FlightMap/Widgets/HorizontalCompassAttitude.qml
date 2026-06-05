/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick

import QGroundControl
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Palette
import QGroundControl.FlightDisplay
import QGroundControl.FactSystem

//水平布局的指南针和姿态球仪表盘，姿态球在左、数据面板在中间、指南针在右
//三个面板自然排列，总宽度 = 各面板宽度之和 + 间距
//背景为跑道形（两侧半圆），左侧边与姿态球重叠，右侧边与指南针重叠
Rectangle {
    id:     control
    width:  mainRow.width + (_margin * 2)
    height: control._widgetSize + (_margin * 2)
    radius: height / 2  // 跑道形背景，两侧为半圆
    color:  qgcPal.window

    property real extraInset:           0
    property real extraValuesWidth:     dataPanel.implicitWidth

    // 解锁状态属性，外部设置时同步解锁数据面板
    property bool settingsUnlocked: false
    onSettingsUnlockedChanged: {
        dataPanel.factValueGrid.settingsUnlocked = settingsUnlocked
    }

    property var  _activeVehicle:       globals.activeVehicle
    property real _margin:              ScreenTools.defaultFontPixelWidth / 2
    property real _spacing:             ScreenTools.defaultFontPixelWidth
    property real _widgetSize:          ScreenTools.defaultFontPixelHeight * 3.25  // 仪表盘直径，约等于数据面板高度

    DeadMouseArea { anchors.fill: parent }

    QGCPalette { id: qgcPal }

    //主布局行，包含姿态球、数据面板、指南针
    Row {
        id:         mainRow
        spacing:    control._spacing
        anchors.centerIn: parent

        //姿态球控件，显示roll/pitch，位于左侧
        QGCAttitudeWidget {
            id:     attitude
            size:   control._widgetSize
            vehicle: globals.activeVehicle
        }

        //数据面板，使用TelemetryValuesBar，位于中间（垂直居中）
        // z 设置为较高值，确保点击事件能传递到数据面板内部
        Item {
            width:  dataPanel.implicitWidth
            height: control._widgetSize
            z:      10  // 提高z-order，确保事件优先处理

            TelemetryValuesBar {
                id:                     dataPanel
                anchors.centerIn:       parent
                extraWidth:             0
                settingsGroup:          factValueGrid.telemetryBarSettingsGroup
                specificVehicleForCard: null  // 使用活动车辆
            }
        }

        //指南针控件，显示heading，位于右侧
        QGCCompassWidget {
            id:     compass
            size:   control._widgetSize
            vehicle: globals.activeVehicle
        }
    }
}
