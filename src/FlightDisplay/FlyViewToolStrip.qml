/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQml.Models

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlightDisplay

//飞行工具条，继承ToolStrip基类，显示飞行快捷操作按钮
//包含：起飞、降落、返航、暂停、紧急停止、起飞前检查清单等按钮
ToolStrip {
    id: _root

    signal displayPreFlightChecklist

    //飞行工具条动作列表功能组件，定义飞行操作按钮和动作
    FlyViewToolStripActionList {
        id: flyViewToolStripActionList

        onDisplayPreFlightChecklist: _root.displayPreFlightChecklist()
    }

    model: flyViewToolStripActionList.model
}
