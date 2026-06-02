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

//水平布局的指南针和姿态球仪表盘，姿态球在左、数据面板在中间、指南针在右
Rectangle {
    id:     control
    width:  Math.min(_defaultWidth, _maxWidth)
    height: _outerRadius * 2
    radius: _outerRadius
    color:  qgcPal.window

    property real extraInset:           0
    property real extraValuesWidth:     _outerRadius

    property real   _defaultWidth:      mainWindow.width * 0.38  // 加宽以容纳数据面板
    property real   _maxWidth:          ScreenTools.defaultFontPixelHeight * 24
    property real   _topBottomMargin:   (width * 0.03) / 2
    property real   _widgetSize:        (width - _dataPanelWidth - (_topBottomMargin * 2) - (_spacing * 2)) / 2  // 基于宽度计算，两个仪表盘+数据面板
    property real   _outerRadius:       _widgetSize / 2 + _topBottomMargin
    property real   _spacing:           ScreenTools.defaultFontPixelHeight * 0.5
    property real   _dataPanelWidth:    ScreenTools.defaultFontPixelWidth * 14

    DeadMouseArea { anchors.fill: parent }

    QGCPalette { id: qgcPal }

    //姿态球控件，显示roll/pitch，位于左侧
    QGCAttitudeWidget {
        id:                     attitude
        anchors.leftMargin:     control._topBottomMargin
        anchors.left:           parent.left
        size:                   control._widgetSize
        vehicle:                globals.activeVehicle
        anchors.verticalCenter: parent.verticalCenter
    }

    //数据面板，显示高度、速度、距离等数据，位于中间
    Column {
        id:                     dataPanel
        anchors.leftMargin:     control._spacing
        anchors.left:           attitude.right
        anchors.verticalCenter: parent.verticalCenter
        width:                  control._dataPanelWidth
        spacing:                ScreenTools.defaultFontPixelHeight * 0.2

        property var _activeVehicle: globals.activeVehicle

        //高度数据行
        Row {
            spacing: ScreenTools.defaultFontPixelWidth * 0.5
            anchors.horizontalCenter: parent.horizontalCenter
            QGCLabel {
                text: qsTr("Alt")
                font.pointSize: ScreenTools.smallFontPointSize
                color: qgcPal.text
            }
            QGCLabel {
                text: dataPanel._activeVehicle ? dataPanel._activeVehicle.altitudeRelative.valueString : "--"
                font.pointSize: ScreenTools.defaultFontPointSize
                font.bold: true
                color: qgcPal.text
            }
        }

        //速度数据行
        Row {
            spacing: ScreenTools.defaultFontPixelWidth * 0.5
            anchors.horizontalCenter: parent.horizontalCenter
            QGCLabel {
                text: qsTr("Spd")
                font.pointSize: ScreenTools.smallFontPointSize
                color: qgcPal.text
            }
            QGCLabel {
                text: dataPanel._activeVehicle ? dataPanel._activeVehicle.groundSpeed.valueString : "--"
                font.pointSize: ScreenTools.defaultFontPointSize
                font.bold: true
                color: qgcPal.text
            }
        }

        //距离数据行（到home的距离）
        Row {
            spacing: ScreenTools.defaultFontPixelWidth * 0.5
            anchors.horizontalCenter: parent.horizontalCenter
            QGCLabel {
                text: qsTr("Dst")
                font.pointSize: ScreenTools.smallFontPointSize
                color: qgcPal.text
            }
            QGCLabel {
                text: dataPanel._activeVehicle ? dataPanel._activeVehicle.distanceToHome.valueString : "--"
                font.pointSize: ScreenTools.defaultFontPointSize
                font.bold: true
                color: qgcPal.text
            }
        }
    }

    //指南针控件，显示heading，位于右侧
    QGCCompassWidget {
        id:                     compass
        anchors.leftMargin:     control._spacing
        anchors.left:           dataPanel.right
        size:                   control._widgetSize
        vehicle:                globals.activeVehicle
        anchors.verticalCenter: parent.verticalCenter
    }
}
