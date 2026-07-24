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

ColumnLayout {
    Layout.fillWidth: true
    spacing: _rowSpacing

    function saveSettings() {
        // No need
    }

    QGCLabel {
        Layout.preferredWidth: _secondColumnWidth
        Layout.fillWidth:       true
        font.pointSize:         ScreenTools.smallFontPointSize
        wrapMode:               Text.WordWrap
        text:                   qsTr("Note: For best perfomance, please disable AutoConnect to UDP devices on the General page.")
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: _colSpacing

        QGCLabel {
            text: qsTr("Port")
            Layout.fillWidth: true
        }
        QGCTextField {
            id:                     portField
            text:                   subEditConfig.localPort.toString()
            focus:                  true
            Layout.preferredWidth:  _secondColumnWidth
            Layout.alignment:       Qt.AlignRight
            inputMethodHints:       Qt.ImhFormattedNumbersOnly
            onTextChanged:          subEditConfig.localPort = parseInt(portField.text)
        }
    }

    QGCLabel {
        text: qsTr("Server Addresses (optional)")
        Layout.fillWidth: true
    }

    Repeater {
        model: subEditConfig.hostList

        delegate: RowLayout {
            Layout.fillWidth: true
            spacing: _colSpacing

            QGCLabel {
                Layout.preferredWidth:  _secondColumnWidth
                Layout.fillWidth:       true
                text:                   modelData
            }

            QGCButton {
                Layout.alignment: Qt.AlignRight
                text:       qsTr("Remove")
                onClicked:  subEditConfig.removeHost(modelData)
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: _colSpacing

        QGCTextField {
            id:                     hostField
            Layout.preferredWidth:  _secondColumnWidth
            Layout.fillWidth:       true
            placeholderText:        qsTr("Example: 127.0.0.1:14550")
        }
        QGCButton {
            Layout.alignment: Qt.AlignRight
            text:       qsTr("Add Server")
            enabled:    hostField.text !== ""
            onClicked: {
                subEditConfig.addHost(hostField.text)
                hostField.text = ""
            }
        }
    }
}
