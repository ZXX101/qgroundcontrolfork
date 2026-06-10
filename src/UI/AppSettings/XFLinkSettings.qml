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
        Loader {
            sourceComponent: connectpage
            // Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            // width: parent.width
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
        //左侧连接列表
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
                                item.tabIndex = 0;
                                var editingConfig = _linkManager.startConfigurationEditing(object);
                                console.log("editingConfig.name",editingConfig.name)
                                console.log("editingConfig.linkType",editingConfig.linkType)
                                console.log("editingConfig.type",editingConfig.type)
                                console.log("editingConfig.portName",editingConfig.portName)
                                console.log("editingConfig.portDisplayName",editingConfig.portDisplayName)
                                console.log("editingConfig.baud",editingConfig.baud)
                                item.showDronesPage(object,editingConfig)
                                // var editingConfig = _linkManager.startConfigurationEditing(object)
                                // linkDialogComponent.createObject(mainWindow, { editingConfig: editingConfig, originalConfig: object }).open()
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

            //右侧设置列表
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
                //第一个页面：Drones - 通过Loader加载Component
                Loader {
                    id: dronesPageLoader
                    sourceComponent: dronesPage
                    active: false
                }
                //第二个页面：POD
                Loader {
                    sourceComponent: podPage
                }

                //第三个页面：Others
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
            property string settingsURL: null
            property int selectedType: null
            // Component.onCompleted: {
            //     editingConfig = _linkManager.createConfiguration(LinkConfiguration.TypeTcp, "");
            //     settingsURL = "XFTcpSettings.qml";
            // }
            function editConfig(object, config) {
                originalConfig = object;
                editingConfig = config;
                selectedType = config.linkType;
                if (config.linkType === LinkConfiguration.TypeTcp)
                    settingsURL = "XFTcpSettings.qml";
                if (config.linkType === LinkConfiguration.TypeUdp)
                    settingsURL = "XFUdpSettings.qml";
                if (config.linkType === LinkConfiguration.TypeSerial)
                    settingsURL = "XFSerialSettings.qml";
            }
            function reset() {
                if (editingConfig) {
                    _linkManager.cancelConfigurationEditing(editingConfig);
                }
                originalConfig = null;
                editingConfig = null;
                selectedType = LinkConfiguration.TypeTcp;
            }

            RowLayout {
                QGCLabel {
                    text: "Type"
                }
                QGCRadioButton {
                    text: "TCP"
                    checked: dronesPageRoot.selectedType === LinkConfiguration.TypeTcp
                    enabled: dronesPageRoot.originalConfig == null
                    onCheckedChanged: {
                        if (checked) {
                            dronesPageRoot.settingsURL = "XFTcpSettings.qml";
                            dronesPageRoot.editingConfig = _linkManager.createConfiguration(LinkConfiguration.TypeTcp, nameField.text);
                        }
                    }
                }
                QGCRadioButton {
                    text: "Serial"
                    checked: dronesPageRoot.selectedType === LinkConfiguration.TypeSerial
                    enabled: dronesPageRoot.originalConfig == null
                    onCheckedChanged: {
                        if (checked) {
                            dronesPageRoot.settingsURL = "XFSerialSettings.qml";
                            dronesPageRoot.editingConfig = _linkManager.createConfiguration(LinkConfiguration.TypeSerial, nameField.text);
                        }
                    }
                }
                QGCRadioButton {
                    text: "UDP"
                    checked: dronesPageRoot.selectedType === LinkConfiguration.TypeUdp
                    enabled: dronesPageRoot.originalConfig == null
                    onCheckedChanged: {
                        if (checked) {
                            dronesPageRoot.settingsURL = "XFUdpSettings.qml";
                            dronesPageRoot.editingConfig = _linkManager.createConfiguration(LinkConfiguration.TypeUdp, nameField.text);
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
                    text: dronesPageRoot.editingConfig.name
                    placeholderText: qsTr("enter protocol name")
                }
            }
            QGCCheckBoxSlider {
                Layout.fillWidth: true
                text: qsTr("High Latency")
                checked: dronesPageRoot.editingConfig.highLatency
                onCheckedChanged: dronesPageRoot.editingConfig.highLatency = checked
            }

            Loader {
                id: linkSettingsLoader
                source: subSettingsURL

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
                checked: dronesPageRoot.editingConfig.autoConnect
                onCheckedChanged: dronesPageRoot.editingConfig.autoConnect = checked
            }
            RowLayout {
                Layout.fillWidth: true
                QGCButton {

                    Text {
                        id: btnAccept
                        text: qsTr("OK")
                    }
                    onClicked: {
                        linkSettingsLoader.item.saveSettings();
                        dronesPageRoot.editingConfig.name = nameField.text;
                        if (dronesPageRoot.originalConfig) {
                            _linkManager.endConfigurationEditing(dronesPageRoot.originalConfig, dronesPageRoot.editingConfig);
                        } else {
                            // If it was edited, it's no longer "dynamic"
                            dronesPageRoot.editingConfig.dynamic = false;
                            _linkManager.endCreateConfiguration(editingConfig);
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
                        _linkManager.cancelConfigurationEditing(editingConfig);
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
                    // fact: _videoSettings.videoSource
                    // visible: fact.visible
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
