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
import QGroundControl.AutoPilotPlugin
import QGroundControl.MultiVehicleManager

//通用页面主容器，覆盖整个窗口，显示通用配置界面
//包含左侧导航按钮列表、右侧内容区域、顶部返回按钮
//左侧导航包含8个子页面项：连接、设备配置（含二级菜单）、飞行参数、安全、设备日志、Mavlink Console、Mavlink Analyze、软件设置
Rectangle {
    id: xfCommonView
    anchors.fill: parent
    visible: false
    color: qgcPal.window
    z: QGroundControl.zOrderTopMost

    readonly property real _defaultTextHeight: ScreenTools.defaultFontPixelHeight
    readonly property real _defaultTextWidth: ScreenTools.defaultFontPixelWidth
    readonly property real _horizontalMargin: _defaultTextWidth / 2
    readonly property real _verticalMargin: _defaultTextHeight / 2

    //当前选中的一级菜单索引（0-7）
    property int currentPageIndex: 7
    //设备配置二级菜单索引
    property int deviceConfigSubIndex: 0

    //页面列表数据
    property var pageList: [
        {
            name: qsTr("连接"),
            url: "qrc:/qml/QGroundControl/AppSettings/XFLinkSettings.qml",
            icon: "qrc:/xfres/link.png"
        },
        {
            name: qsTr("设备配置"),
            icon: "qrc:/xfres/deviceConfig.png"
        },
        {
            name: qsTr("飞行参数"),
            url: "",
            icon: "qrc:/xfres/flightParams.png"
        },
        {
            name: qsTr("安全"),
            url: "",
            icon: "qrc:/xfres/safety.png"
        },
        {
            name: qsTr("设备日志"),
            url: "qrc:/qml/QGroundControl/AnalyzeView/XFLogDownloadPage.qml",
            icon: "qrc:/xfres/deviceLog.png"
        },
        {
            name: qsTr("Mavlink Console"),
            url: "qrc:/qml/QGroundControl/AnalyzeView/XFMAVLinkConsolePage.qml",
            icon: "qrc:/xfres/mavlink.png"
        },
        {
            name: qsTr("Mavlink Analyze"),
            url: "qrc:/qml/QGroundControl/AnalyzeView/XFMAVLinkInspectorPage.qml",
            icon: "qrc:/xfres/mavlinkInspect.png"
        },
        {
            name: qsTr("软件设置"),
            url: "qrc:/qml/QGroundControl/AppSettings/XFGeneralSettings.qml",
            icon: "qrc:/xfres/softwareSettings.png"
        }
    ]

    //设备配置二级菜单页面列表
    property var deviceConfigPages: [
        {
            name: qsTr("概况"),
            url: "qrc:/qml/QGroundControl/VehicleSetup/XFVehicleSummary.qml"
        },
        {
            name: qsTr("机架"),
            componentName: "airframe"
        },
        {
            name: qsTr("传感器"),
            componentName: "sensors"
        },
        {
            name: qsTr("通道设置"),
            componentName: "flightModes"
        },
        {
            name: qsTr("电源"),
            componentName: "power"
        },
        {
            name: qsTr("电机"),
            componentName: "motors"
        },
        {
            name: qsTr("遥控器"),
            url: "qrc:/qml/QGroundControl/VehicleSetup/JoystickConfig.qml"
        },
        {
            name: qsTr("PID调参"),
            componentName: "tuning"
        },
        {
            name: qsTr("参数"),
            url: "qrc:/qml/QGroundControl/VehicleSetup/SetupParameterEditor.qml"
        }
    ]

    //设备配置二级菜单是否展开
    property bool deviceConfigExpanded: false

    //飞控相关属性
    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property bool _fullParameterVehicleAvailable: QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable && (!_activeVehicle || !_activeVehicle.parameterManager.missingParameters)
    property var _vehicleComponents: _fullParameterVehicleAvailable && _activeVehicle ? _activeVehicle.autopilotPlugin.vehicleComponents : []

    //通过componentName查找对应的VehicleComponent对象
    function findVehicleComponent(componentName) {
        if (!_vehicleComponents || _vehicleComponents.length === 0) return null
        for (var i = 0; i < _vehicleComponents.length; i++) {
            var comp = _vehicleComponents[i]
            var name = comp.name.toLowerCase()
            if (componentName === "airframe" && (name === "airframe" || name === "frame")) return comp
            if (componentName === "sensors" && name === "sensors") return comp
            if (componentName === "flightModes" && name === "flight modes") return comp
            if (componentName === "power" && name === "power") return comp
            if (componentName === "motors" && (name === "motors" || name === "actuators")) return comp
            if (componentName === "tuning" && (name === "pid tuning" || name === "tuning")) return comp
        }
        return null
    }

    //获取某菜单项的QML加载URL（优先使用XF定制版）
    function getUrlForPage(page) {
        if (page.url && page.url !== "") return page.url
        if (page.componentName) {
            var comp = findVehicleComponent(page.componentName)
            if (comp && comp.setupSource.toString() !== "") {
                var url = comp.setupSource.toString()
                //替换为XF定制版QML
                if (page.componentName === "airframe") {
                    if (url.indexOf("PX4") !== -1) {
                        return "qrc:/qml/QGroundControl/AutoPilotPlugins/PX4/XFAirframeComponent.qml"
                    } else if (url.indexOf("APM") !== -1) {
                        return "qrc:/qml/QGroundControl/AutoPilotPlugins/APM/XFAPMAirframeComponent.qml"
                    }
                } else if (page.componentName === "sensors") {
                    if (url.indexOf("PX4") !== -1) {
                        return "qrc:/qml/QGroundControl/AutoPilotPlugins/PX4/XFSensorsComponent.qml"
                    } else if (url.indexOf("APM") !== -1) {
                        return "qrc:/qml/QGroundControl/AutoPilotPlugins/APM/XFAPMSensorsComponent.qml"
                    }
                } else if (page.componentName === "flightModes") {
                    if (url.indexOf("PX4") !== -1) {
                        return "qrc:/qml/QGroundControl/AutoPilotPlugins/PX4/XFPX4FlightModes.qml"
                    } else if (url.indexOf("APM") !== -1) {
                        return "qrc:/qml/QGroundControl/AutoPilotPlugins/APM/XFAPMFlightModesComponent.qml"
                    }
                } else if (page.componentName === "power") {
                    if (url.indexOf("PX4") !== -1) {
                        return "qrc:/qml/QGroundControl/AutoPilotPlugins/PX4/XFPowerComponent.qml"
                    } else if (url.indexOf("APM") !== -1) {
                        return "qrc:/qml/QGroundControl/AutoPilotPlugins/APM/XFAPMPowerComponent.qml"
                    }
                } else if (page.componentName === "motors") {
                    if (url.indexOf("PX4") !== -1) {
                        return "qrc:/qml/QGroundControl/AutoPilotPlugins/PX4/XFActuatorComponent.qml"
                    } else if (url.indexOf("APM") !== -1) {
                        return "qrc:/qml/QGroundControl/AutoPilotPlugins/APM/XFAPMMotorComponent.qml"
                    }
                } else if (page.componentName === "tuning") {
                    if (url.indexOf("PX4") !== -1) {
                        return "qrc:/qml/QGroundControl/AutoPilotPlugins/PX4/XFPX4TuningComponent.qml"
                    } else if (url.indexOf("APM") !== -1) {
                        return "qrc:/qml/QGroundControl/AutoPilotPlugins/APM/XFAPMTuningComponentCopter.qml"
                    }
                }
                return url
            }
        }
        return ""
    }

    //检查某菜单项是否可见（组件存在且setupSource非空）
    function isPageVisible(page) {
        if (page.url && page.url !== "") return true
        if (page.componentName) {
            var comp = findVehicleComponent(page.componentName)
            return comp && comp.setupSource.toString() !== ""
        }
        return false
    }

    //选择页面的函数
    function selectPage(index) {
        if (mainWindow.allowViewSwitch()) {
            currentPageIndex = index;
            deviceConfigExpanded = false;
            if (pageList[index].url !== "") {
                contentLoader.source = pageList[index].url;
            }
            updateButtonChecked();
        }
    }


    //更新按钮选中状态
    function updateButtonChecked() {
        button0.checked = (currentPageIndex === 0);
        button1.checked = (currentPageIndex === 1);
        button2.checked = (currentPageIndex === 2);
        button3.checked = (currentPageIndex === 3);
        button4.checked = (currentPageIndex === 4);
        button5.checked = (currentPageIndex === 5);
        button6.checked = (currentPageIndex === 6);
        button7.checked = (currentPageIndex === 7);
    }

    Component.onCompleted: {
        updateButtonChecked();
    }

    //阻塞鼠标区域
    DeadMouseArea {
        anchors.fill: parent
    }

    QGCPalette {
        id: qgcPal
    }

    //顶部返回按钮区域
    Rectangle {
        id: toolbar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: ScreenTools.toolbarHeight
        color: qgcPal.toolbarBackground

        RowLayout {
            anchors.leftMargin: _defaultTextWidth
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: _defaultTextWidth

            QGCLabel {
                text: qsTr("XF地面站 通用配置")
                font.pointSize: ScreenTools.largeFontPointSize
                font.family: ScreenTools.tecentFontFamily
            }
            QGCButton {
                id: buttonBack
                text: "Back"
                iconSource: "qrc:/xfres/back.png"
                // Layout.fillWidth: true
                // checked: currentPageIndex === 0
                // 后期要改颜色就该qgcPal里面的值
                // background: Rectangle {
                //     color:      qgcPal.buttonHighlight
                //     opacity:    pressed ? 1 : enabled && hovered ? .6 : .2
                //     radius:     ScreenTools.defaultFontPixelWidth / 2
                // }
                onClicked: {
                    if (mainWindow.allowViewSwitch()) {
                        xfCommonView.visible = false;
                        mainWindow.showFlyView();
                    }
                }
            }
        }

        QGCMouseArea {
            anchors.fill: parent
            onClicked: {
                if (mainWindow.allowViewSwitch()) {
                    xfCommonView.visible = false;
                    mainWindow.showFlyView();
                }
            }
        }
    }

    //左侧按钮列表（使用QGCFlickable + ColumnLayout，与SetupView一致）
    QGCFlickable {
        id: buttonScroll
        width: _defaultTextWidth * 18
        anchors.topMargin: _verticalMargin
        anchors.top: toolbar.bottom
        anchors.bottom: parent.bottom
        anchors.leftMargin: _horizontalMargin
        anchors.left: parent.left
        contentHeight: buttonColumn.height
        flickableDirection: Flickable.VerticalFlick
        clip: true

        ColumnLayout {
            id: buttonColumn
            spacing: _defaultTextHeight / 4
            width: buttonScroll.width - _defaultTextWidth

            //页面0: 连接
            ConfigButton {
                id: button0
                text: pageList[0].name
                icon.source: pageList[0].icon
                Layout.fillWidth: true
                checked: currentPageIndex === 0
                onClicked: selectPage(0)
            }

            //页面1: 设备配置（含二级菜单）
            ColumnLayout {
                Layout.fillWidth: true
                spacing: _defaultTextHeight / 4

                ConfigButton {
                    id: button1
                    text: pageList[1].name
                    icon.source: pageList[1].icon
                    Layout.fillWidth: true
                    icon.color: "white"
                    textColor:  "white"
                    checked: currentPageIndex === 1
                    background: Rectangle {
                        color:      qgcPal.buttonHighlight
                        opacity:    parent.hovered ? .2 : 0
                        radius:     ScreenTools.defaultFontPixelWidth / 2
                    }
                    QGCColoredImage {
                        height: parent.height/3
                        width: height
                        fillMode: Image.PreserveAspectFit
                        // color: qgcPal.colorGreen
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        source: deviceConfigExpanded ? "qrc:/xfres/menuExpand.png" : "qrc:/xfres/menuCollapse.png"
                    }

                    onClicked: {
                        if (deviceConfigExpanded) {
                            deviceConfigExpanded = false;
                        } else {
                            deviceConfigExpanded = true;
                            deviceConfigSubIndex = 0;
                            var url = getUrlForPage(deviceConfigPages[0]);
                            if (url !== "") {
                                contentLoader.vehicleComponent = null;
                                contentLoader.source = "";
                                contentLoader.source = url;
                            }
                        }
                        currentPageIndex = 1;
                        updateButtonChecked();
                    }
                }


                //设备配置二级菜单
                ColumnLayout {
                    visible: deviceConfigExpanded
                    spacing: _defaultTextHeight / 8
                    Layout.fillWidth: true
                    Layout.leftMargin: _defaultTextWidth

                    Repeater {
                        model: deviceConfigPages

                        ConfigButton {
                            text: modelData.name
                            Layout.fillWidth: true
                            font.pointSize: ScreenTools.defaultFontPixelSize * 0.9
                            checked: deviceConfigSubIndex === index
                            visible: isPageVisible(modelData)

                            onClicked: {
                                currentPageIndex = 1;
                                deviceConfigSubIndex = index;
                                var url = getUrlForPage(modelData);
                                if (url !== "") {
                                    var comp = findVehicleComponent(modelData.componentName);
                                    contentLoader.vehicleComponent = comp || null;
                                    contentLoader.source = "";
                                    contentLoader.source = url;
                                }
                                updateButtonChecked();
                            }
                        }
                    }
                }
            }

            //页面2-7
            ConfigButton {
                id: button2
                text: pageList[2].name
                icon.source: pageList[2].icon
                Layout.fillWidth: true
                checked: currentPageIndex === 2
                onClicked: selectPage(2)
            }
            ConfigButton {
                id: button3
                text: pageList[3].name
                icon.source: pageList[3].icon
                Layout.fillWidth: true
                checked: currentPageIndex === 3
                onClicked: selectPage(3)
            }
            ConfigButton {
                id: button4
                text: pageList[4].name
                icon.source: pageList[4].icon
                Layout.fillWidth: true
                checked: currentPageIndex === 4
                onClicked: selectPage(4)
            }
            ConfigButton {
                id: button5
                text: pageList[5].name
                icon.source: pageList[5].icon
                Layout.fillWidth: true
                checked: currentPageIndex === 5
                onClicked: selectPage(5)
            }
            ConfigButton {
                id: button6
                text: pageList[6].name
                icon.source: pageList[6].icon
                Layout.fillWidth: true
                checked: currentPageIndex === 6
                onClicked: selectPage(6)
            }
            ConfigButton {
                id: button7
                text: pageList[7].name
                icon.source: pageList[7].icon
                Layout.fillWidth: true
                checked: currentPageIndex === 7
                onClicked: selectPage(7)
            }
        }
    }

    //分隔线
    Rectangle {
        id: divider
        anchors.topMargin: _verticalMargin
        anchors.bottomMargin: _verticalMargin
        anchors.leftMargin: _horizontalMargin
        anchors.left: buttonScroll.right
        anchors.top: toolbar.bottom
        anchors.bottom: parent.bottom
        width: 1
        color: qgcPal.windowShade
    }

    //右侧内容区域
    Loader {
        id: contentLoader
        anchors.topMargin: _verticalMargin
        anchors.bottomMargin: _verticalMargin
        anchors.leftMargin: _horizontalMargin
        anchors.rightMargin: _horizontalMargin
        anchors.left: divider.right
        anchors.right: parent.right
        anchors.top: toolbar.bottom
        anchors.bottom: parent.bottom
        source: pageList[currentPageIndex].url
        property var vehicleComponent
    }

    //监听飞控连接状态变化
    Connections {
        target: QGroundControl.multiVehicleManager
        onParameterReadyVehicleAvailableChanged: {
            //飞控连接变化时，刷新二级菜单
            if (currentPageIndex === 1 && deviceConfigExpanded) {
                var url = getUrlForPage(deviceConfigPages[deviceConfigSubIndex]);
                if (url !== "") {
                    contentLoader.vehicleComponent = null;
                    contentLoader.source = "";
                    contentLoader.source = url;
                }
            }
        }
    }
}
