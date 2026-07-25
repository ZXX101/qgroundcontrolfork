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
import QGroundControl.ScreenTools
import QGroundControl.Palette

    GridLayout {
        columns:        2
        Layout.fillWidth: true
        Layout.margins: ScreenTools.defaultFontPixelHeight / 2
    rowSpacing:     _rowSpacing
    columnSpacing:  _colSpacing

    function saveSettings() {
        subEditConfig.host = hostField.text
        subEditConfig.port = parseInt(portField.text)
    }

    QGCLabel {
        text: qsTr("Server Address")
    }
    QGCTextField {
        id:                     hostField
        Layout.fillWidth:       true
        text:                   subEditConfig.host
    }

    QGCLabel {
        text: qsTr("Port")
    }
    QGCTextField {
        id:                     portField
        Layout.fillWidth:       true
        text:                   subEditConfig.port.toString()
        inputMethodHints:       Qt.ImhFormattedNumbersOnly
    }
}
