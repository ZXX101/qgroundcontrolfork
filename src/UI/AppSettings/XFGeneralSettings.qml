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
        Loader {
            id: generalPageLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceComponent: generalPageComp
        }
        Loader {
            id: flyviewLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceComponent: flyviewPageComp
        }
        Loader {
            id: appmessageLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: "XFAppMessages.qml"
        }
        Loader {
            id: rtksettingsLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceComponent: rtksettingsComp
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
            QGCLabel {
                text: qsTr("RTK Settings")
            }
            Item {
                Layout.fillHeight: true
            }
        }
    }
}
