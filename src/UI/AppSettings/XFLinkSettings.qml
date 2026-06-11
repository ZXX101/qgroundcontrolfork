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
import QtQuick.Dialogs
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FactControls
import QGroundControl.ScreenTools
import QGroundControl.Palette

QGCFlickable {
    property var _linkManager: QGroundControl.linkManager
    property var _autoConnectSettings: QGroundControl.settingsManager.autoConnectSettings

    RowLayout {
        anchors.fill: parent
        spacing: ScreenTools.defaultDialogControlSpacing * 5

        // 左侧：连接列表
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: ScreenTools.defaultFontPixelWidth * 20

            QGCLabel {
                text: "Links"
                font.bold: true
                font.pointSize: ScreenTools.defaultFontPointSize * 1.2
            }

            Repeater {
                model: _linkManager.linkConfigurations
                Layout.fillWidth: true

                RowLayout {
                    Layout.fillWidth: true
                    visible: !object.dynamic

                    QGCLabel {
                        Layout.fillWidth: false
                        text: object.linkType === LinkConfiguration.TypeTcp ? "TCP" : object.linkType === LinkConfiguration.TypeUdp ? "UDP" : object.linkType === LinkConfiguration.TypeSerial ? "Serial" : "Unknown"
                        font.family: ScreenTools.tecentFontFamily
                    }
                    QGCLabel {
                        Layout.fillWidth: true
                        text: object.name
                    }
                    QGCColoredImage {
                        height: ScreenTools.minTouchPixels
                        width: height
                        sourceSize.height: height
                        fillMode: Image.PreserveAspectFit
                        mipmap: true
                        smooth: true
                        color: qgcPalEdit.text
                        source: "/res/pencil.svg"
                        enabled: !object.link

                        QGCPalette {
                            id: qgcPalEdit
                            colorGroupEnabled: parent.enabled
                        }

                        QGCMouseArea {
                            fillItem: parent
                            onClicked: {
                                var editingConfig = _linkManager.startConfigurationEditing(object)
                                editLoader.sourceComponent = editPage
                                editLoader.item.editConfig(object, editingConfig)
                            }
                        }
                    }
                    QGCColoredImage {
                        height: ScreenTools.minTouchPixels
                        width: height
                        sourceSize.height: height
                        fillMode: Image.PreserveAspectFit
                        mipmap: true
                        smooth: true
                        color: qgcPalDelete.text
                        source: "/res/TrashDelete.svg"

                        QGCPalette {
                            id: qgcPalDelete
                            colorGroupEnabled: parent.enabled
                        }

                        QGCMouseArea {
                            fillItem: parent
                            onClicked: mainWindow.showMessageDialog(qsTr("Delete Link"), qsTr("Are you sure you want to delete '%1'?").arg(object.name), Dialog.Ok | Dialog.Cancel, function () {
                                _linkManager.removeConfiguration(object)
                            })
                        }
                    }
                    QGCButton {
                        text: object.link ? qsTr("Disconnect") : qsTr("Connect")
                        onClicked: {
                            if (object.link) {
                                object.link.disconnect()
                            } else {
                                _linkManager.createConnectedLink(object)
                            }
                        }
                    }
                }
            }
        }

        // 右侧：编辑页面
        Loader {
            id: editLoader
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 40
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
        }
    }

    // 编辑页面 Component
    Component {
        id: editPage

        ColumnLayout {
            property var originalConfig: null
            property var editingConfig: null
            property bool editing: false

            function editConfig(object, config) {
                originalConfig = object
                editingConfig = config
                editing = true
            }

            QGCLabel {
                text: "Edit Link"
                font.bold: true
                font.pointSize: ScreenTools.defaultFontPointSize * 1.2
            }

            RowLayout {
                QGCLabel { text: qsTr("Name") }
                QGCTextField {
                    id: nameField
                    Layout.fillWidth: true
                    text: editingConfig ? editingConfig.name : ""
                    placeholderText: qsTr("Enter name")
                }
            }

            QGCCheckBoxSlider {
                Layout.fillWidth: true
                text: qsTr("Automatically Connect on Start")
                checked: editingConfig ? editingConfig.autoConnect : false
                onCheckedChanged: if (editingConfig) editingConfig.autoConnect = checked
            }

            QGCCheckBoxSlider {
                Layout.fillWidth: true
                text: qsTr("High Latency")
                checked: editingConfig ? editingConfig.highLatency : false
                onCheckedChanged: if (editingConfig) editingConfig.highLatency = checked
            }

            Loader {
                id: linkSettingsLoader
                source: subEditConfig ? settingsURLForType(subEditConfig.linkType) : ""

                property var subEditConfig: editingConfig
                property int _firstColumnWidth: ScreenTools.defaultFontPixelWidth * 12
                property int _secondColumnWidth: ScreenTools.defaultFontPixelWidth * 30
                property int _rowSpacing: ScreenTools.defaultFontPixelHeight / 2
                property int _colSpacing: ScreenTools.defaultFontPixelWidth / 2
            }

            function settingsURLForType(type) {
                switch (type) {
                case LinkConfiguration.TypeTcp: return "XFTcpSettings.qml"
                case LinkConfiguration.TypeUdp: return "XFUdpSettings.qml"
                case LinkConfiguration.TypeSerial: return "XFSerialSettings.qml"
                default: return ""
                }
            }

            RowLayout {
                Layout.fillWidth: true
                QGCButton {
                    text: qsTr("OK")
                    onClicked: {
                        if (linkSettingsLoader.item) {
                            linkSettingsLoader.item.saveSettings()
                        }
                        if (editingConfig) {
                            editingConfig.name = nameField.text
                            if (originalConfig) {
                                _linkManager.endConfigurationEditing(originalConfig, editingConfig)
                            }
                        }
                        editLoader.sourceComponent = null
                    }
                }
                QGCButton {
                    text: qsTr("Cancel")
                    onClicked: {
                        _linkManager.cancelConfigurationEditing(editingConfig)
                        editLoader.sourceComponent = null
                    }
                }
            }
        }
    }
}