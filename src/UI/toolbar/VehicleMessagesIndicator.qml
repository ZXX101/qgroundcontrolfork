/****************************************************************************
 *
 * Vehicle Messages Indicator for QGroundControl
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.MultiVehicleManager
import QGroundControl.ScreenTools
import QGroundControl.Palette
import QGroundControl.FactSystem

//车辆消息指示器，位于飞行模式指示器后面，显示车辆警告/错误消息
//图标颜色：默认白色、警告橙色、错误红色
//点击弹出完整状态面板：Arm/Disarm按钮、Vehicle Messages列表、Sensor Status、Overall Status
Item {
    id:                 control
    width:              messageIcon.width + ScreenTools.defaultFontPixelWidth

    readonly property real _iconSize: ScreenTools.defaultFontPixelHeight * 1.2

    property var    _activeVehicle:                 QGroundControl.multiVehicleManager.activeVehicle
    property bool   _connected:                     _activeVehicle && !_activeVehicle.vehicleLinkManager.communicationLost
    property bool   _armed:                         _activeVehicle ? _activeVehicle.armed : false
    property bool   _healthAndArmingChecksSupported: _activeVehicle ? _activeVehicle.healthAndArmingCheckReport.supported : false
    property real   _spacing:                       ScreenTools.defaultFontPixelWidth / 2

    //获取图标颜色，根据消息类型返回对应颜色
    function getIconColor() {
        if (_activeVehicle && _activeVehicle.messageTypeError) return qgcPal.colorRed
        if (_activeVehicle && _activeVehicle.messageTypeWarning) return qgcPal.colorOrange
        return "white"
    }

    QGCColoredImage {
        id:                 messageIcon
        height:             control._iconSize
        width:              height

        sourceSize.height:  height
        sourceSize.width:   width
        source:             "/xfres/message.png"
        fillMode:           Image.PreserveAspectFit
        color:              getIconColor()
        anchors.verticalCenter: parent.verticalCenter
        opacity:            1
    }

    QGCMouseArea {
        anchors.fill:   parent
        onClicked:      mainWindow.showIndicatorDrawer(overallStatusIndicatorPage, control)
    }

    // 警告日志弹窗（在线时弹出）
    Component {
        id: overallStatusIndicatorPage

        ToolIndicatorPage {
            showExpand:         _activeVehicle.mainStatusIndicatorContentItem ? true : false
            waitForParameters:  _activeVehicle.mainStatusIndicatorContentItem ? true : false
            contentComponent:   mainStatusContentComponent
            expandedComponent:  mainStatusExpandedComponent
        }
    }

    // 警告日志内容
    Component {
        id: mainStatusContentComponent

        ColumnLayout {
            id:         mainLayout
            spacing:    _spacing

            QGCButton {
                enabled:            _armed || !_healthAndArmingChecksSupported || _activeVehicle.healthAndArmingCheckReport.canArm
                text:               _armed ? qsTr("Disarm") : (forceArm ? qsTr("Force Arm") : qsTr("Arm"))
                Layout.alignment:   Qt.AlignLeft

                property bool forceArm: false

                onPressAndHold: forceArm = true

                onClicked: {
                    if (_armed) {
                        mainWindow.disarmVehicleRequest()
                    } else {
                        if (forceArm) {
                            mainWindow.forceArmVehicleRequest()
                        } else {
                            mainWindow.armVehicleRequest()
                        }
                    }
                    forceArm = false
                    mainWindow.closeIndicatorDrawer()
                }
            }

            SettingsGroupLayout {
                heading:            qsTr("Vehicle Messages")
                visible:            !vehicleMessageList.noMessages

                VehicleMessageList {
                    id: vehicleMessageList
                }
            }

            SettingsGroupLayout {
                heading:            qsTr("Sensor Status")
                visible:            !_healthAndArmingChecksSupported

                GridLayout {
                    rowSpacing:     _spacing
                    columnSpacing:  _spacing
                    rows:           _activeVehicle.sysStatusSensorInfo.sensorNames.length
                    flow:           GridLayout.TopToBottom

                    Repeater {
                        model: _activeVehicle.sysStatusSensorInfo.sensorNames
                        QGCLabel { text: modelData }
                    }

                    Repeater {
                        model: _activeVehicle.sysStatusSensorInfo.sensorStatus
                        QGCLabel { text: modelData }
                    }
                }
            }

            SettingsGroupLayout {
                heading:            qsTr("Overall Status")
                visible:            _healthAndArmingChecksSupported && _activeVehicle.healthAndArmingCheckReport.problemsForCurrentMode.count > 0

                Repeater {
                    model:      _activeVehicle ? _activeVehicle.healthAndArmingCheckReport.problemsForCurrentMode : null
                    delegate:   listdelegate
                }
            }

            FactPanelController {
                id: controller
            }

            Component {
                id: listdelegate

                Column {
                    Row {
                        spacing: ScreenTools.defaultFontPixelHeight

                        QGCLabel {
                            id:           message
                            text:         object.message
                            textFormat:   TextEdit.RichText
                            color:        object.severity == 'error' ? qgcPal.colorRed : object.severity == 'warning' ? qgcPal.colorOrange : qgcPal.text
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (object.description != "")
                                        object.expanded = !object.expanded
                                }
                            }
                        }

                        QGCColoredImage {
                            id:                     arrowDownIndicator
                            anchors.verticalCenter: parent.verticalCenter
                            height:                 1.5 * ScreenTools.defaultFontPixelWidth
                            width:                  height
                            source:                 "/qmlimages/arrow-down.png"
                            color:                  qgcPal.text
                            visible:                object.description != ""
                            MouseArea {
                                anchors.fill:       parent
                                onClicked:          object.expanded = !object.expanded
                            }
                        }
                    }

                    QGCLabel {
                        id:                 description
                        text:               object.description
                        textFormat:         TextEdit.RichText
                        clip:               true
                        visible:            object.expanded

                        property var fact:  null

                        onLinkActivated: (link) => {
                            if (link.startsWith('param://')) {
                                var paramName = link.substr(8);
                                fact = controller.getParameterFact(-1, paramName, true)
                                if (fact != null) {
                                    paramEditorDialogComponent.createObject(mainWindow).open()
                                }
                            } else {
                                Qt.openUrlExternally(link);
                            }
                        }

                        Component {
                            id: paramEditorDialogComponent

                            ParameterEditorDialog {
                                title:          qsTr("Edit Parameter")
                                fact:           description.fact
                                destroyOnClose: true
                            }
                        }
                    }
                }
            }
        }
    }

    // 警告日志拓展弹窗
    Component {
        id: mainStatusExpandedComponent

        ColumnLayout {
            Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 60
            spacing:                margins / 2

            property real margins: ScreenTools.defaultFontPixelHeight

            Loader {
                source: _activeVehicle.mainStatusIndicatorContentItem
            }

            SettingsGroupLayout {
                Layout.fillWidth:   true
                visible:            QGroundControl.corePlugin.showAdvancedUI

                GridLayout {
                    columns:            2
                    rowSpacing:         ScreenTools.defaultFontPixelHeight / 2
                    columnSpacing:      ScreenTools.defaultFontPixelWidth * 2
                    Layout.fillWidth:   true

                    QGCLabel { Layout.fillWidth: true; text: qsTr("Vehicle Parameters") }
                    QGCButton {
                        text: qsTr("Configure")
                        onClicked: {
                            mainWindow.showVehicleConfigParametersPage()
                            mainWindow.closeIndicatorDrawer()
                        }
                    }

                    QGCLabel { Layout.fillWidth: true; text: qsTr("Vehicle Configuration") }
                    QGCButton {
                        text: qsTr("Configure")
                        onClicked: {
                            mainWindow.showVehicleConfig()
                            mainWindow.closeIndicatorDrawer()
                        }
                    }
                }
            }
        }
    }
}
