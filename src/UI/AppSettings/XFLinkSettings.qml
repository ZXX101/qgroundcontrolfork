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

    // 编辑状态
    property var currentOriginalConfig: null
    property var currentEditingConfig: null
    property bool isEditing: false

    function startEditing(object) {
        if (currentEditingConfig && isEditing) {
            _linkManager.cancelConfigurationEditing(currentEditingConfig)
        }
        var editingConfig = _linkManager.startConfigurationEditing(object)
        currentOriginalConfig = object
        currentEditingConfig = editingConfig
        isEditing = true
        bar.currentIndex = 0
    }

    function cancelEditing() {
        if (currentEditingConfig) {
            _linkManager.cancelConfigurationEditing(currentEditingConfig)
        }
        isEditing = false
        currentOriginalConfig = null
        currentEditingConfig = null
    }

    function saveAndClose() {
        if (linkSettingsLoader.item) {
            linkSettingsLoader.item.saveSettings()
        }
        if (currentEditingConfig) {
            currentEditingConfig.name = nameField.text
            if (currentOriginalConfig) {
                _linkManager.endConfigurationEditing(currentOriginalConfig, currentEditingConfig)
            }
        }
        isEditing = false
        currentOriginalConfig = null
        currentEditingConfig = null
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
                            onClicked: startEditing(object)
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

        // 右侧：编辑页面（始终显示）
        ColumnLayout {
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 40
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft

            TabBar {
                id: bar
                Layout.fillWidth: true

                TabButton {
                    text: qsTr("Drones")
                }
                TabButton {
                    text: qsTr("POD")
                }
                TabButton {
                    text: qsTr("Others")
                }
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: bar.currentIndex

                // 无人机页面
                ColumnLayout {
                    // 编辑状态时显示编辑表单
                    visible: isEditing

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
                            text: currentEditingConfig ? currentEditingConfig.name : ""
                            placeholderText: qsTr("Enter name")
                        }
                    }

                    QGCCheckBoxSlider {
                        Layout.fillWidth: true
                        text: qsTr("Automatically Connect on Start")
                        checked: currentEditingConfig ? currentEditingConfig.autoConnect : false
                        onCheckedChanged: if (currentEditingConfig) currentEditingConfig.autoConnect = checked
                    }

                    QGCCheckBoxSlider {
                        Layout.fillWidth: true
                        text: qsTr("High Latency")
                        checked: currentEditingConfig ? currentEditingConfig.highLatency : false
                        onCheckedChanged: if (currentEditingConfig) currentEditingConfig.highLatency = checked
                    }

                    Loader {
                        id: linkSettingsLoader
                        source: currentEditingConfig ? settingsURLForType(currentEditingConfig.linkType) : ""

                        property var subEditConfig: currentEditingConfig
                        property int _firstColumnWidth: ScreenTools.defaultFontPixelWidth * 12
                        property int _secondColumnWidth: ScreenTools.defaultFontPixelWidth * 30
                        property int _rowSpacing: ScreenTools.defaultFontPixelHeight / 2
                        property int _colSpacing: ScreenTools.defaultFontPixelWidth / 2
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        QGCButton {
                            text: qsTr("OK")
                            onClicked: saveAndClose()
                        }
                        QGCButton {
                            text: qsTr("Cancel")
                            onClicked: cancelEditing()
                        }
                    }
                }

                // 空白页面（不在编辑时显示）
                ColumnLayout {
                    visible: !isEditing
                    QGCLabel {
                        text: "Select a link to edit"
                        font.pointSize: ScreenTools.defaultFontPointSize * 1.1
                    }
                }

                // 云台页面
                ColumnLayout {
                    RowLayout {
                        QGCLabel {
                            text: "Source"
                        }
                        QGCTextField {
                            Layout.fillWidth: true
                            placeholderText: "Select source"
                        }
                    }
                    RowLayout {
                        QGCLabel {
                            text: "Name"
                        }
                        QGCTextField {
                            Layout.fillWidth: true
                            placeholderText: "enter protocol name"
                        }
                    }
                    RowLayout {
                        QGCLabel {
                            text: "High Latency"
                        }
                        QGCCheckBox {
                            checked: false
                        }
                    }
                    RowLayout {
                        QGCLabel {
                            text: "Host Address"
                        }
                        QGCTextField {
                            Layout.fillWidth: true
                            placeholderText: "0.0.0.0"
                        }
                    }
                    RowLayout {
                        QGCLabel {
                            text: "Port"
                        }
                        QGCTextField {
                            Layout.fillWidth: true
                            placeholderText: "14540"
                        }
                    }
                    RowLayout {
                        QGCLabel {
                            text: "Auto Connect"
                        }
                        QGCCheckBox {
                            checked: false
                        }
                    }
                }

                // 其他页面
                ColumnLayout {
                    RowLayout {
                        QGCLabel {
                            text: "Type"
                        }
                        QGCRadioButton {
                            text: "TCP"
                        }
                        QGCRadioButton {
                            text: "UART"
                        }
                        QGCRadioButton {
                            text: "UDP"
                        }
                    }
                    RowLayout {
                        QGCLabel {
                            text: "Name"
                        }
                        QGCTextField {
                            Layout.fillWidth: true
                            placeholderText: "enter protocol name"
                        }
                    }
                    RowLayout {
                        QGCLabel {
                            text: "High Latency"
                        }
                        QGCCheckBox {
                            checked: false
                        }
                    }
                    RowLayout {
                        QGCLabel {
                            text: "Host Address"
                        }
                        QGCTextField {
                            Layout.fillWidth: true
                            placeholderText: "0.0.0.0"
                        }
                    }
                    RowLayout {
                        QGCLabel {
                            text: "Port"
                        }
                        QGCTextField {
                            Layout.fillWidth: true
                            placeholderText: "14540"
                        }
                    }
                    RowLayout {
                        QGCLabel {
                            text: "Auto Connect"
                        }
                        QGCCheckBox {
                            checked: false
                        }
                    }
                }
            }
        }
    }
}