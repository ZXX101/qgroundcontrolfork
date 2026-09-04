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

Item {
    id: rootLayout

    property var missionItem
    property var flightMap

    readonly property var _masterController: missionItem ? missionItem.masterController : null

    Rectangle {
        id: scrollArea
        anchors.fill: parent
        color: "#101010"

        QGCFlickable {
            id: editorFlickable
            anchors.fill: parent
            anchors.margins: ScreenTools.defaultFontPixelWidth
            clip: true
            contentWidth: width
            contentHeight: contentColumn.height
            flickableDirection: Flickable.VerticalFlick

            Column {
                id: contentColumn
                width: editorFlickable.width
                spacing: ScreenTools.defaultFontPixelHeight / 2

                RowLayout {
                    width: parent.width

                    QGCLabel {
                        text: qsTr("Command")
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Item {
                        id: commandPicker
                        Layout.preferredWidth: commandInnerLayout.width + ScreenTools.comboBoxPadding * 2
                        Layout.preferredHeight: ScreenTools.implicitComboBoxHeight

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.color: qgcPal.windowShade
                            border.width: 1
                            radius: ScreenTools.buttonBorderRadius
                        }

                        RowLayout {
                            id: commandInnerLayout
                            anchors.centerIn: parent
                            spacing: ScreenTools.comboBoxPadding

                            QGCLabel {
                                text: missionItem ? missionItem.commandName : ""
                            }

                            QGCColoredImage {
                                width: ScreenTools.defaultFontPixelWidth
                                height: width
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                antialiasing: true
                                color: qgcPal.text
                                source: "/qmlimages/arrow-down.png"
                                visible: missionItem ? missionItem.isSimpleItem : false
                            }
                        }

                        QGCMouseArea {
                            fillItem: parent
                            enabled: missionItem ? missionItem.isSimpleItem : false
                            onClicked: commandDialog.createObject(mainWindow).open()
                        }

                        Component {
                            id: commandDialog

                            MissionCommandDialog {
                                vehicle: _masterController ? _masterController.controllerVehicle : null
                                missionItem: rootLayout.missionItem
                                map: rootLayout.flightMap
                                flyThroughCommandsAllowed: true
                            }
                        }
                    }
                }

                Loader {
                    id: editorLoader
                    width: parent.width
                    source: missionItem ? missionItem.editorQml : ""
                    asynchronous: true

                    onLoaded: {
                        if (item && item.hasOwnProperty("xfFieldOutlineEnabled")) {
                            item.xfFieldOutlineEnabled = true
                        }
                        if (item && item.hasOwnProperty("xfCoordinateFieldsEnabled")) {
                            item.xfCoordinateFieldsEnabled = true
                        }
                        if (item && item.hasOwnProperty("xfDarkBackgroundEnabled")) {
                            item.xfDarkBackgroundEnabled = true
                        }
                    }

                    property var masterController: _masterController
                    property real availableWidth: width
                    property var editorRoot: rootLayout
                }
            }

            ScrollIndicator.vertical: ScrollIndicator { }
        }
    }

    QGCPalette {
        id: qgcPal
    }

    onMissionItemChanged: editorFlickable.contentY = 0

    Connections {
        target: missionItem && missionItem.isSimpleItem ? missionItem : null

        function onCommandChanged() {
            editorFlickable.contentY = 0
        }
    }
}
