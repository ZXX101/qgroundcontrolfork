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
import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.ScreenTools
import QGroundControl.Palette

QGCFlickable {
    property var _linkManager: QGroundControl.linkManager
    property var _autoConnectSettings: QGroundControl.settingsManager.autoConnectSettings

    //videosettings page property
    // property var _settingsManager: QGroundControl.settingsManager
    // property var _videoManager: QGroundControl.videoManager
    // property var _videoSettings: _settingsManager.videoSettings
    // property string _videoSource: _videoSettings.videoSource.rawValue
    // property bool _isGST: _videoManager.gstreamerEnabled
    // property bool _isStreamSource: _videoManager.isStreamSource
    // property bool _isUDP264: _isStreamSource && (_videoSource === _videoSettings.udp264VideoSource)
    // property bool _isUDP265: _isStreamSource && (_videoSource === _videoSettings.udp265VideoSource)
    // property bool _isRTSP: _isStreamSource && (_videoSource === _videoSettings.rtspVideoSource)
    // property bool _isTCP: _isStreamSource && (_videoSource === _videoSettings.tcpVideoSource)
    // property bool _isMPEGTS: _isStreamSource && (_videoSource === _videoSettings.mpegtsVideoSource)
    // property bool _videoAutoStreamConfig: _videoManager.autoStreamConfigured
    // property bool _videoSourceDisabled: _videoSource === _videoSettings.disabledVideoSource
    // property real _urlFieldWidth: ScreenTools.defaultFontPixelWidth * 40
    // property bool _requiresUDPUrl: _isUDP264 || _isUDP265 || _isMPEGTS

    RowLayout {
        anchors.fill: parent
        spacing: ScreenTools.defaultDialogControlSpacing * 2

        // 左侧：连接列表
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: ScreenTools.defaultFontPixelWidth * 20
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft

            QGCLabel {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.preferredHeight: visible ? implicitHeight : 0
                visible: linkConfigurationsRepeater.visibleItemCount === 0
                text: qsTr("No protocols yet. Add a protocol on the right form to connect")
                wrapMode: Text.WordWrap
                font.bold: true
                font.pointSize: ScreenTools.defaultFontPointSize
            }

            Repeater {
                id: linkConfigurationsRepeater
                model: _linkManager.linkConfigurations
                Layout.fillWidth: true

                property int visibleItemCount: 0

                function refreshVisibleItemCount() {
                    let visibleCount = 0
                    for (let i = 0; i < count; ++i) {
                        const delegateItem = itemAt(i)
                        if (delegateItem && delegateItem.visible) {
                            ++visibleCount
                        }
                    }
                    visibleItemCount = visibleCount
                }

                onItemAdded: Qt.callLater(refreshVisibleItemCount)
                onItemRemoved: Qt.callLater(refreshVisibleItemCount)
                Component.onCompleted: Qt.callLater(refreshVisibleItemCount)

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 2
                    visible: !object.dynamic
                    onVisibleChanged: Qt.callLater(linkConfigurationsRepeater.refreshVisibleItemCount)
                    Rectangle {
                        anchors.fill: parent
                        color: "black"
                        radius: ScreenTools.smallFontPixelHeight
                    }
                    RowLayout {

                        anchors.leftMargin: ScreenTools.defaultFontPixelWidth
                        anchors.rightMargin: ScreenTools.defaultFontPixelWidth
                        anchors.fill: parent

                        QGCLabel {
                            Layout.fillWidth: false
                            text: object.linkType === LinkConfiguration.TypeTcp ? qsTr("TCP") : object.linkType === LinkConfiguration.TypeUdp ? qsTr("UDP") : object.linkType === LinkConfiguration.TypeSerial ? qsTr("Serial") : qsTr("Unknown")
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
                                    bar.currentIndex = 0;
                                    var editingConfig = _linkManager.startConfigurationEditing(object);
                                    dronesPageLoader.sourceComponent = editLinkComponent;
                                    dronesPageLoader.item.init(object, editingConfig);
                                }
                            }
                        }

                        QGCButton {
                            text: object.link ? qsTr("Disconnect") : qsTr("Connect")
                            iconSource: "qrc:/xfres/linkDisconnected.png"
                            onClicked: {
                                if (object.link) {
                                    object.link.disconnect();
                                } else {
                                    _linkManager.createConnectedLink(object);
                                }
                            }
                            backgroundColor: "transparent"
                        }
                    }
                    Image {
                        height: ScreenTools.minTouchPixels
                        width: height
                        sourceSize.height: height
                        fillMode: Image.PreserveAspectFit
                        source: "/xfres/deleteProtocol.png"
                        anchors.horizontalCenter: parent.right
                        anchors.verticalCenter: parent.verticalCenter



                        QGCMouseArea {
                            fillItem: parent
                            onClicked: mainWindow.showMessageDialog(qsTr("Delete Link"), qsTr("Are you sure you want to delete '%1'?").arg(object.name), Dialog.Ok | Dialog.Cancel, function () {
                                _linkManager.removeConfiguration(object);
                            })
                        }
                    }
                }
            }
        }

        // 右侧：编辑页面（始终显示）
        ColumnLayout {
            Layout.minimumWidth: ScreenTools.defaultFontPixelWidth * 50
            Layout.maximumWidth: ScreenTools.defaultFontPixelWidth * 50
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft

            TabBar {
                id: bar
                Layout.fillWidth: true
                spacing: 0
                background: Rectangle {
                    color: "transparent"
                }

                TabButton {
                    text: qsTr("Drones")
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: qgcPal.buttonText
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: "transparent"
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width * 0.8
                            height: 2
                            color: "#154D25"
                            visible: parent.parent.checked
                        }
                    }
                }
                TabButton {
                    text: qsTr("POD")
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: qgcPal.buttonText
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: "transparent"
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width * 0.8
                            height: 2
                            color: "#154D25"
                            visible: parent.parent.checked
                        }
                    }
                }
                TabButton {
                    text: qsTr("Others")
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: qgcPal.buttonText
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: "transparent"
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width * 0.8
                            height: 2
                            color: "#154D25"
                            visible: parent.parent.checked
                        }
                    }
                }
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: bar.currentIndex

                // 无人机页面
                Loader {
                    id: dronesPageLoader
                    sourceComponent: newLinkComponent
                }

                // 云台页面
                Loader {
                    id: podPageLoader
                    sourceComponent: podSettingComponent
                }
                // 其他页面
                ColumnLayout {
                    RowLayout {
                        QGCLabel {
                            text: qsTr("Nothing here")
                        }
                    }
                }
            }
        }
    }

    // 新建链接页面
    Component {
        id: newLinkComponent

        ColumnLayout {
            QGCLabel {
                text: qsTr("No link selected")
                font.pointSize: ScreenTools.defaultFontPointSize * 1.1
                Layout.alignment: Qt.AlignCenter
            }

            QGCButton {

                Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                text: qsTr("Add New Link")
                onClicked: {
                    var editingConfig = _linkManager.createConfiguration(LinkConfiguration.TypeTcp, "");
                    dronesPageLoader.sourceComponent = editLinkComponent;
                    dronesPageLoader.item.init(null, editingConfig);
                }
            }
        }
    }

    // 编辑链接页面
    Component {
        id: editLinkComponent

        Item {
            anchors.fill: parent

            property var originalConfig: null
            property var editingConfig: null

            function init(orig, config) {
                originalConfig = orig;
                editingConfig = config;
                linkSettingsLoader.source = settingsURLForType(config.linkType);
                updateRadioButtons();
            }

            function updateRadioButtons() {
                for (var i = 0; i < typeRepeater.count; i++) {
                    typeRepeater.itemAt(i).checked = editingConfig && editingConfig.linkType === typeRepeater.model[i].type;
                }
            }

            function settingsURLForType(type) {
                switch (type) {
                case LinkConfiguration.TypeTcp:
                    return "XFTcpSettings.qml";
                case LinkConfiguration.TypeUdp:
                    return "XFUdpSettings.qml";
                case LinkConfiguration.TypeSerial:
                    return "XFSerialSettings.qml";
                default:
                    return "";
                }
            }

            ColumnLayout {
                anchors.fill: parent

                QGCFlickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: mainLayout.width
                    contentHeight: mainLayout.height

                    ColumnLayout {
                        id: mainLayout
                        x: Math.max(0, parent.width / 2 - width / 2)
                        width: Math.max(implicitWidth, ScreenTools.defaultFontPixelWidth * 50)
                        spacing: ScreenTools.defaultFontPixelHeight

                        QGCLabel {
                            text: originalConfig ? qsTr("Edit Link") : qsTr("New Link")
                            font.bold: true
                            font.pointSize: ScreenTools.defaultFontPointSize * 1.2
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            QGCLabel { text: qsTr("Type") }
                            Repeater {
                                id: typeRepeater
                                model: [
                                    { type: LinkConfiguration.TypeTcp, name: qsTr("TCP") },
                                    { type: LinkConfiguration.TypeUdp, name: qsTr("UDP") },
                                    { type: LinkConfiguration.TypeSerial, name: qsTr("Serial") }
                                ]
                                QGCRadioButton {
                                    text: modelData.name
                                    enabled: originalConfig == null
                                    onCheckedChanged: if (checked && originalConfig == null) {
                                        var newConfig = _linkManager.createConfiguration(modelData.type, nameField.text);
                                        editingConfig = newConfig;
                                        linkSettingsLoader.source = settingsURLForType(newConfig.linkType);
                                    }
                                }
                            }
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
                            onCheckedChanged: if (editingConfig)
                                editingConfig.autoConnect = checked
                        }

                        QGCCheckBoxSlider {
                            Layout.fillWidth: true
                            text: qsTr("High Latency")
                            checked: editingConfig ? editingConfig.highLatency : false
                            onCheckedChanged: if (editingConfig)
                                editingConfig.highLatency = checked
                        }

                        Loader {
                            id: linkSettingsLoader
                            property var subEditConfig: editingConfig
                            property int _firstColumnWidth: ScreenTools.defaultFontPixelWidth * 12
                            property int _secondColumnWidth: ScreenTools.defaultFontPixelWidth * 30
                            property int _rowSpacing: ScreenTools.defaultFontPixelHeight / 2
                            property int _colSpacing: ScreenTools.defaultFontPixelWidth / 2
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    QGCButton {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        text: qsTr("OK")
                        onClicked: {
                            if (linkSettingsLoader.item) linkSettingsLoader.item.saveSettings();
                            if (editingConfig) {
                                editingConfig.name = nameField.text;
                                if (originalConfig) {
                                    _linkManager.endConfigurationEditing(originalConfig, editingConfig);
                                } else {
                                    editingConfig.dynamic = false;
                                    _linkManager.endCreateConfiguration(editingConfig);
                                }
                            }
                            dronesPageLoader.sourceComponent = newLinkComponent;
                        }
                    }
                    QGCButton {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        text: qsTr("Cancel")
                        onClicked: {
                            if (editingConfig) {
                                if (originalConfig) {
                                    _linkManager.cancelConfigurationEditing(editingConfig);
                                } else {
                                    delete editingConfig;
                                }
                            }
                            dronesPageLoader.sourceComponent = newLinkComponent;
                        }
                    }
                }
            }
        }
    }

    //视频编辑页面
    Component {
        id: podSettingComponent

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            QGCFlickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                // contentWidth: videoSettings.item.implicitWidth
                contentHeight: videoSettings.item ? videoSettings.item.implicitHeight : 0
                Loader {
                    id: videoSettings
                    source: "XFVideoSettings.qml"
                    width: parent.width
                }
            }
        }
    }
}
