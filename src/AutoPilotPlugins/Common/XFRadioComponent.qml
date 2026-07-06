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
import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Controllers
import QGroundControl.Palette

// 遥控器校准页面，用于校准遥控器通道映射和附加设置
SetupPage {
    id:             radioPage
    pageComponent:  pageComponent

    // 页面主内容组件
    Component {
        id: pageComponent

        // 页面根容器，左右两列布局
        Item {
            width:  availableWidth
            height: Math.max(leftColumn.height, rightColumn.height)

            // 页面加载完成后启动校准控制器并更新通道数
            function setupPageCompleted() {
                controller.start()
                updateChannelCount()
            }

            // 更新当前检测到的通道数量（预留，暂无实现）
            function updateChannelCount()
            {
            }

            // 全局调色板
            QGCPalette { id: qgcPal; colorGroupEnabled: radioPage.enabled }

            // 遥控器校准控制器，管理校准流程、通道映射和绑定操作
            RadioComponentController {
                id:             controller
                statusText:     statusText
                cancelButton:   cancelButton
                nextButton:     nextButton
                skipButton:     skipButton
                onChannelCountChanged:              updateChannelCount()
                onFunctionMappingChangedAPMReboot:  mainWindow.showMessageDialog(qsTr("Reboot required"), qsTr("Your stick mappings have changed, you must reboot the vehicle for correct operation."))
                onThrottleReversedCalFailure:       mainWindow.showMessageDialog(qsTr("Throttle channel reversed"), qsTr("Calibration failed. The throttle channel on your transmitter is reversed. You must correct this on your transmitter in order to complete calibration."))
            }

            // Spektrum接收机绑定对话框，选择绑定模式后让接收机进入配对状态
            Component {
                id: spektrumBindDialogComponent

                QGCPopupDialog {
                    title:      qsTr("Spektrum Bind")
                    buttons:    Dialog.Ok | Dialog.Cancel

                    onAccepted: { controller.spektrumBindMode(radioGroup.checkedButton.bindMode) }

                    ButtonGroup { id: radioGroup }

                    ColumnLayout {
                        spacing: ScreenTools.defaultFontPixelHeight / 2

                    // 提示用户点击确定以将Spektrum接收机置于绑定模式
                    QGCLabel {
                        wrapMode:   Text.WordWrap
                        text:       qsTr("Click Ok to place your Spektrum receiver in the bind mode.")
                    }

                    // 提示用户选择接收机类型
                    QGCLabel {
                            wrapMode:   Text.WordWrap
                            text:       qsTr("Select the specific receiver type below:")
                        }

                    // DSM2绑定模式选项
                    QGCRadioButton {
                        text:               qsTr("DSM2 Mode")
                        ButtonGroup.group:  radioGroup
                        property int bindMode: RadioComponentController.DSM2
                    }

                    // DSMX 7通道及以下绑定模式选项
                    QGCRadioButton {
                        text:               qsTr("DSMX (7 channels or less)")
                        ButtonGroup.group:  radioGroup
                        property int bindMode: RadioComponentController.DSMX7
                    }

                    // DSMX 8通道及以上绑定模式选项（默认选中）
                    QGCRadioButton {
                            checked:            true
                            text:               qsTr("DSMX (8 channels or more)")
                            ButtonGroup.group:  radioGroup
                            property int bindMode: RadioComponentController.DSMX8
                        }
                    }
                }
            }

            // 单通道监听条组件，可视化显示单个RC通道的实时PWM值
            Component {
                id: channelMonitorDisplayComponent

                Item {
                    property int    rcValue:    1500


                    property int            __lastRcValue:      1500
                    readonly property int   __rcValueMaxJitter: 2
                    property color          __barColor:         qgcPal.windowShade

                    readonly property int _pwmMin:      800
                    readonly property int _pwmMax:      2200
                    readonly property int _pwmRange:    _pwmMax - _pwmMin

                // 通道监听条背景，显示通道值的可视范围
                Rectangle {
                    id:                     bar
                    anchors.verticalCenter: parent.verticalCenter
                    width:                  parent.width
                    height:                 parent.height / 2
                    color:                  __barColor
                }

                // 中心线标记，表示通道中值位置
                Rectangle {
                        anchors.horizontalCenter:   parent.horizontalCenter
                        width:                      globals.defaultTextWidth / 2
                        height:                     parent.height
                        color:                      qgcPal.window
                    }

                // 通道值指示圆点，根据RC值在条上滑动显示当前位置
                Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width:                  parent.height * 0.75
                        height:                 width
                        radius:                 width / 2
                        color:                  qgcPal.text
                        visible:                mapped
                        x:                      (((reversed ? _pwmMax - rcValue : rcValue - _pwmMin) / _pwmRange) * parent.width) - (width / 2)
                    }

                    // 通道未映射时显示"Not Mapped"文字
                    QGCLabel {
                        anchors.fill:           parent
                        horizontalAlignment:    Text.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        text:                   qsTr("Not Mapped")
                        visible:                !mapped
                    }

                    // 通道值变化时的黄色闪烁动画
                    ColorAnimation {
                        id:         barAnimation
                        target:     bar
                        property:   "color"
                        from:       "yellow"
                        to:         __barColor
                        duration:   1500
                    }
                }
            } // Component - channelMonitorDisplayComponent

            // 左侧列：姿态控制通道监听、校准按钮和附加设置
            Column {
                id:             leftColumn
                anchors.left:   parent.left
                anchors.right:  columnSpacer.left
                spacing:        10

                // 姿态控制通道区域，显示Roll/Pitch/Yaw/Throttle四个通道的实时值
                Column {
                    width:      parent.width
                    spacing:    5
                    QGCLabel { text: qsTr("Attitude Controls") }

                    // Roll通道监听行，显示副翼通道的实时RC值
                    Item {
                        width:  parent.width
                        height: globals.defaultTextHeight * 2
                        QGCLabel {
                            id:     rollLabel
                            width:  globals.defaultTextWidth * 10
                            text:   qsTr("Roll")
                        }

                        // Roll通道监听条加载器
                        Loader {
                            id:                 rollLoader
                            anchors.left:       rollLabel.right
                            anchors.right:      parent.right
                            height:             globals.defaultTextHeight
                            width:              100
                            sourceComponent:    channelMonitorDisplayComponent

                            property bool mapped:           controller.rollChannelMapped
                            property bool reversed:         controller.rollChannelReversed
                        }

                        // 将Roll通道RC值变化实时传递给监听条
                        Connections {
                            target: controller

                            onRollChannelRCValueChanged: (rcValue) => rollLoader.item.rcValue = rcValue
                        }
                    }

                    // Pitch通道监听行，显示升降通道的实时RC值
                    Item {
                        width:  parent.width
                        height: globals.defaultTextHeight * 2

                        QGCLabel {
                            id:     pitchLabel
                            width:  globals.defaultTextWidth * 10
                            text:   qsTr("Pitch")
                        }

                        // Pitch通道监听条加载器
                        Loader {
                            id:                 pitchLoader
                            anchors.left:       pitchLabel.right
                            anchors.right:      parent.right
                            height:             globals.defaultTextHeight
                            width:              100
                            sourceComponent:    channelMonitorDisplayComponent

                            property bool mapped:           controller.pitchChannelMapped
                            property bool reversed:         controller.pitchChannelReversed
                        }

                        // 将Pitch通道RC值变化实时传递给监听条
                        Connections {
                            target: controller

                            onPitchChannelRCValueChanged: (rcValue) => pitchLoader.item.rcValue = rcValue
                        }
                    }

                    // Yaw通道监听行，显示偏航通道的实时RC值
                    Item {
                        width:  parent.width
                        height: globals.defaultTextHeight * 2

                        QGCLabel {
                            id:     yawLabel
                            width:  globals.defaultTextWidth * 10
                            text:   qsTr("Yaw")
                        }

                        // Yaw通道监听条加载器
                        Loader {
                            id:                 yawLoader
                            anchors.left:       yawLabel.right
                            anchors.right:      parent.right
                            height:             globals.defaultTextHeight
                            width:              100
                            sourceComponent:    channelMonitorDisplayComponent

                            property bool mapped:           controller.yawChannelMapped
                            property bool reversed:         controller.yawChannelReversed
                        }

                        // 将Yaw通道RC值变化实时传递给监听条
                        Connections {
                            target: controller

                            onYawChannelRCValueChanged: (rcValue) => yawLoader.item.rcValue = rcValue
                        }
                    }

                    // Throttle通道监听行，显示油门通道的实时RC值
                    Item {
                        width:  parent.width
                        height: globals.defaultTextHeight * 2

                        QGCLabel {
                            id:     throttleLabel
                            width:  globals.defaultTextWidth * 10
                            text:   qsTr("Throttle")
                        }

                        // Throttle通道监听条加载器
                        Loader {
                            id:                 throttleLoader
                            anchors.left:       throttleLabel.right
                            anchors.right:      parent.right
                            height:             globals.defaultTextHeight
                            width:              100
                            sourceComponent:    channelMonitorDisplayComponent

                            property bool mapped:           controller.throttleChannelMapped
                            property bool reversed:         controller.throttleChannelReversed
                        }

                        // 将Throttle通道RC值变化实时传递给监听条
                        Connections {
                            target:                             controller
                            onThrottleChannelRCValueChanged:    (rcValue) => throttleLoader.item.rcValue = rcValue
                        }
                    }
                } // Column - Attitude Control labels

                // 校准操作按钮行：跳过、取消、开始校准
                Row {
                    spacing: 10

                    // 跳过当前校准步骤
                    QGCButton {
                        id:         skipButton
                        text:       qsTr("Skip")
                        onClicked:  controller.skipButtonClicked()
                    }

                    // 取消正在进行的校准流程
                    QGCButton {
                        id:         cancelButton
                        text:       qsTr("Cancel")
                        onClicked:  controller.cancelButtonClicked()
                    }

                    // 开始或继续校准流程，点击时检查通道数并提示归零微调
                    QGCButton {
                        id:         nextButton
                        primary:    true
                        text:       qsTr("Calibrate")

                        onClicked: {
                            if (text === qsTr("Calibrate")) {
                                if (controller.channelCount < controller.minChannelCount) {
                                    mainWindow.showMessageDialog(qsTr("Radio Not Ready"),
                                                                 controller.channelCount == 0 ? qsTr("Please turn on transmitter.") :
                                                                                                (controller.channelCount < controller.minChannelCount ?
                                                                                                     qsTr("%1 channels or more are needed to fly.").arg(controller.minChannelCount) :
                                                                                                     qsTr("Ready to calibrate.")))
                                } else {
                                    mainWindow.showMessageDialog(qsTr("Zero Trims"),
                                                                 qsTr("Before calibrating you should zero all your trims and subtrims. Click Ok to start Calibration.\n\n%1").arg(
                                                                     (QGroundControl.multiVehicleManager.activeVehicle.px4Firmware ? "" : qsTr("Please ensure all motor power is disconnected AND all props are removed from the vehicle."))),
                                                                 Dialog.Ok,
                                                                 function() { controller.nextButtonClicked() })
                                }
                            } else {
                                controller.nextButtonClicked()
                            }
                        }
                    }
                } // Row - Buttons

                // 校准状态提示文字，显示当前校准步骤说明
                QGCLabel {
                    id:         statusText
                    width:      parent.width
                    wrapMode:   Text.WordWrap
                }

                // 分隔线
                Rectangle {
                    width:          parent.width
                    height:         1
                    border.color:   qgcPal.text
                    border.width:   1
                }

                // 附加遥控设置区域标题
                QGCLabel { text: qsTr("Additional Radio setup:") }

                // 附加通道映射设置列表，显示辅助通道和参数通道的映射下拉框
                ColumnLayout {
                    id:                 switchSettingsGrid
                    anchors.left:       parent.left
                    anchors.right:      parent.right

                    // 根据固件类型动态生成附加通道映射参数的标签下拉框
                    Repeater {
                        model: QGroundControl.multiVehicleManager.activeVehicle.px4Firmware ?
                                   (QGroundControl.multiVehicleManager.activeVehicle.multiRotor ?
                                        [ "RC_MAP_AUX1", "RC_MAP_AUX2", "RC_MAP_PARAM1", "RC_MAP_PARAM2", "RC_MAP_PARAM3"] :
                                        [ "RC_MAP_FLAPS", "RC_MAP_AUX1", "RC_MAP_AUX2", "RC_MAP_PARAM1", "RC_MAP_PARAM2", "RC_MAP_PARAM3"]) :
                                   0

                        LabelledFactComboBox {
                            label:               fact.shortDescription
                            fact:                controller.getParameterFact(-1, modelData)
                            indexModel:          false
                        }
                    }
                }

                // 接收机绑定和微调复制按钮行
                RowLayout {
                    // Spektrum接收机绑定按钮，打开绑定模式选择对话框
                    QGCButton {
                        id:         bindButton
                        text:       qsTr("Spektrum Bind")
                        onClicked:  spektrumBindDialogComponent.createObject(mainWindow).open()
                    }

                    // CRSF接收机绑定按钮，确认后让接收机进入配对模式
                    QGCButton {
                        text:       qsTr("CRSF Bind")
                        onClicked:  mainWindow.showMessageDialog(qsTr("CRSF Bind"),
                                                                 qsTr("Click Ok to place your CRSF receiver in the bind mode."),
                                                                 Dialog.Ok | Dialog.Cancel,
                                                                 function() { controller.crsfBindMode() })
                    }

                    // 复制微调值按钮，将遥控器当前微调值同步到飞控
                    QGCButton {
                        text:       qsTr("Copy Trims")
                        onClicked:  mainWindow.showMessageDialog(qsTr("Copy Trims"),
                                                                 qsTr("Center your sticks and move throttle all the way down, then press Ok to copy trims. After pressing Ok, reset the trims on your radio back to zero."),
                                                                 Dialog.Ok | Dialog.Cancel,
                                                                 function() { controller.copyTrims() })
                    }
                }
            } // Column - Left Column

            // 左右列之间的间距
            Item {
                id:             columnSpacer
                anchors.right:  rightColumn.left
                width:          20
            }

            // 右侧列：遥控器模式选择、校准示意图和全通道监视图
            Column {
                id:             rightColumn
                anchors.top:    parent.top
                anchors.right:  parent.right
                width:          ScreenTools.defaultFontPixelWidth * 40
                spacing:        ScreenTools.defaultFontPixelHeight / 2

                // 遥控器模式选择（Mode 1/Mode 2）
                Row {
                    spacing: ScreenTools.defaultFontPixelWidth

                    QGCRadioButton {
                        text:       qsTr("Mode 1")
                        checked:    controller.transmitterMode == 1
                        onClicked:  controller.transmitterMode = 1
                    }

                    QGCRadioButton {
                        text:       qsTr("Mode 2")
                        checked:    controller.transmitterMode == 2
                        onClicked:  controller.transmitterMode = 2
                    }
                }

                // 校准步骤示意图，根据当前校准阶段显示对应操作指引
                Image {
                    width:      parent.width
                    fillMode:   Image.PreserveAspectFit
                    smooth:     true
                    source:     controller.imageHelp
                }

                // 全通道RC监视图，以双列方式显示所有通道的实时值
                RCChannelMonitor {
                    width:      parent.width
                    twoColumn:  true
                }
            } // Column - Right Column
        } // Item
    } // Component - pageComponent
} // SetupPage
