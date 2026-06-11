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

    // 类型到URL的映射
    property var typeToURL: ({
            [LinkConfiguration.TypeTcp]: "XFTcpSettings.qml",
            [LinkConfiguration.TypeUdp]: "XFUdpSettings.qml",
            [LinkConfiguration.TypeSerial]: "XFSerialSettings.qml"
        })

    RowLayout {
        anchors.fill: parent
        spacing: ScreenTools.defaultDialogControlSpacing * 5
        Loader {
            sourceComponent: connectpage
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "red"
                z: -1
            }
        }

        Loader {
            id: settingPageLoader
            sourceComponent: settingPage
            Layout.preferredWidth: item ? item.implicitWidth : 0
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
        }
    }

    //连接页面
    Component {
        id: connectpage
        ColumnLayout {
            id: connectlistlayout
            QGCLabel {
                id: noconnectionlabel
                text: "No protocol,please config protocol in right panel!"
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                visible: _linkManager.linkConfigurations.count === 0
            }
            Repeater {
                model: _linkManager.linkConfigurations

                RowLayout {
                    Layout.alignment: Qt.AlignTop | Qt.AlignLeft
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
                                var item = settingPageLoader.item;
                                var editingConfig = _linkManager.startConfigurationEditing(object);
                                item.showDronesPage(object, editingConfig);
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
                                _linkManager.removeConfiguration(object);
                            })
                        }
                    }
                    QGCButton {
                        text: object.link ? qsTr("Disconnect") : qsTr("Connect")
                        onClicked: {
                            if (object.link) {
                                object.link.disconnect();
                            } else {
                                _linkManager.createConnectedLink(object);
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: settingPage

        ColumnLayout {
            property alias tabIndex: bar.currentIndex
            property alias dronesItem: dronesPageLoader.item

            function showDronesPage(object, config) {
                if (dronesPageLoader.item) {
                    dronesPageLoader.item.reset();
                }
                dronesPageLoader.active = true;
                dronesPageLoader.item.editConfig(object, config);
                bar.currentIndex = 0;
            }

            function hideDronesPage() {
                if (dronesPageLoader.item) {
                    dronesPageLoader.item.reset();
                }
                dronesPageLoader.active = false;
            }

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
                id: settingsPageStack
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: bar.currentIndex
                Loader {
                    id: dronesPageLoader
                    sourceComponent: dronesPage
                    active: false
                }
                Loader {
                    sourceComponent: podPage
                }
                Loader {
                    sourceComponent: othersPage
                }
            }
        }
    }

    //无人机页面
    Component {
        id: dronesPage

        ColumnLayout {
            id: dronesPageRoot
            property var originalConfig: null
            property var editingConfig: null
            property string settingsURL: ""
            property int selectedType: -1
            property bool editingReady: false

            function editConfig(object, config) {
                originalConfig = object;
                editingConfig = config;
                selectedType = config.linkType;
                settingsURL = typeToURL[config.linkType] || "XFTcpSettings.qml";
                editingReady = true;
                console.log("editingConfig.name",editingConfig.name)
                console.log("editingConfig.hostList",editingConfig.hostList)
                console.log("editingConfig.localPort",editingConfig.localPort)
                console.log("editingConfig.baud",editingConfig.baud)
                console.log("editingConfig.portName",editingConfig.portName)
                console.log("editingConfig.host",editingConfig.host)
                console.log("editingConfig.port",editingConfig.port)
            }

            function reset() {
                if (editingConfig) {
                    _linkManager.cancelConfigurationEditing(editingConfig);
                }
                originalConfig = null;
                editingConfig = null;
                selectedType = -1;
                settingsURL = "";
                editingReady = false;
            }

            // 使用Repeater简化RadioButton
            RowLayout {
                QGCLabel {
                    text: "Type"
                }
                Repeater {
                    model: [
                        {
                            type: LinkConfiguration.TypeTcp,
                            name: "TCP",
                            url: "XFTcpSettings.qml"
                        },
                        {
                            type: LinkConfiguration.TypeSerial,
                            name: "Serial",
                            url: "XFSerialSettings.qml"
                        },
                        {
                            type: LinkConfiguration.TypeUdp,
                            name: "UDP",
                            url: "XFUdpSettings.qml"
                        }
                    ]
                    QGCRadioButton {
                        text: modelData.name
                        checked: dronesPageRoot.selectedType === modelData.type
                        enabled: dronesPageRoot.originalConfig == null
                        onCheckedChanged: if (checked) {
                            dronesPageRoot.settingsURL = modelData.url;
                            dronesPageRoot.editingConfig = _linkManager.createConfiguration(modelData.type, nameField.text);
                        }
                    }
                }
            }
            RowLayout {
                QGCLabel {
                    text: "Name"
                }
                QGCTextField {
                    id: nameField
                    Layout.fillWidth: true
                    text: dronesPageRoot.editingConfig ? dronesPageRoot.editingConfig.name : ""
                    placeholderText: qsTr("enter protocol name")
                }
            }
            QGCCheckBoxSlider {
                Layout.fillWidth: true
                text: qsTr("High Latency")
                checked: dronesPageRoot.editingConfig ? dronesPageRoot.editingConfig.highLatency : false
                onCheckedChanged: if (dronesPageRoot.editingConfig)
                    dronesPageRoot.editingConfig.highLatency = checked
            }

            Loader {
                id: linkSettingsLoader
                source: subSettingsURL
                active: dronesPageRoot.editingReady

                property var subEditConfig: dronesPageRoot.editingConfig
                property string subSettingsURL: dronesPageRoot.settingsURL
                property int _firstColumnWidth: ScreenTools.defaultFontPixelWidth * 12
                property int _secondColumnWidth: ScreenTools.defaultFontPixelWidth * 30
                property int _rowSpacing: ScreenTools.defaultFontPixelHeight / 2
                property int _colSpacing: ScreenTools.defaultFontPixelWidth / 2
            }
            QGCCheckBoxSlider {
                Layout.fillWidth: true
                text: qsTr("Automatically Connect on Start")
                checked: dronesPageRoot.editingConfig ? dronesPageRoot.editingConfig.autoConnect : false
                onCheckedChanged: if (dronesPageRoot.editingConfig)
                    dronesPageRoot.editingConfig.autoConnect = checked
            }
            RowLayout {
                Layout.fillWidth: true
                QGCButton {
                    Text {
                        id: btnAccept
                        text: qsTr("OK")
                    }
                    onClicked: {
                        if (linkSettingsLoader.item) {
                            linkSettingsLoader.item.saveSettings();
                        }
                        if (dronesPageRoot.editingConfig) {
                            dronesPageRoot.editingConfig.name = nameField.text;
                            if (dronesPageRoot.originalConfig) {
                                _linkManager.endConfigurationEditing(dronesPageRoot.originalConfig, dronesPageRoot.editingConfig);
                            } else {
                                dronesPageRoot.editingConfig.dynamic = false;
                                _linkManager.endCreateConfiguration(dronesPageRoot.editingConfig);
                            }
                        }
                        settingPageLoader.item.hideDronesPage();
                    }
                }
                QGCButton {
                    Text {
                        id: btnReject
                        text: qsTr("Cancel")
                    }
                    onClicked: {
                        _linkManager.cancelConfigurationEditing(dronesPageRoot.editingConfig);
                        settingPageLoader.item.hideDronesPage();
                    }
                }
            }
        }
    }

    //云台页面
    Component {
        id: podPage

        ColumnLayout {
            RowLayout {
                LabelledFactComboBox {
                    Layout.fillWidth: true
                    label: qsTr("Source")
                    indexModel: false
                }
            }
            RowLayout {
                QGCLabel {
                    text: "Name"
                }
                QGCTextField {
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
                    placeholderText: "0.0.0.0"
                }
            }
            RowLayout {
                QGCLabel {
                    text: "Port"
                }
                QGCTextField {
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

    //其他页面
    Component {
        id: othersPage

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
                    placeholderText: "0.0.0.0"
                }
            }
            RowLayout {
                QGCLabel {
                    text: "Port"
                }
                QGCTextField {
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
