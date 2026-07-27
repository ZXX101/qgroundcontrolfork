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
    property int currentPageIndex: 0

    //页面列表数据
    property var pageList: [
        {
            name: qsTr("Connection"),
            url: "qrc:/qml/QGroundControl/AppSettings/XFLinkSettings.qml",
            icon: "qrc:/xfressvg/link.svg"
        },
        {
            name: qsTr("Device Config"),
            icon: "qrc:/xfressvg/deviceConfig.svg"
        },
        {
            name: qsTr("Flight Params"),
            componentName: "flyparam",
            icon: "qrc:/xfressvg/flightParams.svg"
        },
        {
            name: qsTr("Safety"),
            componentName: "safety",
            icon: "qrc:/xfressvg/safety.svg"
        },
        {
            name: qsTr("Device Log"),
            url: "qrc:/qml/QGroundControl/AnalyzeView/XFLogDownloadPage.qml",
            icon: "qrc:/xfressvg/deviceLog.svg"
        },
        {
            name: qsTr("Mavlink Console"),
            url: "qrc:/qml/QGroundControl/AnalyzeView/XFMAVLinkConsolePage.qml",
            icon: "qrc:/xfressvg/mavlink.svg"
        },
        {
            name: qsTr("Mavlink Analyze"),
            url: "qrc:/qml/QGroundControl/AnalyzeView/XFMAVLinkInspectorPage.qml",
            icon: "qrc:/xfressvg/mavlinkInspect.svg"
        },
        {
            name: qsTr("Software Settings"),
            url: "qrc:/qml/QGroundControl/AppSettings/XFGeneralSettings.qml",
            icon: "qrc:/xfressvg/softwareSettings.svg"
        }
    ]

    //设备配置二级菜单是否展开
    property bool deviceConfigExpanded: true

    //设备配置二级菜单中选中的索引：-1=概况, 0..n=vehicleComponents中第n项, -2=参数
    property int deviceConfigSubIndex: -1

    //飞控相关属性
    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property bool _fullParameterVehicleAvailable: QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable && (!_activeVehicle || !_activeVehicle.parameterManager.missingParameters)
    property var _vehicleComponents: _fullParameterVehicleAvailable && _activeVehicle ? _activeVehicle.autopilotPlugin.vehicleComponents : []

    // 从 setupSource URL 提取组件标识
    function getComponentIdFromUrl(url) {
        var urlStr = url.toString().toLowerCase()
        if (urlStr.indexOf("airframe") >= 0) return "airframe"
        if (urlStr.indexOf("sensors") >= 0) return "sensors"
        if (urlStr.indexOf("flightmodes") >= 0) return "flightModes"
        if (urlStr.indexOf("power") >= 0) return "power"
        if (urlStr.indexOf("actuator") >= 0 || urlStr.indexOf("motor") >= 0) return "motors"
        if (urlStr.indexOf("radio") >= 0) return "radio"
        if (urlStr.indexOf("tuning") >= 0) return "tuning"
        if (urlStr.indexOf("camera") >= 0) return "camera"
        if (urlStr.indexOf("esp8266") >= 0 || urlStr.indexOf("remote") >= 0) return "esp8266"
        if (urlStr.indexOf("safety") >= 0) return "safety"
        if (urlStr.indexOf("syslink") >= 0) return "syslink"
        if (urlStr.indexOf("flightbehavior") >= 0) return "flightBehavior"
        if (urlStr.indexOf("follow") >= 0) return "follow"
        if (urlStr.indexOf("heli") >= 0) return "heli"
        if (urlStr.indexOf("lights") >= 0) return "lights"
        if (urlStr.indexOf("subframe") >= 0 || urlStr.indexOf("sub frame") >= 0) return "subFrame"
        return ""
    }

    function getTranslatedComponentName(component) {
        if (!component) {
            return ""
        }

        switch (getComponentIdFromUrl(component.setupSource)) {
        case "airframe":
            return qsTr("Airframe")
        case "sensors":
            return qsTr("Sensors")
        case "flightModes":
            return qsTr("Flight Modes")
        case "power":
            return qsTr("Power")
        case "motors":
            return qsTr("Motors")
        case "radio":
            return qsTr("Radio")
        case "tuning":
            return qsTr("Tuning")
        default:
            return component.name || ""
        }
    }

    // 过滤并排序后的组件列表（排除Safety/FlightBehavior/ESP8266/Camera等，按指定顺序排列）
    property var _fallbackComponents: [
        { name: "Airframe", setupSource: "qrc:/qml/QGroundControl/AutoPilotPlugins/APM/AirframeComponent.qml" },
        { name: "Sensors", setupSource: "qrc:/qml/QGroundControl/AutoPilotPlugins/APM/SensorsComponent.qml" },
        { name: "Flight Modes", setupSource: "qrc:/qml/QGroundControl/AutoPilotPlugins/APM/FlightModesComponent.qml" },
        { name: "Power", setupSource: "qrc:/qml/QGroundControl/AutoPilotPlugins/APM/PowerComponent.qml" },
        { name: "Motors", setupSource: "qrc:/qml/QGroundControl/AutoPilotPlugins/APM/MotorComponent.qml" },
        { name: "Radio", setupSource: "qrc:/qml/QGroundControl/AutoPilotPlugins/Common/RadioComponent.qml" },
        { name: "Tuning", setupSource: "qrc:/qml/QGroundControl/AutoPilotPlugins/APM/TuningComponentCopter.qml" }
    ]

    property var _vehicleComponentsList: _fullParameterVehicleAvailable && _activeVehicle ? _activeVehicle.autopilotPlugin.vehicleComponents : []
    property var _filteredComponents: {
        var refresh = _filterRefreshCounter
        var all = _vehicleComponentsList
        var order = ["airframe", "sensors", "flightModes", "power", "motors", "radio", "tuning"]
        var exclude = ["safety", "camera", "esp8266", "syslink", "flightBehavior", "follow", "heli", "lights", "subFrame"]

        var filtered = []
        for (var i = 0; i < all.length; i++) {
            var url = all[i].setupSource.toString()
            var id = getComponentIdFromUrl(url)
            if (!id || exclude.indexOf(id) >= 0) continue
            var idx = order.indexOf(id)
            filtered.push({component: all[i], order: idx >= 0 ? idx : 999})
        }
        filtered.sort(function(a, b) { return a.order - b.order })
        var result = filtered.map(function(item) { return item.component })
        return result.length > 0 ? result : _fallbackComponents
    }

    // 刷新过滤后的组件列表
    property int _filterRefreshCounter: 0
    function _refreshFilteredComponents() {
        _filterRefreshCounter++
    }

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
            if (componentName === "safety" && name === "safety") return comp
            if (componentName === "flyparam" && name === "flight behavior") return comp
            if (componentName === "radio" && name === "radio") return comp
        }
        return null
    }

    //获取一级菜单某项的QML加载URL（safety/flyparam直接返回XF定制版）
    function getUrlForPage(page) {
        if (page.url && page.url !== "") return page.url
        if (page.componentName) {
            if (page.componentName === "safety") {
                if (_activeVehicle && _activeVehicle.apmFirmware) {
                    return "qrc:/qml/QGroundControl/AutoPilotPlugins/APM/XFAPMSafetyComponent.qml"
                } else if (_activeVehicle) {
                    return "qrc:/qml/QGroundControl/AutoPilotPlugins/PX4/XFSafetyComponent.qml"
                } else {
                    return "qrc:/qml/QGroundControl/AutoPilotPlugins/APM/XFAPMSafetyComponent.qml"
                }
            } else if (page.componentName === "flyparam") {
                if (_activeVehicle && _activeVehicle.apmFirmware) {
                    return "qrc:/qml/QGroundControl/AutoPilotPlugins/APM/XFAPMFlyParamComponent.qml"
                } else if (_activeVehicle) {
                    return "qrc:/qml/QGroundControl/AutoPilotPlugins/PX4/XFFlyParamComponent.qml"
                } else {
                    return "qrc:/qml/QGroundControl/AutoPilotPlugins/APM/XFAPMFlyParamComponent.qml"
                }
            }
        }
        return ""
    }

    //根据vehicleComponent获取XF定制版URL
    function getUrlForVehicleComponent(vehicleComponent) {
        if (!vehicleComponent || !vehicleComponent.setupSource) return ""
        var url = vehicleComponent.setupSource.toString().toLowerCase()
        if (url === "") return ""

        // 通过 URL 路径匹配，不管 name 是什么语言
        if (url.indexOf("airframe") !== -1) {
            if (url.indexOf("px4") !== -1) {
                return "qrc:/qml/QGroundControl/AutoPilotPlugins/PX4/XFAirframeComponent.qml"
            } else if (url.indexOf("apm") !== -1) {
                return "qrc:/qml/QGroundControl/AutoPilotPlugins/APM/XFAPMAirframeComponent.qml"
            }
        } else if (url.indexOf("sensor") !== -1) {
            if (url.indexOf("px4") !== -1) {
                return "qrc:/qml/QGroundControl/AutoPilotPlugins/PX4/XFSensorsComponent.qml"
            } else if (url.indexOf("apm") !== -1) {
                return "qrc:/qml/QGroundControl/AutoPilotPlugins/APM/XFAPMSensorsComponent.qml"
            }
        } else if (url.indexOf("flightmode") !== -1) {
            if (url.indexOf("px4") !== -1) {
                return "qrc:/qml/QGroundControl/AutoPilotPlugins/PX4/XFPX4FlightModes.qml"
            } else if (url.indexOf("apm") !== -1) {
                return "qrc:/qml/QGroundControl/AutoPilotPlugins/APM/XFAPMFlightModesComponent.qml"
            }
        } else if (url.indexOf("power") !== -1) {
            if (url.indexOf("px4") !== -1) {
                return "qrc:/qml/QGroundControl/AutoPilotPlugins/PX4/XFPowerComponent.qml"
            } else if (url.indexOf("apm") !== -1) {
                return "qrc:/qml/QGroundControl/AutoPilotPlugins/APM/XFAPMPowerComponent.qml"
            }
        } else if (url.indexOf("actuator") !== -1 || url.indexOf("motor") !== -1) {
            if (url.indexOf("px4") !== -1) {
                return "qrc:/qml/QGroundControl/AutoPilotPlugins/PX4/XFActuatorComponent.qml"
            } else if (url.indexOf("apm") !== -1) {
                return "qrc:/qml/QGroundControl/AutoPilotPlugins/APM/XFAPMMotorComponent.qml"
            }
        } else if (url.indexOf("tuning") !== -1) {
            if (url.indexOf("px4") !== -1) {
                return "qrc:/qml/QGroundControl/AutoPilotPlugins/PX4/XFPX4TuningComponent.qml"
            } else if (url.indexOf("apm") !== -1) {
                return "qrc:/qml/QGroundControl/AutoPilotPlugins/APM/XFAPMTuningComponentCopter.qml"
            }
        } else if (url.indexOf("radio") !== -1) {
            return "qrc:/qml/QGroundControl/AutoPilotPlugins/Common/XFRadioComponent.qml"
        }
        return url
    }

    //检查某菜单项是否可见
    function isPageVisible(page) {
        if (page.url && page.url !== "") return true
        if (page.componentName) {
            return true
        }
        return true
    }

    //显示设备配置二级菜单的概况页
    function _showDeviceConfigSummary() {
        deviceConfigSubIndex = -1
        if (_fullParameterVehicleAvailable) {
            contentLoader.vehicleComponent = null
            contentLoader.source = "qrc:/qml/QGroundControl/VehicleSetup/XFVehicleSummary.qml"
        } else if (QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable) {
            contentLoader.vehicleComponent = null
            contentLoader.source = "qrc:/qml/QGroundControl/VehicleSetup/VehicleSummary.qml"
        } else {
            contentLoader.vehicleComponent = null
            contentLoader.sourceComponent = disconnectedSummaryComponent
        }
        updateButtonChecked()
    }

    Component {
        id: disconnectedSummaryComponent
        Rectangle {
            color: qgcPal.windowShade
            QGCLabel {
                anchors.margins: _defaultTextWidth * 2
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font.pointSize: ScreenTools.largeFontPointSize
                text: qsTr("Vehicle settings and info will display after connecting your vehicle.")
            }
        }
    }

    //选择页面的函数
    function selectPage(index) {
        if (mainWindow.allowViewSwitch()) {
            currentPageIndex = index;
            deviceConfigExpanded = false;
            var url = getUrlForPage(pageList[index]);
            if (url !== "") {
                var comp = findVehicleComponent(pageList[index].componentName);
                contentLoader.vehicleComponent = comp || null;
                contentLoader.source = "";
                contentLoader.source = url;
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
        buttonSummary.checked = (currentPageIndex === 1 && deviceConfigSubIndex === -1);
        buttonParams.checked = (currentPageIndex === 1 && deviceConfigSubIndex === -2);
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
        color: "#101010"

        RowLayout {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: _defaultTextWidth

            QGCToolBarButton {
                z:                      1
                Layout.preferredHeight: toolbar.height
                icon.source:            "/xfres/LogoFull.png"
                logo:                   true
                onClicked:              mainWindow.showToolSelectDialog()
            }

            QGCLabel {
                text: qsTr("XF Ground Station - Common Config")
                font.pointSize: ScreenTools.largeFontPointSize
                font.family: ScreenTools.tecentFontFamily
            }
            QGCButton {
                id: buttonBack
                text: qsTr("Back")
                iconSource: "qrc:/xfressvg/back.svg"
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
                        source: deviceConfigExpanded ? "qrc:/xfressvg/menuExpand.svg" : "qrc:/xfressvg/menuCollapse.svg"
                    }

                    onClicked: {
                        if (deviceConfigExpanded) {
                            deviceConfigExpanded = false;
                        } else {
                            deviceConfigExpanded = true;
                            _showDeviceConfigSummary();
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

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: false
                        height: subMenuColumn.height
                        color: "#000000"

                        ColumnLayout {
                            id: subMenuColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: _defaultTextHeight / 8

                            ConfigButton {
                                id: buttonSummary
                                text: qsTr("Summary")
                                Layout.fillWidth: true
                                font.pointSize: ScreenTools.defaultFontPixelSize * 0.9
                                checked: deviceConfigSubIndex === -1
                                background: Rectangle {
                                    color:      qgcPal.buttonHighlight
                                    opacity:    buttonSummary.checked || buttonSummary.pressed ? 1 : buttonSummary.enabled && buttonSummary.hovered ? .5 : 0
                                    radius:     ScreenTools.defaultFontPixelWidth / 2
                                }
                                onClicked: {
                                    currentPageIndex = 1;
                                    _showDeviceConfigSummary();
                                }
                            }

                            Repeater {
                                id: vehicleComponentsRepeater
                                model: _filteredComponents

                                ConfigButton {
                                    id: subMenuCompButton
                                    text: getTranslatedComponentName(modelData)
                                    Layout.fillWidth: true
                                    font.pointSize: ScreenTools.defaultFontPixelSize * 0.9
                                    checked: deviceConfigSubIndex === index
                                    visible: modelData.setupSource.toString() !== ""
                                    background: Rectangle {
                                        color:      qgcPal.buttonHighlight
                                        opacity:    subMenuCompButton.checked || subMenuCompButton.pressed ? 1 : subMenuCompButton.enabled && subMenuCompButton.hovered ? .5 : 0
                                        radius:     ScreenTools.defaultFontPixelWidth / 2
                                    }

                                    onClicked: {
                                        currentPageIndex = 1;
                                        deviceConfigSubIndex = index;
                                        var url = getUrlForVehicleComponent(modelData);
                                        if (url !== "") {
                                            contentLoader.vehicleComponent = modelData;
                                            contentLoader.source = "";
                                            contentLoader.source = url;
                                        }
                                        updateButtonChecked();
                                    }
                                }
                            }

                            ConfigButton {
                                id: buttonParams
                                text: qsTr("Parameters")
                                Layout.fillWidth: true
                                font.pointSize: ScreenTools.defaultFontPixelSize * 0.9
                                checked: deviceConfigSubIndex === -2
                                visible: true
                                background: Rectangle {
                                    color:      qgcPal.buttonHighlight
                                    opacity:    buttonParams.checked || buttonParams.pressed ? 1 : buttonParams.enabled && buttonParams.hovered ? .5 : 0
                                    radius:     ScreenTools.defaultFontPixelWidth / 2
                                }
                                onClicked: {
                                    currentPageIndex = 1;
                                    deviceConfigSubIndex = -2;
                                    contentLoader.vehicleComponent = null;
                                    contentLoader.source = "qrc:/qml/QGroundControl/VehicleSetup/XFSetupParameterEditor.qml";
                                    updateButtonChecked();
                                }
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
                visible: isPageVisible(pageList[2])
                onClicked: selectPage(2)
            }
            ConfigButton {
                id: button3
                text: pageList[3].name
                icon.source: pageList[3].icon
                Layout.fillWidth: true
                checked: currentPageIndex === 3
                visible: isPageVisible(pageList[3])
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
        anchors.left: buttonScroll.right
        anchors.top: toolbar.bottom
        anchors.bottom: parent.bottom
        width: 1
        color: qgcPal.windowShade
    }

    //右侧内容区域
    Loader {
        id: contentLoader
        anchors.left: divider.right
        anchors.right: parent.right
        anchors.top: toolbar.bottom
        anchors.bottom: parent.bottom
        source: currentPageIndex === 1 ? "" : pageList[currentPageIndex].url
        property var vehicleComponent

        onSourceChanged: {
            if (currentPageIndex === 1 && source === "") {
            }
        }
    }

    //监听飞控连接状态变化
    Connections {
        target: QGroundControl.multiVehicleManager
        onParameterReadyVehicleAvailableChanged: {

            // 强制刷新 _filteredComponents
            _refreshFilteredComponents()

            if (!_fullParameterVehicleAvailable) {
                if (currentPageIndex === 1) {
                    _showDeviceConfigSummary()
                } else if (currentPageIndex === 2 || currentPageIndex === 3) {
                    currentPageIndex = 1
                    deviceConfigExpanded = true
                    _showDeviceConfigSummary()
                }
            } else {
                var url = getUrlForPage(pageList[currentPageIndex])
                if (url !== "") {
                    var comp = findVehicleComponent(pageList[currentPageIndex].componentName)
                    contentLoader.vehicleComponent = comp || null
                    contentLoader.source = ""
                    contentLoader.source = url
                }
            }
            updateButtonChecked()
        }
    }


}
