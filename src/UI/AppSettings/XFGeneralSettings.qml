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
import QGroundControl.MultiVehicleManager
import QGroundControl.Palette

ColumnLayout {
    property var _settingsManager: QGroundControl.settingsManager
    property var _appSettings: _settingsManager.appSettings
    property var _brandImageSettings: _settingsManager.brandImageSettings
    property Fact _appFontPointSize: _appSettings.appFontPointSize
    property Fact _userBrandImageIndoor: _brandImageSettings.userBrandImageIndoor
    property Fact _userBrandImageOutdoor: _brandImageSettings.userBrandImageOutdoor
    property Fact _appSavePath: _appSettings.savePath

    TabBar {
        id: bar
        Layout.fillWidth: true

        TabButton {
            text: qsTr("General")
        }
        TabButton {
            text: qsTr("Flyview")
        }
        TabButton {
            text: qsTr("System Console")
        }
        TabButton {
            text: qsTr("RTK Settings")
        }
    }
    StackLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        currentIndex: bar.currentIndex

        property real _pagePadding: ScreenTools.defaultFontPixelWidth * 2

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Loader {
                id: generalPageLoader
                anchors.fill: parent
                anchors.leftMargin: parent.parent._pagePadding
                anchors.rightMargin: parent.parent._pagePadding
                sourceComponent: generalPageComp
            }
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Loader {
                id: flyviewLoader
                anchors.fill: parent
                anchors.leftMargin: parent.parent._pagePadding
                anchors.rightMargin: parent.parent._pagePadding
                sourceComponent: flyviewPageComp
            }
        }
        Loader {
            id: appmessageLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: "XFAppMessages.qml"
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Loader {
                id: rtksettingsLoader
                anchors.fill: parent
                anchors.leftMargin: parent.parent._pagePadding
                anchors.rightMargin: parent.parent._pagePadding
                sourceComponent: rtksettingsComp
            }
        }
    }
    Component {
        id: generalPageComp
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            LabelledFactComboBox {
                label: qsTr("Language")
                fact: _appSettings.qLocaleLanguage
                indexModel: false
                visible: _appSettings.qLocaleLanguage.visible
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: ScreenTools.defaultFontPixelWidth * 2
                visible: _appSavePath.visible && !ScreenTools.isMobile

ColumnLayout {
    x:      ScreenTools.defaultFontPixelWidth * 2
    width:  parent.width - ScreenTools.defaultFontPixelWidth * 2
                    Layout.fillWidth: true
                    spacing: 0

                    QGCLabel {
                        text: qsTr("Application Load/Save Path")
                    }
                    QGCLabel {
                        Layout.fillWidth: true
                        font.pointSize: ScreenTools.smallFontPointSize
                        text: _appSavePath.rawValue === "" ? qsTr("<default location>") : _appSavePath.value
                        elide: Text.ElideMiddle
                    }
                }

                QGCButton {
                    text: qsTr("Browse")
                    onClicked: savePathBrowseDialog.openForLoad()
                    QGCFileDialog {
                        id: savePathBrowseDialog
                        title: qsTr("Choose the location to save/load files")
                        folder: _appSavePath.rawValue
                        selectFolder: true
                        onAcceptedForLoad: file => _appSavePath.rawValue = file
                    }
                }
            }
            Repeater {
                model: [QGroundControl.settingsManager.unitsSettings.horizontalDistanceUnits, QGroundControl.settingsManager.unitsSettings.verticalDistanceUnits, QGroundControl.settingsManager.unitsSettings.speedUnits]

                LabelledFactComboBox {
                    label: modelData.shortDescription
                    fact: modelData
                    indexModel: false
                }
            }
            Item {
                Layout.fillHeight: true
            }
        }
    }
    Component {
        id: flyviewPageComp
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Loader {
                id: flyviewSettings
                Layout.fillWidth: true
                source: "XFFlyViewSettings.qml"
            }
            Item {
                Layout.fillHeight: true
            }
        }
    }
    Component {
        id: rtksettingsComp
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            property var rtkSettings: _settingsManager.rtkSettings
            property bool useFixedPosition: rtkSettings.useFixedBasePosition.rawValue

            QGCPalette { id: qgcPal }

            QGCLabel {
                text: qsTr("NTRIP Network RTK")
                font.pointSize: ScreenTools.defaultFontPointSize
            }

            FactCheckBoxSlider {
                Layout.fillWidth: true
                text: qsTr("Enable NTRIP")
                fact: rtkSettings.ntripEnabled
                visible: fact.visible
            }

            LabelledFactTextField {
                label: qsTr("Server URL")
                fact: rtkSettings.ntripURL
                visible: rtkSettings.ntripEnabled.rawValue && fact.visible
            }

            QGCLabel {
                text: qsTr("Format: ntrip://user:pass@host:port/mountpoint")
                font.pointSize: ScreenTools.smallFontPointSize
                visible: rtkSettings.ntripEnabled.rawValue
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }

            FactCheckBoxSlider {
                Layout.fillWidth: true
                text: qsTr("Send GGA Position (VRS)")
                fact: rtkSettings.ntripSendGGA
                visible: rtkSettings.ntripEnabled.rawValue && fact.visible
            }

            FactCheckBoxSlider {
                Layout.fillWidth: true
                text: qsTr("Use NTRIP v1 Protocol")
                fact: rtkSettings.ntripV1
                visible: rtkSettings.ntripEnabled.rawValue && fact.visible
            }

            RowLayout {
                visible: rtkSettings.ntripEnabled.rawValue
                Layout.fillWidth: true

                QGCLabel {
                    text: qsTr("Status:")
                }

                QGCLabel {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: QGroundControl.gpsRtk.ntripConnected.value
                          ? qsTr("● Connected (%1 bytes received)").arg(QGroundControl.gpsRtk.ntripBytesReceived.value)
                          : (QGroundControl.gpsRtk.ntripStatus.value !== ""
                             ? qsTr("○ %1").arg(QGroundControl.gpsRtk.ntripStatus.value)
                             : qsTr("○ Disconnected"))
                    color: QGroundControl.gpsRtk.ntripConnected.value
                           ? qgcPal.colorGreen
                           : qgcPal.colorRed
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: qgcPal.windowShade
            }

            QGCLabel {
                text: qsTr("RTK GPS Base Station")
                font.pointSize: ScreenTools.defaultFontPointSize
            }

            FactCheckBoxSlider {
                Layout.fillWidth: true
                text: qsTr("AutoConnect")
                fact: _settingsManager.autoConnectSettings.autoConnectRTKGPS
                visible: fact.visible
            }

            RowLayout {
                visible: rtkSettings.useFixedBasePosition.visible

                QGCRadioButton {
                    text: qsTr("Survey-In")
                    checked: !useFixedPosition
                    onClicked: rtkSettings.useFixedBasePosition.rawValue = false
                }

                QGCRadioButton {
                    text: qsTr("Specify position")
                    checked: useFixedPosition
                    onClicked: rtkSettings.useFixedBasePosition.rawValue = true
                }
            }

            FactSlider {
                Layout.fillWidth: true
                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 40
                label: qsTr("Accuracy (u-blox only)")
                fact: rtkSettings.surveyInAccuracyLimit
                majorTickStepSize: 0.1
                visible: !useFixedPosition && rtkSettings.surveyInAccuracyLimit.visible
            }

            FactSlider {
                Layout.fillWidth: true
                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 40
                label: qsTr("Min Duration")
                fact: rtkSettings.surveyInMinObservationDuration
                majorTickStepSize: 10
                visible: !useFixedPosition && rtkSettings.surveyInMinObservationDuration.visible
            }

            LabelledFactTextField {
                label: rtkSettings.fixedBasePositionLatitude.shortDescription
                fact: rtkSettings.fixedBasePositionLatitude
                visible: useFixedPosition && rtkSettings.fixedBasePositionLatitude.visible
            }

            LabelledFactTextField {
                label: rtkSettings.fixedBasePositionLongitude.shortDescription
                fact: rtkSettings.fixedBasePositionLongitude
                visible: useFixedPosition && rtkSettings.fixedBasePositionLongitude.visible
            }

            LabelledFactTextField {
                label: rtkSettings.fixedBasePositionAltitude.shortDescription
                fact: rtkSettings.fixedBasePositionAltitude
                visible: useFixedPosition && rtkSettings.fixedBasePositionAltitude.visible
            }

            LabelledFactTextField {
                label: rtkSettings.fixedBasePositionAccuracy.shortDescription
                fact: rtkSettings.fixedBasePositionAccuracy
                visible: useFixedPosition && rtkSettings.fixedBasePositionAccuracy.visible
            }

            LabelledButton {
                label: qsTr("Current Base Position")
                buttonText: enabled ? qsTr("Save") : qsTr("Not Yet Valid")
                visible: useFixedPosition
                enabled: QGroundControl.gpsRtk.valid.value

                onClicked: {
                    rtkSettings.fixedBasePositionLatitude.rawValue = QGroundControl.gpsRtk.currentLatitude.rawValue
                    rtkSettings.fixedBasePositionLongitude.rawValue = QGroundControl.gpsRtk.currentLongitude.rawValue
                    rtkSettings.fixedBasePositionAltitude.rawValue = QGroundControl.gpsRtk.currentAltitude.rawValue
                    rtkSettings.fixedBasePositionAccuracy.rawValue = QGroundControl.gpsRtk.currentAccuracy.rawValue
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
