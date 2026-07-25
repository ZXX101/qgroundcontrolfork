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
    color: "#2A2A2A"
    radius: 0
    border.width: 0
    border.color: "transparent"

    property var missionController
    property var planMasterController
    property var geoFenceController
    property var flightMap
    property bool expanded: true
    property string missionName: "Mission"
    property bool fenceEnabled: false

    property string currentTab: "basic"
    property int editSequenceNumber: -1
    property int currentSequenceNumber: -1

    Component.onCompleted: {
        if (missionController) {
            currentSequenceNumber = missionController.currentPlanViewSeqNum;
        }
    }

    function syncToSequenceNumber(seqNum) {
        if (seqNum > 0 && missionController) {
            currentSequenceNumber = seqNum;
            currentTab = "editor";
            editSequenceNumber = seqNum;
            contentLoader.updateMissionItemForce();
        }
    }

    QGCPalette { id: qgcPal }

    MouseArea {
        anchors.fill: parent
        onPressed: mouse.accepted = true
        onWheel: wheel.accepted = true
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: titleBar
            Layout.preferredHeight: ScreenTools.toolbarHeight
            Layout.fillWidth: true
            color: "#2A2A2A"
            radius: 0
            clip: true

            RowLayout {
                anchors.fill: parent
                anchors.margins: ScreenTools.defaultFontPixelWidth / 2
                spacing: ScreenTools.defaultFontPixelWidth / 2

                QGCButton {
                    iconSource: expanded ? "/xfres/collapseMission.png" : "/xfres/expandMission.png"
                    onClicked: expanded = !expanded
                }

                QGCLabel {
                    text: qsTr("Mission Info")
                    font.bold: true
                    font.pointSize: ScreenTools.defaultFontPixelSize * 1.2
                    color: qgcPal.buttonText
                    Layout.fillWidth: true
                    visible: popup.expanded
                }

                QGCButton {
                    iconSource: "/xfres/clearMission.png"
                    _horizontalPadding: 0
                    visible: popup.expanded
                    onClicked: {
                        if (planMasterController) {
                            planMasterController.removeAllFromVehicle();
                        }
                    }
                }

                QGCButton {
                    iconSource: "/xfres/openMission.png"
                    _horizontalPadding: 0
                    visible: popup.expanded
                    onClicked: {
                        if (typeof loadFromSelectedFile === "function") {
                            loadFromSelectedFile();
                        }
                    }
                }

                QGCButton {
                    iconSource: "/xfres/saveMission.png"
                    _horizontalPadding: 0
                    visible: popup.expanded
                    onClicked: {
                        if (typeof saveToSelectedFile === "function") {
                            saveToSelectedFile();
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#303030"
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Rectangle {
                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                Layout.minimumWidth: ScreenTools.defaultFontPixelWidth * 8
                Layout.maximumWidth: ScreenTools.defaultFontPixelWidth * 8
                Layout.fillHeight: true
                color: "#191919"

                ColumnLayout {
                    id: tabColumn
                    anchors.fill: parent
                    spacing: 0

                    QGCButton {
                        text: qsTr("Basic")
                        checked: currentTab === "basic"
                        onClicked: {
                            currentTab = "basic";
                            editSequenceNumber = -1;
                        }
                        Layout.fillWidth: true
                        background: Rectangle {
                            color: parent.checked ? qgcPal.buttonHighlight : qgcPal.button
                            radius: 0
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: "#303030"
                    }
                    QGCButton {
                        text: qsTr("List")
                        checked: currentTab === "list"
                        onClicked: {
                            currentTab = "list";
                            editSequenceNumber = -1;
                        }
                        Layout.fillWidth: true
                        background: Rectangle {
                            color: parent.checked ? qgcPal.buttonHighlight : qgcPal.button
                            radius: 0
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: "#303030"
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        QGCFlickable {
                            anchors.fill: parent
                            clip: true
                            flickableDirection: Flickable.VerticalFlick
                            contentHeight: waypointColumn.height

                            ColumnLayout {
                                id: waypointColumn
                                width: parent.width
                                spacing: 0

                                Repeater {
                                    model: missionController ? missionController.visualItems : null

                                    QGCButton {
                                        required property int index
                                        required property var object
                                        text: object.sequenceNumber === 0 ? "" : "#" + object.sequenceNumber
                                        visible: object.sequenceNumber !== 0
                                        checked: currentSequenceNumber === object.sequenceNumber
                                        Layout.fillWidth: true
                                        background: Rectangle {
                                            color: parent.checked ? qgcPal.buttonHighlight : qgcPal.button
                                            radius: 0
                                            Rectangle {
                                                anchors.bottom: parent.bottom
                                                anchors.left: parent.left
                                                anchors.right: parent.right
                                                height: 1
                                                color: "#303030"
                                            }
                                        }
                                        onClicked: {
                                            editSequenceNumber = object.sequenceNumber;
                                            currentTab = "editor";
                                            if (missionController) {
                                                missionController.setCurrentPlanViewSeqNum(object.sequenceNumber, false);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                color: "#303030"
                visible: popup.expanded
            }

            Loader {
                id: contentLoader
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: popup.expanded ? -1 : 0
                visible: popup.expanded
                source: {
                    if (currentTab === "basic") return "XFMissionBasicPage.qml";
                    if (currentTab === "list") return "XFMissionListPage.qml";
                    if (currentTab === "editor") return "XFMissionItemEditor.qml";
                    return "";
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#101010"
                    radius: 0
                    z: -1
                }

                property var missionController: popup.missionController
                property string missionName: popup.missionName
                property var currentEditItem: {
                    if (currentTab !== "editor" || editSequenceNumber < 0 || !missionController) return null;
                    for (var i = 0; i < missionController.visualItems.count; i++) {
                        var itm = missionController.visualItems.get(i);
                        if (itm.sequenceNumber === editSequenceNumber) return itm;
                    }
                    return null;
                }

                function updateMissionItemForce() {
                    if (item && item.hasOwnProperty("missionItem")) {
                        var mi = null;
                        if (missionController && editSequenceNumber > 0) {
                            for (var i = 0; i < missionController.visualItems.count; i++) {
                                var itm = missionController.visualItems.get(i);
                                if (itm.sequenceNumber === editSequenceNumber) {
                                    mi = itm;
                                    break;
                                }
                            }
                        }
                        item.missionItem = mi;
                    }
                }

                onLoaded: {
                    updateMissionItemForce();
                    if (item) {
                        if (item.hasOwnProperty("geoFenceController")) item.geoFenceController = popup.geoFenceController;
                        if (item.hasOwnProperty("flightMap")) item.flightMap = popup.flightMap;
                    }
                }

                Connections {
                    target: contentLoader.item
                    ignoreUnknownSignals: true
                    function onFenceEnabledChanged() {
                        if (contentLoader.item && contentLoader.item.hasOwnProperty("fenceEnabled")) {
                            popup.fenceEnabled = contentLoader.item.fenceEnabled;
                        }
                    }
                }

                Connections {
                    target: popup
                    function onGeoFenceControllerChanged() {
                        if (contentLoader.item && contentLoader.item.hasOwnProperty("geoFenceController")) {
                            contentLoader.item.geoFenceController = popup.geoFenceController;
                        }
                    }
                    function onFlightMapChanged() {
                        if (contentLoader.item && contentLoader.item.hasOwnProperty("flightMap")) {
                            contentLoader.item.flightMap = popup.flightMap;
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#303030"
            visible: popup.expanded
        }

        Rectangle {
            id: bottomBar
            Layout.preferredHeight: ScreenTools.toolbarHeight * 0.8
            Layout.fillWidth: true
            color: "#2A2A2A"
            radius: 0
            clip: true
            visible: popup.expanded

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 3
                anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 3
                anchors.topMargin: ScreenTools.defaultFontPixelHeight * 0.75
                anchors.bottomMargin: ScreenTools.defaultFontPixelHeight * 0.75
                spacing: ScreenTools.defaultFontPixelWidth * 3

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height * 1.4
                    color: "#109B38"
                    radius: ScreenTools.defaultFontPixelHeight / 4

                    QGCLabel {
                        anchors.centerIn: parent
                        text: qsTr("Upload")
                        color: "white"
                    }

                    QGCMouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (typeof upload === "function") {
                                upload();
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height * 1.4
                    color: "#1969B3"
                    radius: ScreenTools.defaultFontPixelHeight / 4

                    QGCLabel {
                        anchors.centerIn: parent
                        text: qsTr("Download")
                        color: "white"
                    }

                    QGCMouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (planMasterController && typeof downloadClicked === "function") {
                                downloadClicked(qsTr("Plan overwrite"));
                            } else if (planMasterController) {
                                planMasterController.loadFromVehicle();
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height * 1.4
                    color: qgcPal.button
                    radius: ScreenTools.defaultFontPixelHeight / 4

                    QGCLabel {
                        anchors.centerIn: parent
                        text: qsTr("Clear")
                        color: qgcPal.buttonText
                    }

                    QGCMouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (typeof clearButtonClicked === "function") {
                                clearButtonClicked();
                            } else if (planMasterController) {
                                planMasterController.removeAllFromVehicle();
                            }
                        }
                    }
                }
            }
        }
    }
}