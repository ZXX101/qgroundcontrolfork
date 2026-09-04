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

Rectangle {
    id:                 card
    height:             _fields.length > 2 ? ScreenTools.defaultFontPixelHeight * 7 :
                        (_fields.length > 0 ? ScreenTools.defaultFontPixelHeight * 4.5 : ScreenTools.defaultFontPixelHeight * 2.5)
    color:              missionItem && missionItem.isCurrentItem ? qgcPal.missionItemEditor : qgcPal.windowShade
    radius:             ScreenTools.defaultFontPixelWidth / 4
    border.width:       1
    border.color:       qgcPal.windowShade

    property var        missionItem
    property real       effectiveSpeed: NaN
    property int        speedProfileRevision: 0
    readonly property var _fields: _buildFields()

    function _altText() {
        return (missionItem && missionItem.isSimpleItem && missionItem.altitude && !isNaN(missionItem.altitude.value)) ? Number(missionItem.altitude.value).toFixed(1) + " m" : "-- m"
    }

    function _speedText() {
        return !isNaN(effectiveSpeed) ? Number(effectiveSpeed).toFixed(1) + " m/s" : "-- m/s"
    }

    function _lonText() {
        return (missionItem && missionItem.coordinate && !isNaN(missionItem.coordinate.longitude)) ? missionItem.coordinate.longitude.toFixed(6) : "--"
    }

    function _latText() {
        return (missionItem && missionItem.coordinate && !isNaN(missionItem.coordinate.latitude)) ? missionItem.coordinate.latitude.toFixed(6) : "--"
    }

    function _changeSpeedText() {
        // 该指令设置的速度即 param2，>0 时可直接从 specifiedFlightSpeed 拿到
        if (missionItem && !isNaN(missionItem.specifiedFlightSpeed) && missionItem.specifiedFlightSpeed > 0) {
            return Number(missionItem.specifiedFlightSpeed).toFixed(1) + " m/s"
        }
        var fact = _findParamFact("Speed")
        if (fact && fact.rawValue === -2) {
            // -2 表示恢复默认速度（基础页面未勾选速度时自动插入的速度指令）
            return qsTr("Default")
        }
        return "-- m/s"
    }

    // JSON 里的参数名会按文件名作为 context 被翻译，匹配时要同时匹配原文和译文
    function _nameMatches(factName, sourceName) {
        return factName === sourceName ||
               factName === qsTranslate("MavCmdInfoCommon.json", sourceName) ||
               factName === qsTranslate("APM-MavCmdInfoCommon.json", sourceName)
    }

    // 按参数显示名在命令的参数列表中查找 Fact
    function _findParamFact(paramName) {
        if (missionItem && missionItem.isSimpleItem) {
            var models = [missionItem.textFieldFacts, missionItem.nanFacts, missionItem.comboboxFacts]
            for (var m = 0; m < models.length; m++) {
                var model = models[m]
                if (!model) {
                    continue
                }
                for (var i = 0; i < model.count; i++) {
                    var fact = model.get(i)
                    if (fact && _nameMatches(fact.name, paramName)) {
                        return fact
                    }
                }
            }
        }
        return null
    }

    // 按参数显示名生成一个卡片字段
    function _paramField(paramName) {
        var fact = _findParamFact(paramName)
        if (fact) {
            var value = fact.valueString
            if (fact.units) {
                value += " " + fact.units
            }
            return { "label": fact.name, "value": value }
        }
        return { "label": paramName, "value": "--" }
    }

    // 不同命令显示不同字段，最多4个；1-2个字段只占一行，3-4个字段两行
    function _buildFields() {
        if (!missionItem) {
            return []
        }
        var alt = { "label": qsTr("Altitude"),  "value": _altText() }
        var spd = { "label": qsTr("Speed"),     "value": _speedText() }
        var lon = { "label": qsTr("Longitude"), "value": _lonText() }
        var lat = { "label": qsTr("Latitude"),  "value": _latText() }

        var fields = _commandFields(alt, spd, lon, lat)
        // 只有1个字段时补一个空白占位，让它保持在2字段布局的左侧位置
        if (fields.length === 1) {
            fields.push({ "label": "", "value": "" })
        }
        return fields
    }

    function _commandFields(alt, spd, lon, lat) {
        switch (missionItem.isSimpleItem ? missionItem.command : -1) {
        case 17:  // Loiter
        case 21:  // Land
            return [alt, lon, lat]
        case 22:  // Takeoff（仅高度，无经纬度）
        case 30:  // Change Altitude（仅高度）
            return [alt]
        case 20:  // Return To Launch
            return []
        case 195: // Region of interest (ROI)
        case 201: // Region of interest
            return [lon, lat]
        case 178: // Change speed
            return [{ "label": qsTr("Speed"), "value": _changeSpeedText() }]
        case 113: // Wait for altitude
            return [alt, _paramField("Rate")]
        case 93:  // Delay until
            return [_paramField("Hold")]
        case 112: // Delay
            return [_paramField("Delay")]
        case 114: // Wait for distance
            return [_paramField("Distance")]
        case 115: // Wait for Yaw
            return [_paramField("Heading")]
        case 18:  // Loiter (turns)
            return [_paramField("Turns"), alt, lon, lat]
        case 19:  // Loiter (time)
            return [_paramField("Loiter Time"), alt, lon, lat]
        case 177: // Jump to item
            return [_paramField("Item #"), _paramField("Repeat")]
        case 183: // Set servo
            return [_paramField("Servo"), _paramField("PWM")]
        case 205: // Control Mount
            return [_paramField("Pitch"), _paramField("Roll"), _paramField("Yaw")]
        case 206: // Camera trigger distance
            return [_paramField("Distance")]
        default:  // Waypoint, Spline waypoint 等
            return [alt, spd, lon, lat]
        }
    }
    readonly property real deleteButtonWidth: waypointDeleteBtn.implicitWidth

    signal waypointClicked(int sequenceNumber)
    signal waypointRemove(int itemIndex)

    RowLayout {
        anchors.fill:       parent
        anchors.margins:    ScreenTools.defaultFontPixelWidth / 2
        spacing:            ScreenTools.defaultFontPixelWidth

        Column {
            // 固定宽度，避免命令名长短不一导致各卡片字段列对不齐
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
            Layout.maximumWidth: ScreenTools.defaultFontPixelWidth * 8
            clip: true

            QGCLabel {
                width:      parent.width
                elide:      Text.ElideRight
                text:       "#" + (missionItem ? missionItem.sequenceNumber : 0)
                font.bold:  true
                font.pointSize: ScreenTools.defaultFontPixelSize * 1.2
            }
            QGCLabel {
                width:      parent.width
                elide:      Text.ElideRight
                text:       missionItem ? missionItem.commandName : ""
                font.pointSize: ScreenTools.smallFontPointSize
                color:      qgcPal.text
            }
        }

        GridLayout {
            id: fieldGrid
            Layout.fillWidth: true
            columns: 2
            rowSpacing: ScreenTools.defaultFontPixelHeight / 2
            columnSpacing: ScreenTools.defaultFontPixelWidth * 2

            Repeater {
                model: card._fields

                ColumnLayout {
                    Layout.fillWidth: true
                    // implicitWidth 设为相同值，让 GridLayout 均分两列（内容不撑宽列），字段按Z字形排列
                    implicitWidth:  1

                    QGCLabel {
                        Layout.fillWidth: true
                        elide:      Text.ElideRight
                        text:       modelData.label
                        font.pointSize: ScreenTools.defaultFontPointSize
                        color:      qgcPal.text
                    }
                    QGCLabel {
                        Layout.fillWidth: true
                        elide:      Text.ElideRight
                        text:       modelData.value
                        font.pointSize: ScreenTools.defaultFontPointSize
                    }
                }
            }
        }

    }
    Image {
        id: waypointDeleteBtn
        z: 1
        height: ScreenTools.minTouchPixels* 0.7
        width: height
        sourceSize.height: height
        fillMode: Image.PreserveAspectFit
        source: "/xfressvg/deleteProtocol.svg"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.right
        anchors.leftMargin: -width / 2
        visible: missionItem && missionItem.sequenceNumber !== 0

        QGCMouseArea {
            fillItem: parent
            onClicked: {
                waypointRemove(index)
            }
        }
    }

    QGCMouseArea {
        z: 0
        anchors.fill: parent
        onClicked: {
            if (missionItem) {
                waypointClicked(missionItem.sequenceNumber)
            }
        }
    }
}
