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
import QGroundControl.FactSystem
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
    property int editSequenceNumber: -1

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
                    spacing: ScreenTools.defaultFontPixelWidth / 2
                    Layout.alignment: Qt.AlignTop
                    Layout.fillHeight: true

                    QGCButton {
                        text: qsTr("Basic")
                        checked: currentTab === "basic"
                        onClicked: {
                            currentTab = "basic";
                            editSequenceNumber = -1;
                        }
                        Layout.fillWidth: true
                    }
                    QGCButton {
                        text: qsTr("List")
                        checked: currentTab === "list"
                        onClicked: {
                            currentTab = "list";
                            editSequenceNumber = -1;
                        }
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: qgcPal.windowShade
                        visible: missionController && missionController.visualItems.count > 1
                    }

                    Repeater {
                        model: missionController ? missionController.visualItems : null

                        QGCButton {
                            required property int index
                            required property var object
                            text: object.sequenceNumber === 0 ? "" : "#" + object.sequenceNumber
                            visible: object.sequenceNumber !== 0
                            checked: editSequenceNumber === object.sequenceNumber
                            Layout.fillWidth: true
                            onClicked: {
                                editSequenceNumber = object.sequenceNumber;
                                currentTab = "editor";
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
                Loader {
                    id: contentLoader
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    source: {
                        if (currentTab === "basic")
                            return "XFMissionBasicPage.qml";
                        if (currentTab === "list")
                            return "XFMissionListPage.qml";
                            // return "";
                        if (currentTab === "editor")
                            return "XFMissionItemEditor.qml";
                        return "";
                    }

                    property var missionController: popup.missionController
                    property var currentEditItem: {
                        if (currentTab !== "editor" || editSequenceNumber < 0 || !missionController) return null
                        for (var i = 0; i < missionController.visualItems.count; i++) {
                            var itm = missionController.visualItems.get(i);
                            if (itm.sequenceNumber === editSequenceNumber) return itm;
                        }
                        return null;
                    }

                    onLoaded: {
                        updateMissionItem();
                    }

                    function updateMissionItem() {
                        if (item && item.hasOwnProperty("missionItem")) {
                            item.missionItem = currentEditItem;
                        }
                    }

                    onCurrentEditItemChanged: {
                        updateMissionItem();
                    }

                    Rectangle {
                        anchors.fill: contentLoader
                        color: qgcPal.windowShade
                        radius: ScreenTools.defaultFontPixelWidth / 4
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
}
