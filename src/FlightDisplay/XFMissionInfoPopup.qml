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
    id:                 popup
    color:              qgcPal.window
    radius:             ScreenTools.defaultFontPixelWidth / 2
    border.width:       1
    border.color:       qgcPal.windowShade

    property var        missionController
    property var        planMasterController
    property bool       expanded: true

    property string currentTab: "basic"

    QGCPalette { id: qgcPal }

    Rectangle {
        id:                 titleBar
        anchors.top:        parent.top
        anchors.left:       parent.left
        anchors.right:      parent.right
        height:             ScreenTools.defaultFontPixelHeight * 2.5
        color:              qgcPal.toolbarBackground
        radius:             parent.radius
        // radius:             0

        RowLayout {
            anchors.fill:   parent
            anchors.margins: ScreenTools.defaultFontPixelWidth / 2
            spacing:        ScreenTools.defaultFontPixelWidth / 2

            QGCButton {
                text:       expanded ? "◀" : "▶"
                onClicked:  expanded = !expanded
            }

            QGCLabel {
                text:       qsTr("Mission Info")
                font.bold:  true
                Layout.fillWidth: true
            }

            QGCButton {
                text:       "Delete"
                onClicked:  {
                    if (planMasterController) {
                        planMasterController.removeAllFromVehicle()
                    }
                }
            }

            QGCButton {
                text:       "Open"
                onClicked:  {
                    if (typeof loadFromSelectedFile === "function") {
                        loadFromSelectedFile()
                    }
                }
            }

            QGCButton {
                text:       "Save"
                onClicked:  {
                    if (typeof saveToSelectedFile === "function") {
                        saveToSelectedFile()
                    }
                }
            }
        }
    }

    Item {
        id:                 contentArea
        anchors.top:        titleBar.bottom
        anchors.left:       parent.left
        anchors.right:      parent.right
        anchors.bottom:     bottomBar.top
        visible:            expanded

        ColumnLayout {
            id:                 tabColumn
            anchors.left:       parent.left
            anchors.top:        parent.top
            anchors.margins:    ScreenTools.defaultFontPixelWidth
            spacing:            ScreenTools.defaultFontPixelWidth / 2

            QGCButton {
                text:           qsTr("Basic")
                checked:        currentTab === "basic"
                onClicked:      currentTab = "basic"
            }
            QGCButton {
                text:           qsTr("List")
                checked:        currentTab === "list"
                onClicked:      currentTab = "list"
            }
        }

        Loader {
            id:                 contentLoader
            anchors.left:       tabColumn.right
            anchors.leftMargin: ScreenTools.defaultFontPixelWidth
            anchors.right:      parent.right
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            source:             currentTab === "basic" ?
                                "XFMissionBasicPage.qml" : "XFMissionListPage.qml"

            property var missionController: popup.missionController
        }
    }

    Rectangle {
        id:                 bottomBar
        anchors.bottom:     parent.bottom
        anchors.left:       parent.left
        anchors.right:      parent.right
        height:             ScreenTools.defaultFontPixelHeight * 2.5
        color:              qgcPal.toolbarBackground
        // radius:             0
        radius:             parent.radius

        RowLayout {
            anchors.centerIn: parent
            spacing:            ScreenTools.defaultFontPixelWidth

            QGCButton {
                text:           qsTr("Upload")
                onClicked:      {
                    if (typeof upload === "function") {
                        upload()
                    }
                }
            }
            QGCButton {
                text:           qsTr("Download")
                onClicked:      {
                    if (planMasterController) {
                        planMasterController.loadFromVehicle()
                    }
                }
            }
            QGCButton {
                text:           qsTr("Clear")
                onClicked:      {
                    if (planMasterController) {
                        planMasterController.removeAllFromVehicle()
                    }
                }
            }
        }
    }
}
