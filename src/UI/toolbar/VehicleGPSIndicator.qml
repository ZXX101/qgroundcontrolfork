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

//车辆GPS指示器，继承GPSIndicator基类，显示GPS卫星数和HDOP精度
//位于工具栏右侧固定位置，点击弹出GPS详情面板
GPSIndicator {
    property bool showIndicator: true
}
