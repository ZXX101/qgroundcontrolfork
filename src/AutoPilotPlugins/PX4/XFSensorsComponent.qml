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
import QGroundControl.Palette
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Controllers

SetupPage {
    id:             sensorsPage
    pageComponent:  sensorsPageComponent
    pageName:       ""
    pageDescription: ""

    Component {
        id:             sensorsPageComponent

        Item {
            width:  availableWidth
            height: availableHeight

            readonly property string compassHelp:   qsTr("For Compass calibration you will need to rotate your vehicle through a number of positions.")
            readonly property string accelHelp:     qsTr("For Accelerometer calibration you will need to place your vehicle on all six sides on a perfectly level surface and hold it still in each orientation for a few seconds.")
            readonly property string levelHelp:     qsTr("To level the horizon you need to place the vehicle in its level flight position and leave still.")

            readonly property string statusTextAreaDefaultText: qsTr("Start the calibration by clicking the Start Calibration button.")

            property string preCalibrationDialogType
            property string preCalibrationDialogHelp

            readonly property int rotationColumnWidth: 250

            property Fact cal_mag0_id:      controller.getParameterFact(-1, "CAL_MAG0_ID")
            property Fact cal_mag1_id:      controller.getParameterFact(-1, "CAL_MAG1_ID")
            property Fact cal_mag2_id:      controller.getParameterFact(-1, "CAL_MAG2_ID")
            property Fact cal_mag0_rot:     controller.getParameterFact(-1, "CAL_MAG0_ROT")
            property Fact cal_mag1_rot:     controller.getParameterFact(-1, "CAL_MAG1_ROT")
            property Fact cal_mag2_rot:     controller.getParameterFact(-1, "CAL_MAG2_ROT")

            property Fact cal_gyro0_id:     controller.getParameterFact(-1, "CAL_GYRO0_ID")
            property Fact cal_acc0_id:      controller.getParameterFact(-1, "CAL_ACC0_ID")

            property Fact sens_board_rot:   controller.getParameterFact(-1, "SENS_BOARD_ROT")

            property bool _sensorsHaveFixedOrientation:    QGroundControl.corePlugin.options.sensorsHaveFixedOrientation
            property bool _wifiReliableForCalibration:     QGroundControl.corePlugin.options.wifiReliableForCalibration
            property bool _allMagsDisabled:                controller.parameterExists(-1, "SYS_HAS_MAG") ? controller.getParameterFact(-1, "SYS_HAS_MAG").value === 0 : false
            property bool _compassOrientationChangeAllowed: !_sensorsHaveFixedOrientation

            readonly property int _calTypeCompass:  1
            readonly property int _calTypeAccel:    2
            readonly property int _calTypeLevel:    3
            readonly property int _buttonWidth:     ScreenTools.defaultFontPixelWidth * 15

            property bool   compassCalNeeded:   cal_mag0_id.value === 0 && !_allMagsDisabled
            property bool   accelCalNeeded:     cal_acc0_id.value === 0
            property real   _margins:           ScreenTools.defaultFontPixelHeight / 2

            property Fact _ekf2GpsPosX:  controller.getParameterFact(-1, "EKF2_GPS_POS_X", false)
            property Fact _ekf2GpsPosY:  controller.getParameterFact(-1, "EKF2_GPS_POS_Y", false)
            property Fact _ekf2GpsPosZ:  controller.getParameterFact(-1, "EKF2_GPS_POS_Z", false)

            function showPreCalibrationDialog(calType) {
                switch (calType) {
                case _calTypeCompass:
                    preCalibrationDialogType = "compass"
                    preCalibrationDialogHelp = compassHelp
                    preCalibrationDialogComponent.createObject(mainWindow, { title: qsTr("Calibrate Compass") }).open()
                    break
                case _calTypeAccel:
                    preCalibrationDialogType = "accel"
                    preCalibrationDialogHelp = accelHelp
                    preCalibrationDialogComponent.createObject(mainWindow, { title: qsTr("Calibrate Accelerometer") }).open()
                    break
                case _calTypeLevel:
                    preCalibrationDialogType = "level"
                    preCalibrationDialogHelp = levelHelp
                    preCalibrationDialogComponent.createObject(mainWindow, { title: qsTr("Level Horizon") }).open()
                    break
                }
            }

            SensorsComponentController {
                id:                         controller
                statusLog:                  statusTextArea
                progressBar:                progressBar
                compassButton:              compassButton
                gyroButton:                 gyroButton
                accelButton:                accelButton
                airspeedButton:             airspeedButton
                levelButton:                levelButton
                cancelButton:               cancelButton
                setOrientationsButton:      setOrientationsButton
                orientationCalAreaHelpText: orientationCalAreaHelpText

                onResetStatusTextArea: statusLog.text = statusTextAreaDefaultText

                onMagCalComplete: {
                    setOrientationsDialogShowBoardOrientation = false
                    setOrientationsDialogComponent.createObject(mainWindow, { title: qsTr("Compass Calibration Complete"), showRebootVehicleButton: true }).open()
                }

                onWaitingForCancelChanged: {
                    if (controller.waitingForCancel) {
                        waitForCancelDialogComponent.createObject(mainWindow).open()
                    }
                }
            }

            Component.onCompleted: {
                var usingUDP = controller.usingUDPLink()
                if (usingUDP && !_wifiReliableForCalibration) {
                    mainWindow.showMessageDialog(qsTr("Sensor Calibration"), qsTr("Performing sensor calibration over a WiFi connection is known to be unreliable. You should disconnect and perform calibration using a direct USB connection instead."))
                }
            }

            QGCPalette { id: qgcPal; colorGroupEnabled: true }

            Component {
                id: waitForCancelDialogComponent

                QGCSimpleMessageDialog {
                    title:      qsTr("Calibration Cancel")
                    text:       qsTr("Waiting for Vehicle to response to Cancel. This may take a few seconds.")
                    buttons:    0

                    Connections {
                        target: controller

                        onWaitingForCancelChanged: {
                            if (!controller.waitingForCancel) {
                                close()
                            }
                        }
                    }
                }
            }

            Component {
                id: preCalibrationDialogComponent

                QGCPopupDialog {
                    buttons: Dialog.Cancel | Dialog.Ok

                    onAccepted: {
                        if (preCalibrationDialogType == "accel") {
                            controller.calibrateAccel()
                        } else if (preCalibrationDialogType == "level") {
                            controller.calibrateLevel()
                        } else if (preCalibrationDialogType == "compass") {
                            controller.calibrateCompass()
                        }
                    }

                    ColumnLayout {
                        spacing: ScreenTools.defaultFontPixelHeight

                        QGCLabel {
                            Layout.minimumWidth:    ScreenTools.defaultFontPixelWidth * 50
                            Layout.preferredWidth:  innerColumn.width
                            wrapMode:               Text.WordWrap
                            text:                   preCalibrationDialogHelp
                        }

                        Column {
                            id:         innerColumn
                            spacing:    parent.spacing

                            QGCLabel {
                                id:         boardRotationHelp
                                wrapMode:   Text.WordWrap
                                visible:    !_sensorsHaveFixedOrientation && (preCalibrationDialogType == "accel" || preCalibrationDialogType == "compass")
                                text:       qsTr("Set autopilot orientation before calibrating.")
                            }

                            Column {
                                visible:    boardRotationHelp.visible
                                QGCLabel { text: qsTr("Autopilot Orientation") }

                                FactComboBox {
                                    sizeToContents: true
                                    fact:           sens_board_rot
                                }

                                QGCLabel {
                                    wrapMode:   Text.WordWrap
                                    text:       qsTr("ROTATION_NONE indicates component points in direction of flight.")
                                }
                            }

                            QGCLabel {
                                wrapMode:   Text.WordWrap
                                text:       qsTr("Click Ok to start calibration.")
                            }
                        }
                    }
                }
            }

            property bool setOrientationsDialogShowBoardOrientation:    true

            Component {
                id: setOrientationsDialogComponent

                QGCPopupDialog {
                    buttons: Dialog.Ok

                    property bool showRebootVehicleButton: true

                    ColumnLayout {
                        spacing: ScreenTools.defaultFontPixelHeight

                        QGCLabel {
                            text:       qsTr("Reboot the vehicle prior to flight.")
                            visible:    showRebootVehicleButton
                        }

                        QGCButton {
                            text:       qsTr("Reboot Vehicle")
                            visible:    showRebootVehicleButton
                            onClicked: { controller.vehicle.rebootVehicle(); close() }
                        }

                        QGCLabel {
                            text:       qsTr("Adjust orientations as needed.\n\nROTATION_NONE indicates component points in direction of flight.")
                            visible:    !_sensorsHaveFixedOrientation
                        }

                        Column {
                            visible: !_sensorsHaveFixedOrientation && setOrientationsDialogShowBoardOrientation

                            QGCLabel {
                                text: qsTr("Autopilot Orientation")
                            }

                            FactComboBox {
                                sizeToContents: true
                                fact:           sens_board_rot
                            }
                        }

                        Repeater {
                            model: _compassOrientationChangeAllowed ? 3 : 0

                            Column {
                                visible: calMagIdFact.value > 0 && calMagRotFact.value >= 0

                                property Fact calMagIdFact:     controller.getParameterFact(-1, "CAL_MAG" + index + "_ID")
                                property Fact calMagRotFact:    controller.getParameterFact(-1, "CAL_MAG" + index + "_ROT")

                                QGCLabel {
                                    text: qsTr("Compass %1 Orientation").arg(index)
                                }

                                FactComboBox {
                                    sizeToContents: true
                                    fact:           parent.calMagRotFact
                                }
                            }
                        }
                    }
                }
            }

            Column {
                anchors.top:        parent.top
                anchors.bottom:     parent.bottom
                anchors.left:       parent.left
                anchors.right:      parent.right

                TabBar {
                    id:         sensorTabBar
                    width:      parent.width
                    spacing:    0
                    background: Rectangle { color: "transparent" }

                    TabButton {
                        contentItem: Row {
                            spacing: ScreenTools.defaultFontPixelWidth / 2
                            Rectangle {
                                width:              ScreenTools.defaultFontPixelHeight * 0.5
                                height:             width
                                radius:             width / 2
                                color:              !compassCalNeeded ? "green" : "red"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text:                   qsTr("Compass")
                                font:                   parent.parent.font
                                color:                  qgcPal.buttonText
                                horizontalAlignment:    Text.AlignHCenter
                                verticalAlignment:      Text.AlignVCenter
                            }
                        }
                        background: Rectangle {
                            color: "transparent"
                            Rectangle {
                                anchors.bottom:            parent.bottom
                                anchors.horizontalCenter:  parent.horizontalCenter
                                width:                     parent.width * 0.8
                                height:                    2
                                color:                     "#154D25"
                                visible:                   parent.parent.checked
                            }
                        }
                    }
                    TabButton {
                        contentItem: Row {
                            spacing: ScreenTools.defaultFontPixelWidth / 2
                            Rectangle {
                                width:              ScreenTools.defaultFontPixelHeight * 0.5
                                height:             width
                                radius:             width / 2
                                color:              !accelCalNeeded ? "green" : "red"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text:                   qsTr("Accelerometer")
                                font:                   parent.parent.font
                                color:                  qgcPal.buttonText
                                horizontalAlignment:    Text.AlignHCenter
                                verticalAlignment:      Text.AlignVCenter
                            }
                        }
                        background: Rectangle {
                            color: "transparent"
                            Rectangle {
                                anchors.bottom:            parent.bottom
                                anchors.horizontalCenter:  parent.horizontalCenter
                                width:                     parent.width * 0.8
                                height:                    2
                                color:                     "#154D25"
                                visible:                   parent.parent.checked
                            }
                        }
                    }
                    TabButton {
                        contentItem: Row {
                            spacing: ScreenTools.defaultFontPixelWidth / 2
                            Rectangle {
                                width:              ScreenTools.defaultFontPixelHeight * 0.5
                                height:             width
                                radius:             width / 2
                                color:              "gray"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text:                   qsTr("Level Horizon")
                                font:                   parent.parent.font
                                color:                  qgcPal.buttonText
                                horizontalAlignment:    Text.AlignHCenter
                                verticalAlignment:      Text.AlignVCenter
                            }
                        }
                        background: Rectangle {
                            color: "transparent"
                            Rectangle {
                                anchors.bottom:            parent.bottom
                                anchors.horizontalCenter:  parent.horizontalCenter
                                width:                     parent.width * 0.8
                                height:                    2
                                color:                     "#154D25"
                                visible:                   parent.parent.checked
                            }
                        }
                    }
                    TabButton {
                        contentItem: Row {
                            spacing: ScreenTools.defaultFontPixelWidth / 2
                            Rectangle {
                                width:              ScreenTools.defaultFontPixelHeight * 0.5
                                height:             width
                                radius:             width / 2
                                color:              "gray"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text:                   qsTr("GPS Location")
                                font:                   parent.parent.font
                                color:                  qgcPal.buttonText
                                horizontalAlignment:    Text.AlignHCenter
                                verticalAlignment:      Text.AlignVCenter
                            }
                        }
                        background: Rectangle {
                            color: "transparent"
                            Rectangle {
                                anchors.bottom:            parent.bottom
                                anchors.horizontalCenter:  parent.horizontalCenter
                                width:                     parent.width * 0.8
                                height:                    2
                                color:                     "#154D25"
                                visible:                   parent.parent.checked
                            }
                        }
                    }
                }

                StackLayout {
                    width:          parent.width
                    currentIndex:   sensorTabBar.currentIndex
                    clip:           true
                    height:         children[currentIndex] ? children[currentIndex].implicitHeight : 0

                    // Compass Tab
                    RowLayout {
                        spacing: _margins

                        QGCLabel {
                            Layout.fillWidth:   true
                            wrapMode:           Text.WordWrap
                            text:               compassHelp
                        }

                        RowLayout {
                            id:             calButtonColumn
                            spacing:        _margins

                            QGCButton {
                                id:         compassButton
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 18
                                text:       qsTr("Start Calibration")
                                onClicked:  showPreCalibrationDialog(_calTypeCompass)
                            }

                            QGCButton {
                                id:         cancelButton
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 18
                                text:       qsTr("Cancel")
                                enabled:    false
                                onClicked:  controller.cancelCalibration()
                            }

                            QGCButton {
                                id:         setOrientationsButton
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 18
                                text:       qsTr("Orientations")
                                visible:    !_sensorsHaveFixedOrientation && !_allMagsDisabled
                                onClicked:  {
                                    setOrientationsDialogShowBoardOrientation = true
                                    setOrientationsDialogComponent.createObject(mainWindow, { title: qsTr("Set Orientations"), showRebootVehicleButton: false }).open()
                                }
                            }
                        }
                    }

                    // Accelerometer Tab
                    RowLayout {
                        spacing: _margins

                        QGCLabel {
                            Layout.fillWidth:   true
                            wrapMode:           Text.WordWrap
                            text:               accelHelp
                        }

                        RowLayout {
                            spacing:        _margins

                            QGCButton {
                                id:         accelButton
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 18
                                text:       qsTr("Start Calibration")
                                onClicked:  showPreCalibrationDialog(_calTypeAccel)
                            }

                            QGCButton {
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 18
                                text:       qsTr("Cancel")
                                enabled:    cancelButton.enabled
                                onClicked:  controller.cancelCalibration()
                            }
                        }
                    }

                    // Level Horizon Tab
                    RowLayout {
                        spacing: _margins

                        QGCLabel {
                            Layout.fillWidth:   true
                            wrapMode:           Text.WordWrap
                            text:               levelHelp
                        }

                        RowLayout {
                            spacing:        _margins

                            QGCButton {
                                id:         levelButton
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 18
                                text:       qsTr("Start Calibration")
                                enabled:    cal_acc0_id.value !== 0
                                onClicked:  showPreCalibrationDialog(_calTypeLevel)
                            }

                            QGCButton {
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 18
                                text:       qsTr("Cancel")
                                enabled:    cancelButton.enabled
                                onClicked:  controller.cancelCalibration()
                            }
                        }
                    }

                    // GPS Location Tab
                    ColumnLayout {
                        spacing: ScreenTools.defaultFontPixelHeight

                        QGCLabel {
                            text:           qsTr("Positive values are forward, right, and down. Negative values are backward, left, and up.")
                            font.pointSize: ScreenTools.smallFontPointSize
                            color:          qgcPal.text
                            opacity:        0.5
                            wrapMode:       Text.WordWrap
                            Layout.fillWidth: true
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: ScreenTools.defaultFontPixelHeight * 0.5

                            QGCLabel {
                                text: qsTr("GPS Antenna Position (EKF2)")
                                font.bold: true
                                Layout.fillWidth: true
                            }
                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "X"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                FactTextField { fact: _ekf2GpsPosX; unitsLabel: ""; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                                QGCLabel { text: "m"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                            }
                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "Y"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                FactTextField { fact: _ekf2GpsPosY; unitsLabel: ""; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                                QGCLabel { text: "m"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                            }
                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth
                                QGCLabel { text: "Z"; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                                FactTextField { fact: _ekf2GpsPosZ; unitsLabel: ""; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10 }
                                QGCLabel { text: "m"; color: qgcPal.text; opacity: 0.5; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 2 }
                            }
                        }
                    }
                }

                ProgressBar {
                    id:             progressBar
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    visible:        sensorTabBar.currentIndex !== 3
                }

                Item { height: ScreenTools.defaultFontPixelHeight; width: 10; visible: sensorTabBar.currentIndex !== 3 }

                Item {
                    id:     centerPanel
                    width:  parent.width
                    height: parent.height - y
                    visible: sensorTabBar.currentIndex !== 3

                    TextArea {
                        id:             statusTextArea
                        anchors.fill:   parent
                        readOnly:       true
                        text:           statusTextAreaDefaultText
                        color:          qgcPal.text
                        background:     Rectangle { color: qgcPal.windowShade }
                    }

                    Rectangle {
                        id:             orientationCalArea
                        anchors.fill:   parent
                        visible:        controller.showOrientationCalArea
                        color:          qgcPal.windowShade

                        QGCLabel {
                            id:                 orientationCalAreaHelpText
                            anchors.margins:    ScreenTools.defaultFontPixelWidth
                            anchors.top:        orientationCalArea.top
                            anchors.left:       orientationCalArea.left
                            width:              parent.width
                            wrapMode:           Text.WordWrap
                            font.pointSize:     ScreenTools.mediumFontPointSize
                        }

                        Flow {
                            anchors.topMargin:  ScreenTools.defaultFontPixelWidth
                            anchors.top:        orientationCalAreaHelpText.bottom
                            anchors.bottom:     parent.bottom
                            anchors.left:       parent.left
                            anchors.right:      parent.right
                            spacing:            ScreenTools.defaultFontPixelWidth

                            property real indicatorWidth:   (width / 3) - (spacing * 2)
                            property real indicatorHeight:  (height / 2) - spacing

                            VehicleRotationCal {
                                width:              parent.indicatorWidth
                                height:             parent.indicatorHeight
                                visible:            controller.orientationCalDownSideVisible
                                calValid:           controller.orientationCalDownSideDone
                                calInProgress:      controller.orientationCalDownSideInProgress
                                calInProgressText:  controller.orientationCalDownSideRotate ? qsTr("Rotate") : qsTr("Hold Still")
                                imageSource:        controller.orientationCalDownSideRotate ? "qrc:///qmlimages/VehicleDownRotate.png" : "qrc:///qmlimages/VehicleDown.png"
                            }
                            VehicleRotationCal {
                                width:              parent.indicatorWidth
                                height:             parent.indicatorHeight
                                visible:            controller.orientationCalLeftSideVisible
                                calValid:           controller.orientationCalLeftSideDone
                                calInProgress:      controller.orientationCalLeftSideInProgress
                                calInProgressText:  controller.orientationCalLeftSideRotate ? qsTr("Rotate") : qsTr("Hold Still")
                                imageSource:        controller.orientationCalLeftSideRotate ? "qrc:///qmlimages/VehicleLeftRotate.png" : "qrc:///qmlimages/VehicleLeft.png"
                            }
                            VehicleRotationCal {
                                width:              parent.indicatorWidth
                                height:             parent.indicatorHeight
                                visible:            controller.orientationCalRightSideVisible
                                calValid:           controller.orientationCalRightSideDone
                                calInProgress:      controller.orientationCalRightSideInProgress
                                calInProgressText:  controller.orientationCalRightSideRotate ? qsTr("Rotate") : qsTr("Hold Still")
                                imageSource:        controller.orientationCalRightSideRotate ? "qrc:///qmlimages/VehicleRightRotate.png" : "qrc:///qmlimages/VehicleRight.png"
                            }
                            VehicleRotationCal {
                                width:              parent.indicatorWidth
                                height:             parent.indicatorHeight
                                visible:            controller.orientationCalNoseDownSideVisible
                                calValid:           controller.orientationCalNoseDownSideDone
                                calInProgress:      controller.orientationCalNoseDownSideInProgress
                                calInProgressText:  controller.orientationCalNoseDownSideRotate ? qsTr("Rotate") : qsTr("Hold Still")
                                imageSource:        controller.orientationCalNoseDownSideRotate ? "qrc:///qmlimages/VehicleNoseDownRotate.png" : "qrc:///qmlimages/VehicleNoseDown.png"
                            }
                            VehicleRotationCal {
                                width:              parent.indicatorWidth
                                height:             parent.indicatorHeight
                                visible:            controller.orientationCalTailDownSideVisible
                                calValid:           controller.orientationCalTailDownSideDone
                                calInProgress:      controller.orientationCalTailDownSideInProgress
                                calInProgressText:  controller.orientationCalTailDownSideRotate ? qsTr("Rotate") : qsTr("Hold Still")
                                imageSource:        controller.orientationCalTailDownSideRotate ? "qrc:///qmlimages/VehicleTailDownRotate.png" : "qrc:///qmlimages/VehicleTailDown.png"
                            }
                            VehicleRotationCal {
                                width:              parent.indicatorWidth
                                height:             parent.indicatorHeight
                                visible:            controller.orientationCalUpsideDownSideVisible
                                calValid:           controller.orientationCalUpsideDownSideDone
                                calInProgress:      controller.orientationCalUpsideDownSideInProgress
                                calInProgressText:  controller.orientationCalUpsideDownSideRotate ? qsTr("Rotate") : qsTr("Hold Still")
                                imageSource:        controller.orientationCalUpsideDownSideRotate ? "qrc:///qmlimages/VehicleUpsideDownRotate.png" : "qrc:///qmlimages/VehicleUpsideDown.png"
                            }
                        }
                    }

                    QGCButton {
                        text:  qsTr("Factory reset")
                        width: _buttonWidth

                        anchors {
                            right:       orientationCalArea.left
                            rightMargin: ScreenTools.defaultFontPixelWidth/2
                            bottom:      orientationCalArea.bottom
                        }

                        onClicked: {
                            controller.resetFactoryParameters()
                        }
                    }
                }
            }
        } // Item
    } // Component - sensorsPageComponent
} // SetupPage
