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
import QtQuick.Controls

import QGroundControl
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Palette

ColumnLayout {
    property var    instrumentValueData:            null
    property bool   settingsUnlocked:               false
    property alias  contentWidth:                   label.contentWidth
    property bool   showUnits:                      true
    property string valueFontFamily:                ScreenTools.normalFontFamily
    property real   valueWidth:                      0

    property var    _rgFontSizes:                   [ ScreenTools.defaultFontPointSize, ScreenTools.smallFontPointSize, ScreenTools.mediumFontPointSize, ScreenTools.largeFontPointSize ]
    property var    _rgFontSizeRatios:              [ 1, ScreenTools.smallFontPointRatio, ScreenTools.mediumFontPointRatio, ScreenTools.largeFontPointRatio ]
    property real   _doubleDescent:                 ScreenTools.defaultFontDescent * 2
    property real   _tightDefaultFontHeight:        ScreenTools.defaultFontPixelHeight - _doubleDescent
    property var    _rgFontSizeTightHeights:        [ _tightDefaultFontHeight * _rgFontSizeRatios[0] + 2, _tightDefaultFontHeight * _rgFontSizeRatios[1] + 2, _tightDefaultFontHeight * _rgFontSizeRatios[2] + 2, _tightDefaultFontHeight * _rgFontSizeRatios[3] + 2 ]
    property real   _tightHeight:                   _rgFontSizeTightHeights[instrumentValueData.factValueGrid.fontSize]
    property real   _fontSize:                      _rgFontSizes[instrumentValueData.factValueGrid.fontSize]
    property real   _horizontalLabelSpacing:        ScreenTools.defaultFontPixelWidth
    property real   _width:                         0
    property real   _height:                        0

    implicitWidth: valueWidth > 0 ? valueWidth : label.implicitWidth

    QGCLabel {
        id:                 label
        Layout.alignment:   Qt.AlignVCenter | Qt.AlignHCenter
        Layout.fillWidth:   valueWidth > 0
        Layout.minimumWidth: valueWidth > 0 ? valueWidth : 0
        Layout.preferredWidth: valueWidth > 0 ? valueWidth : -1
        Layout.maximumWidth: valueWidth > 0 ? valueWidth : -1
        font.family:        valueFontFamily
        font.pointSize:     _fontSize * 0.8  // 字体减小
        horizontalAlignment: Text.AlignHCenter
        color:              instrumentValueData.isValidColor(instrumentValueData.currentColor) ? instrumentValueData.currentColor : qgcPal.text
        text:               valueText()

        function valueText() {
            if (instrumentValueData.fact) {
                return instrumentValueData.fact.enumOrValueString + (showUnits && instrumentValueData.showUnits ? " " + instrumentValueData.fact.units : "")
            } else {
                return qsTr("--.--")
            }
        }
    }
}
