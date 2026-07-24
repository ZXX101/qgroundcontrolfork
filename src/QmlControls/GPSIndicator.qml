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
import QGroundControl.MultiVehicleManager
import QGroundControl.ScreenTools
import QGroundControl.Palette

// GPS指示器基类，显示GPS卫星数和HDOP精度
// 作为VehicleGPSIndicator和RTKGPSIndicator的基类使用
// 位于工具栏，显示GPS图标、卫星数、HDOP值，点击弹出GPS详情面板

// Used as the base class control for nboth VehicleGPSIndicator and RTKGPSIndicator

Item {
    id:             control
    width:          implicitWidth
    implicitWidth:  gpsIndicatorRow.width
    anchors.top:    parent.top
    anchors.bottom: parent.bottom

    property var    _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property bool   _rtkConnected:  QGroundControl.gpsRtk.connected.value
    property bool   compactDisplay:  false

    //GPS指示器行，包含RTK标签、GPS图标和GPS数值
    Row {
        id:             gpsIndicatorRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        anchors.right:  parent.right
        spacing:        ScreenTools.defaultFontPixelWidth / 2

        //RTK/GPS图标行，包含RTK标签和GPS图标
        Row {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            spacing:        -ScreenTools.defaultFontPixelWidth / 2

            //RTK标签，RTK连接时显示"RTK"文字（旋转90度）
            QGCLabel {
                id:                     gpsLabel
                rotation:               90
                text:                   qsTr("RTK")
                color:                  "white"
                anchors.verticalCenter: parent.verticalCenter
                visible:                _rtkConnected
            }

            //GPS图标，显示GPS信号图标
            QGCColoredImage {
                id:                 gpsIcon
                height:             ScreenTools.defaultFontPixelHeight * 1.5
                width:              height
                sourceSize.height:  height
                sourceSize.width:   width
                source:             "/xfres/gps.png"
                fillMode:           Image.PreserveAspectFit
                color:              "white"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        //GPS数值区域
        Item {
            id:                     gpsValuesContainer
            anchors.verticalCenter: parent.verticalCenter
            width:                  control.compactDisplay ? compactGpsLabel.implicitWidth : gpsValuesColumn.width
            height:                 control.compactDisplay ? compactGpsLabel.implicitHeight : gpsValuesColumn.height

            //紧凑显示：卫星数量,定位类型
            QGCLabel {
                id:                     compactGpsLabel
                anchors.verticalCenter: parent.verticalCenter
                color:                  "white"
                text:                   gpsValuesColumn._hasData
                                        ? _activeVehicle.gps.count.valueString + "," + _activeVehicle.gps.lock.enumStringValue
                                        : "--"
                visible:                control.compactDisplay
            }

            //标准显示：卫星数和HDOP值
            Column {
                id:                     gpsValuesColumn
                anchors.verticalCenter: parent.verticalCenter
                visible:                !control.compactDisplay

                property bool _connected: _activeVehicle && !_activeVehicle.vehicleLinkManager.communicationLost
                property bool _hasData:   _connected && (_activeVehicle.gps.count.rawValue > 0 || _activeVehicle.gps.lock.rawValue > 0)

                //卫星数标签，显示GPS卫星数量
                QGCLabel {
                    anchors.horizontalCenter:   hdopValue.horizontalCenter
                    color:                      "white"
                    text:                       gpsValuesColumn._connected ? _activeVehicle.gps.count.valueString : "--"
                }

                //HDOP值标签，显示GPS水平精度因子
                QGCLabel {
                    id:     hdopValue
                    color:  "white"
                    text:   gpsValuesColumn._connected ? _activeVehicle.gps.hdop.value.toFixed(1) : "--"
                }
            }
        }
    }

    //点击区域，点击弹出GPS详情面板
    MouseArea {
        anchors.fill:   parent
        z:              1
        onClicked:      mainWindow.showIndicatorDrawer(gpsIndicatorPage, control)
    }

    //GPS详情面板组件
    Component {
        id: gpsIndicatorPage

        GPSIndicatorPage { }
    }
}
