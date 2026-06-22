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

Rectangle {
    id: popup
    color: qgcPal.window
    radius: ScreenTools.defaultFontPixelWidth / 2
    border.width: 1
    border.color: qgcPal.windowShade

    property var missionController
    property var planMasterController
    property bool expanded: true

    property string currentTab: "basic"

    QGCPalette {
        id: qgcPal
    }

    MouseArea {
        anchors.fill: parent
        onPressed: mouse.accepted = true
        onWheel: wheel.accepted = true
    }

    ColumnLayout {
        anchors.fill: parent

        Rectangle {
            id: titleBar
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 2.5
            Layout.fillWidth: true
            color: qgcPal.toolbarBackground

            radius: popup.radius
            clip: true

            RowLayout {
                anchors.fill: parent
                anchors.margins: ScreenTools.defaultFontPixelWidth / 2
                spacing: ScreenTools.defaultFontPixelWidth / 2

                QGCButton {
                    text: expanded ? "◀" : "▶"
                    onClicked: expanded = !expanded
                }

                QGCLabel {
                    text: qsTr("Mission Info")
                    font.bold: true
                    font.pointSize: ScreenTools.defaultFontPixelSize * 1.2
                    color: qgcPal.buttonText
                    Layout.fillWidth: true
                }

                QGCButton {
                    text: "Delete"
                    _horizontalPadding: 0
                    onClicked: {
                        if (planMasterController) {
                            planMasterController.removeAllFromVehicle();
                        }
                    }
                }

                QGCButton {
                    text: "Open"
                    _horizontalPadding: 0
                    onClicked: {
                        if (typeof loadFromSelectedFile === "function") {
                            loadFromSelectedFile();
                        }
                    }
                }

                QGCButton {
                    text: "Save"
                    _horizontalPadding: 0
                    onClicked: {
                        if (typeof saveToSelectedFile === "function") {
                            saveToSelectedFile();
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: expanded

            RowLayout {
                anchors.fill: parent
                anchors.margins: ScreenTools.defaultFontPixelWidth / 2
                spacing: ScreenTools.defaultFontPixelWidth / 2

                ColumnLayout {
                    id: tabColumn
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                    spacing: ScreenTools.defaultFontPixelWidth /2
                    Layout.alignment: Qt.AlignTop
                    QGCButton {
                        text: qsTr("Basic")
                        // _horizontalPadding: 0
                        checked: currentTab === "basic"
                        onClicked: currentTab = "basic"
                        Layout.fillWidth: true
                    }
                    QGCButton {
                        text: qsTr("List")
                        // _horizontalPadding: 0
                        checked: currentTab === "list"
                        onClicked: currentTab = "list"
                        Layout.fillWidth: true
                    }
                }
                Loader {
                    id: contentLoader
                    Layout.fillWidth: true
                    source: currentTab === "basic" ? "XFMissionBasicPage.qml" : "XFMissionListPage.qml"

                    property var missionController: popup.missionController
                    Rectangle {
                        anchors.fill: contentLoader
                        color: qgcPal.windowShade
                        radius: ScreenTools.defaultFontPixelWidth / 4
                    }
                }
            }
        }

        Rectangle {
            id: bottomBar
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 2.5
            Layout.fillWidth: true
            color: qgcPal.toolbarBackground
            radius: popup.radius
            clip: true

            RowLayout {
                anchors.centerIn: parent
                spacing: ScreenTools.defaultFontPixelWidth

                QGCButton {
                    text: qsTr("Upload")
                    onClicked: {
                        if (typeof upload === "function") {
                            upload();
                        }
                    }
                }
                QGCButton {
                    text: qsTr("Download")
                    onClicked: {
                        if (planMasterController) {
                            planMasterController.loadFromVehicle();
                        }
                    }
                }
                QGCButton {
                    text: qsTr("Clear")
                    onClicked: {
                        if (planMasterController) {
                            planMasterController.removeAllFromVehicle();
                        }
                    }
                }
            }
        }
    }
}
