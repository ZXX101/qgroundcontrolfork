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
import QtCharts
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.ScreenTools
import QGroundControl.Vehicle

ColumnLayout {
    spacing: ScreenTools.defaultFontPixelHeight / 4

    property real   availableHeight
    property real   availableWidth
    property var    axis
    property string unit
    property string title
    property var    tuningMode
    property double chartDisplaySec:    8

    property int    _currentAxis:       0
    property var    _xAxis:             xAxis
    property var    _yAxis:             yAxis
    property int    _msecs:             0
    property double _last_t:            0

    readonly property int _tickSeparation:      5
    readonly property int _maxTickSections:     10

    function adjustYAxisMin(yAxis, newValue) {
        var newMin = Math.min(yAxis.min, newValue)
        if (newMin % 5 != 0) {
            newMin -= 5
            newMin = Math.floor(newMin / _tickSeparation) * _tickSeparation
        }
        yAxis.min = newMin
    }

    function adjustYAxisMax(yAxis, newValue) {
        var newMax = Math.max(yAxis.max, newValue)
        if (newMax % 5 != 0) {
            newMax += 5
            newMax = Math.floor(newMax / _tickSeparation) * _tickSeparation
        }
        yAxis.max = newMax
    }

    function resetGraphs() {
        for (var i = 0; i < chart.count; ++i) {
            chart.series(i).removePoints(0, chart.series(i).count)
        }
        _xAxis.min = 0
        _xAxis.max = 0
        _yAxis.min = 0
        _yAxis.max = 0
        _msecs = 0
        _last_t = 0
    }

    function axisIndexChanged() {
        if (!axis || axis.length === 0 || !axis[_currentAxis] || !axis[_currentAxis].plot) return
        chart.removeAllSeries()
        axis[_currentAxis].plot.forEach(function(e) {
            chart.createSeries(ChartView.SeriesTypeLine, e.name, xAxis, yAxis);
        })
        var chartTitle = axis[_currentAxis].plotTitle
        if (chartTitle == null)
            chartTitle = axis[_currentAxis].name
        chart.title = chartTitle + " " + title
        resetGraphs()
    }

    Component.onCompleted: {
        axisIndexChanged()
        if (globals.activeVehicle)
            globals.activeVehicle.setPIDTuningTelemetryMode(tuningMode)
    }

    Component.onDestruction: {
        if (globals.activeVehicle)
            globals.activeVehicle.setPIDTuningTelemetryMode(Vehicle.ModeDisabled)
    }
    on_CurrentAxisChanged: axisIndexChanged()
    onAxisChanged: axisIndexChanged()

    ValueAxis {
        id:                     xAxis
        min:                    0
        max:                    0
        labelFormat:            "%.1f"
        titleText:              ScreenTools.isShortScreen ? "" : qsTr("sec")
        tickCount:              Math.min(Math.max(Math.floor(chart.width / (ScreenTools.defaultFontPixelWidth * 7)), 4), 11)
        labelsFont.pointSize:   ScreenTools.defaultFontPointSize
        labelsFont.family:      ScreenTools.normalFontFamily
        titleFont.pointSize:    ScreenTools.defaultFontPointSize
        titleFont.family:       ScreenTools.normalFontFamily
    }

    ValueAxis {
        id:                     yAxis
        min:                    0
        max:                    10
        titleText:              unit
        tickCount:              Math.min(((max - min) / _tickSeparation), _maxTickSections) + 1
        labelsFont.pointSize:   ScreenTools.defaultFontPointSize
        labelsFont.family:      ScreenTools.normalFontFamily
        titleFont.pointSize:    ScreenTools.defaultFontPointSize
        titleFont.family:       ScreenTools.normalFontFamily
    }

    Timer {
        id:         dataTimer
        interval:   10
        running:    true
        repeat:     true

        onTriggered: {
            if (!axis || !axis[_currentAxis] || !axis[_currentAxis].plot)
                return

            _xAxis.max = _msecs / 1000
            _xAxis.min = _msecs / 1000 - chartDisplaySec

            var firstPoint = _msecs == 0

            var len = axis[_currentAxis].plot.length
            for (var i = 0; i < len; ++i) {
                var value = axis[_currentAxis].plot[i].value
                if (!isNaN(value)) {
                    chart.series(i).append(_msecs/1000, value)
                    if (firstPoint) {
                        _yAxis.min = value
                        _yAxis.max = value
                    } else {
                        adjustYAxisMin(_yAxis, value)
                        adjustYAxisMax(_yAxis, value)
                    }
                    var minSec = _msecs/1000 - 3*60
                    while (chart.series(i).count > 0 && chart.series(i).at(0).x < minSec) {
                        chart.series(i).remove(0)
                    }
                }
            }

            var t = new Date().getTime()
            if (_last_t > 0)
                _msecs += t-_last_t
            _last_t = t
        }

        property int _maxPointCount:    10000 / interval
    }

    ChartView {
        id:                     chart
        Layout.fillWidth:       true
        Layout.fillHeight:      true
        Layout.minimumHeight:   ScreenTools.defaultFontPixelHeight * 15
        antialiasing:           true
        legend.alignment:       Qt.AlignBottom
        legend.font.pointSize:  ScreenTools.defaultFontPointSize
        legend.font.family:     ScreenTools.normalFontFamily
        titleFont.pointSize:    ScreenTools.defaultFontPointSize
        titleFont.family:       ScreenTools.normalFontFamily
        margins.top:            0
        margins.bottom:         0
        margins.left:           0
        margins.right:          0


    }

    RowLayout {
        spacing: ScreenTools.defaultFontPixelHeight / 2

        RowLayout {
            spacing: ScreenTools.defaultFontPixelHeight / 2
            visible: axis.length > 1

            QGCLabel { text: qsTr("选择轴:") }

            Repeater {
                model: axis
                QGCRadioButton {
                    text:           modelData.name
                    checked:        index == _currentAxis
                    onClicked: _currentAxis = index
                }
            }
        }

        Item { Layout.fillWidth: true }

        QGCButton {
            text:       qsTr("清除")
            onClicked:  resetGraphs()
        }

        QGCButton {
            text:       dataTimer.running ? qsTr("停止") : qsTr("开始")
            onClicked: {
                dataTimer.running = !dataTimer.running
                _last_t = 0
            }
        }
    }

    Connections {
        target: globals.activeVehicle
        onArmedChanged: {
            if (globals.activeVehicle && armed && !dataTimer.running) {
                dataTimer.running = true
                _last_t = 0
            }
        }
    }
}
