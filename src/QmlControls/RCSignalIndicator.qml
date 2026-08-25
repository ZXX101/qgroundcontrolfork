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

//遥控器链路信号质量指示器(云卓RCSDK),显示信号图标+百分比,点击弹出链路详情面板
//仅在SDK可用(Android云卓遥控器,signalQuality >= 0)时显示
Item {
    id:             control
    width:          implicitWidth
    implicitWidth:  signalIndicatorRow.width
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    visible:        RCSignalQuality.signalQuality >= 0

    //信号质量行,包含信号图标和百分比数值
    Row {
        id:             signalIndicatorRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        spacing:        ScreenTools.defaultFontPixelWidth / 2

        //信号质量图标
        QGCColoredImage {
            id:                     signalIcon
            height:                 ScreenTools.defaultFontPixelHeight * 1.2
            width:                  height
            sourceSize.height:      height
            sourceSize.width:       width
            source:                 "/xfressvg/signal.svg"
            fillMode:               Image.PreserveAspectFit
            color:                  "white"
            anchors.verticalCenter: parent.verticalCenter
        }

        //信号质量百分比
        QGCLabel {
            anchors.verticalCenter: parent.verticalCenter
            color:                  "white"
            text:                   qsTr("%1%").arg(RCSignalQuality.signalQuality)
        }
    }

    //点击区域，点击弹出链路详情面板
    MouseArea {
        anchors.fill:   parent
        z:              1
        onClicked:      mainWindow.showIndicatorDrawer(rcSignalIndicatorPage, control)
    }

    //链路详情面板组件
    Component {
        id: rcSignalIndicatorPage

        RCSignalIndicatorPage { }
    }
}
