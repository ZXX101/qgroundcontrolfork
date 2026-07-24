/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
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

SetupPage {
    id:             radioPage
    pageComponent:  pageComponent
    pageName:       ""
    pageDescription: ""

    Component {
        id: pageComponent

        Item {
            width:  availableWidth
            height: Math.max(leftColumn.height, rightColumn.height)

            function setupPageCompleted() {
                controller.start()
            }

            QGCPalette { id: qgcPal; colorGroupEnabled: radioPage.enabled }

            XFRadioComponentController {
                id:             controller
                onFunctionMappingChangedAPMReboot:  mainWindow.showMessageDialog(qsTr("Reboot required"), qsTr("Your stick mappings have changed, you must reboot the vehicle for correct operation."))
                onThrottleReversedCalFailure:       mainWindow.showMessageDialog(qsTr("Throttle channel reversed"), qsTr("Calibration failed. The throttle channel on your transmitter is reversed. You must correct this on your transmitter in order to complete calibration."))
            }

            Component {
                id: calibrationResultsDialogComponent

                QGCPopupDialog {
                    title:      qsTr("Radio Calibration Results")
                    buttons:    Dialog.Ok

                    ColumnLayout {
                        id: resultsLayout

                        width:  52 * ScreenTools.defaultFontPixelWidth
                        spacing: ScreenTools.defaultFontPixelHeight / 2

                        readonly property real valueColumnWidth:  6 * ScreenTools.defaultFontPixelWidth
                        readonly property real statusColumnWidth: 14 * ScreenTools.defaultFontPixelWidth

                        QGCLabel {
                            Layout.fillWidth: true
                            wrapMode:         Text.WordWrap
                            text:              qsTr("Calibration complete. The following values were detected:")
                        }

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Math.min((controller.channelCount + 1) * ScreenTools.defaultFontPixelHeight * 1.5,
                                                             60 * ScreenTools.defaultFontPixelHeight)
                            clip: true

                            ColumnLayout {
                                width: parent.width

                                RowLayout {
                                    Layout.fillWidth: true

                                    QGCLabel { Layout.fillWidth: true; text: qsTr("Channel") }
                                    QGCLabel {
                                        Layout.preferredWidth: resultsLayout.valueColumnWidth
                                        horizontalAlignment:   Text.AlignRight
                                        text:                  qsTr("Min")
                                    }
                                    QGCLabel {
                                        Layout.preferredWidth: resultsLayout.valueColumnWidth
                                        horizontalAlignment:   Text.AlignRight
                                        text:                  qsTr("Max")
                                    }
                                    QGCLabel {
                                        Layout.preferredWidth: resultsLayout.statusColumnWidth
                                        horizontalAlignment:   Text.AlignHCenter
                                        text:                  qsTr("Status")
                                    }
                                }

                                Repeater {
                                    model: controller.channelCount

                                    RowLayout {
                                        Layout.fillWidth: true

                                        property var channelData: controller.channelMinMax[index]

                                        QGCLabel {
                                            Layout.fillWidth: true
                                            text: qsTr("Channel %1").arg(index + 1)
                                        }

                                        QGCLabel {
                                            Layout.preferredWidth: resultsLayout.valueColumnWidth
                                            horizontalAlignment:   Text.AlignRight
                                            text: channelData && channelData.hasSample ? channelData.min : qsTr("--")
                                        }

                                        QGCLabel {
                                            Layout.preferredWidth: resultsLayout.valueColumnWidth
                                            horizontalAlignment:   Text.AlignRight
                                            text: channelData && channelData.hasSample ? channelData.max : qsTr("--")
                                        }

                                        QGCLabel {
                                            Layout.preferredWidth: resultsLayout.statusColumnWidth
                                            horizontalAlignment:   Text.AlignHCenter
                                            text: !channelData || !channelData.hasSample ? qsTr("No data") :
                                                  (channelData.rangeValid ? qsTr("OK") : qsTr("Range too small"))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

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

                    Rectangle {
                        id:                     bar
                        anchors.verticalCenter: parent.verticalCenter
                        width:                  parent.width
                        height:                 parent.height / 2
                        color:                  __barColor
                    }

                        Rectangle {
                            anchors.horizontalCenter:   parent.horizontalCenter
                            width:                      globals.defaultTextWidth / 2
                            height:                     parent.height
                            color:                      qgcPal.window
                        }

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width:                  2
                            height:                 parent.height
                            x:                      (((reversed ? _pwmMax - calibrationMin : calibrationMin - _pwmMin) / _pwmRange) * parent.width) - (width / 2)
                            color:                  "red"
                            visible:                showCalibrationMinMax && calibrationMin >= _pwmMin && calibrationMin <= _pwmMax
                        }

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width:                  2
                            height:                 parent.height
                            x:                      (((reversed ? _pwmMax - calibrationMax : calibrationMax - _pwmMin) / _pwmRange) * parent.width) - (width / 2)
                            color:                  "red"
                            visible:                showCalibrationMinMax && calibrationMax >= _pwmMin && calibrationMax <= _pwmMax
                        }

                    Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width:                  parent.height * 0.75
                            height:                 width
                            radius:                 width / 2
                            color:                  qgcPal.text
                            visible:                mapped
                            x:                      (((reversed ? _pwmMax - rcValue : rcValue - _pwmMin) / _pwmRange) * parent.width) - (width / 2)
                        }

                        QGCLabel {
                            anchors.fill:           parent
                            horizontalAlignment:    Text.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            text:                   qsTr("Not Mapped")
                            visible:                !mapped
                        }

                        ColorAnimation {
                            id:         barAnimation
                            target:     bar
                            property:   "color"
                            from:       "yellow"
                            to:         __barColor
                            duration:   1500
                        }
                    }
            }

            Column {
                id:             leftColumn
                anchors.left:   parent.left
                anchors.right:  columnSpacer.left
                spacing:        10

                Column {
                    width:      parent.width
                    spacing:    5
                    QGCLabel { text: qsTr("Attitude Controls") }

                    Item {
                        width:  parent.width
                        height: globals.defaultTextHeight * 2
                        QGCLabel {
                            id:     rollLabel
                            width:  globals.defaultTextWidth * 10
                            text:   qsTr("Roll")
                        }

                        Loader {
                            id:                 rollLoader
                            anchors.left:       rollLabel.right
                            anchors.right:      parent.right
                            height:             globals.defaultTextHeight
                            width:              100
                            sourceComponent:    channelMonitorDisplayComponent

                            property bool mapped:           controller.rollChannelMapped
                            property bool reversed:         controller.rollChannelReversed
                            property bool showCalibrationMinMax: controller.calibrating
                            property int calibrationMin: controller.rollChannelMin
                            property int calibrationMax: controller.rollChannelMax
                        }

                        Connections {
                            target: controller
                            onRollChannelRCValueChanged: (rcValue) => rollLoader.item.rcValue = rcValue
                        }
                    }

                    Item {
                        width:  parent.width
                        height: globals.defaultTextHeight * 2

                        QGCLabel {
                            id:     pitchLabel
                            width:  globals.defaultTextWidth * 10
                            text:   qsTr("Pitch")
                        }

                        Loader {
                            id:                 pitchLoader
                            anchors.left:       pitchLabel.right
                            anchors.right:      parent.right
                            height:             globals.defaultTextHeight
                            width:              100
                            sourceComponent:    channelMonitorDisplayComponent

                            property bool mapped:           controller.pitchChannelMapped
                            property bool reversed:         controller.pitchChannelReversed
                            property bool showCalibrationMinMax: controller.calibrating
                            property int calibrationMin: controller.pitchChannelMin
                            property int calibrationMax: controller.pitchChannelMax
                        }

                        Connections {
                            target: controller
                            onPitchChannelRCValueChanged: (rcValue) => pitchLoader.item.rcValue = rcValue
                        }
                    }

                    Item {
                        width:  parent.width
                        height: globals.defaultTextHeight * 2

                        QGCLabel {
                            id:     yawLabel
                            width:  globals.defaultTextWidth * 10
                            text:   qsTr("Yaw")
                        }

                        Loader {
                            id:                 yawLoader
                            anchors.left:       yawLabel.right
                            anchors.right:      parent.right
                            height:             globals.defaultTextHeight
                            width:              100
                            sourceComponent:    channelMonitorDisplayComponent

                            property bool mapped:           controller.yawChannelMapped
                            property bool reversed:         controller.yawChannelReversed
                            property bool showCalibrationMinMax: controller.calibrating
                            property int calibrationMin: controller.yawChannelMin
                            property int calibrationMax: controller.yawChannelMax
                        }

                        Connections {
                            target: controller
                            onYawChannelRCValueChanged: (rcValue) => yawLoader.item.rcValue = rcValue
                        }
                    }

                    Item {
                        width:  parent.width
                        height: globals.defaultTextHeight * 2

                        QGCLabel {
                            id:     throttleLabel
                            width:  globals.defaultTextWidth * 10
                            text:   qsTr("Throttle")
                        }

                        Loader {
                            id:                 throttleLoader
                            anchors.left:       throttleLabel.right
                            anchors.right:      parent.right
                            height:             globals.defaultTextHeight
                            width:              100
                            sourceComponent:    channelMonitorDisplayComponent

                            property bool mapped:           controller.throttleChannelMapped
                            property bool reversed:         controller.throttleChannelReversed
                            property bool showCalibrationMinMax: controller.calibrating
                            property int calibrationMin: controller.throttleChannelMin
                            property int calibrationMax: controller.throttleChannelMax
                        }

                        Connections {
                            target:                             controller
                            onThrottleChannelRCValueChanged:    (rcValue) => throttleLoader.item.rcValue = rcValue
                        }
                    }
                }

                Row {
                    spacing: 10

                    QGCButton {
                        text:       qsTr("Cancel")
                        visible:    controller.calibrating || controller.calibrationDone
                        onClicked:  controller.cancelButtonClicked()
                    }

                    QGCButton {
                        primary:    true
                        text:       controller.calibrating ? qsTr("Click when Done") :
                                   (controller.calibrationDone ? qsTr("Confirm & Save") : qsTr("Calibrate"))
                        visible:    !controller.calibrationDone || controller.calibrating

                        onClicked: {
                            if (controller.calibrating) {
                                mainWindow.showMessageDialog(qsTr("Center Sticks"),
                                                             qsTr("Ensure all sticks are centered and throttle is down, then click OK to finish calibration."),
                                                             Dialog.Ok,
                                                             function() {
                                                                 controller.stopCalibration()
                                                                 calibrationResultsDialogComponent.createObject(mainWindow).open()
                                                             })
                            } else if (controller.calibrationDone) {
                                controller.confirmCalibration()
                            } else {
                                if (controller.channelCount < controller.minChannelCount) {
                                    mainWindow.showMessageDialog(qsTr("Radio Not Ready"),
                                                                 controller.channelCount === 0 ? qsTr("Please turn on transmitter.") :
                                                                                                (controller.channelCount < controller.minChannelCount ?
                                                                                                     qsTr("%1 channels or more are needed to fly.").arg(controller.minChannelCount) :
                                                                                                     qsTr("Ready to calibrate.")))
                                } else {
                                    mainWindow.showMessageDialog(qsTr("Calibrate Radio"),
                                                                 qsTr("Ensure your transmitter is on and receiver is powered.\nEnsure all motor power is disconnected AND all props are removed!\n\nClick OK and then move all RC sticks and switches to their extreme positions."),
                                                                 Dialog.Ok,
                                                                 function() { controller.startCalibration() })
                                }
                            }
                        }
                    }

                    QGCButton {
                        primary:    true
                        text:       qsTr("Confirm & Save")
                        visible:    controller.calibrationDone
                        onClicked:  controller.confirmCalibration()
                    }
                }

                QGCLabel {
                    width:      parent.width
                    wrapMode:   Text.WordWrap
                    text:       controller.calibrating ?
                                    qsTr("Move all RC sticks and switches to their extreme positions. Channels detected: %1").arg(controller.channelsCalibrated) :
                                (controller.calibrationDone ?
                                    qsTr("Calibration complete. Review the min/max values above and click 'Confirm & Save' to write parameters to the board.") :
                                    qsTr("Click Calibrate to start radio calibration. Move all sticks and switches to their extremes in one step."))
                }

                ColumnLayout {
                    id:                 switchSettingsGrid
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    visible:            !controller.calibrating && !controller.calibrationDone

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
            }

            Item {
                id:             columnSpacer
                anchors.right:  rightColumn.left
                width:          20
            }

            Column {
                id:             rightColumn
                anchors.top:    parent.top
                anchors.right:  parent.right
                width:          ScreenTools.defaultFontPixelWidth * 40
                spacing:        ScreenTools.defaultFontPixelHeight / 2

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

                Image {
                    width:      parent.width
                    fillMode:   Image.PreserveAspectFit
                    smooth:     true
                    source:     controller.imageHelp
                }

                RCChannelMonitor {
                    width:      parent.width
                    twoColumn:  true
                    showCalibrationMinMax: controller.calibrating
                    calibrationMinMax:     controller.channelMinMax
                }
            }
        }
    }
}
