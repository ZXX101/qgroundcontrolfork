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
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.ScreenTools
import QGroundControl.Controllers
import QGroundControl.FactSystem
import QGroundControl.FactControls

Item {
    id:         _root

    property Fact   _selectedFact:      null
    property int    _rowHeight:         ScreenTools.defaultFontPixelHeight * 2
    property int    _rowWidth:          10
    property bool   _searchFilter:      searchText.text.trim() != "" || controller.showModifiedOnly
    property var    _searchResults
    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property bool   _showRCToParam:     _activeVehicle.px4Firmware
    property var    _appSettings:       QGroundControl.settingsManager.appSettings
    property var    _controller:        controller

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    ParameterEditorController {
        id: controller
    }

    Timer {
        id:         clearTimer
        interval:   100;
        running:    false;
        repeat:     false
        onTriggered: {
            searchText.text = ""
            controller.searchText = ""
        }
    }

    QGCMenu {
        id:                 toolsMenu
        QGCMenuItem {
            text:           qsTr("Refresh")
            onTriggered:    controller.refresh()
        }
        QGCMenuItem {
            text:           qsTr("Reset all to firmware's defaults")
            onTriggered:    mainWindow.showMessageDialog(qsTr("Reset All"),
                                                         qsTr("Select Reset to reset all parameters to their defaults.\n\nNote that this will also completely reset everything, including UAVCAN nodes, all vehicle settings, setup and calibrations."),
                                                         Dialog.Cancel | Dialog.Reset,
                                                         function() { controller.resetAllToDefaults() })
        }
        QGCMenuItem {
            text:           qsTr("Reset to vehicle's configuration defaults")
            visible:        !_activeVehicle.apmFirmware
            onTriggered:    mainWindow.showMessageDialog(qsTr("Reset All"),
                                                         qsTr("Select Reset to reset all parameters to the vehicle's configuration defaults."),
                                                         Dialog.Cancel | Dialog.Reset,
                                                         function() { controller.resetAllToVehicleConfiguration() })
        }
        QGCMenuSeparator { }
        QGCMenuItem {
            text:           qsTr("Load from file for review...")
            onTriggered: {
                fileDialog.title = qsTr("Load Parameters")
                fileDialog.openForLoad()
            }
        }
        QGCMenuItem {
            text:           qsTr("Save to file...")
            onTriggered: {
                fileDialog.title = qsTr("Save Parameters")
                fileDialog.openForSave()
            }
        }
        QGCMenuSeparator { visible: _showRCToParam }
        QGCMenuItem {
            text:           qsTr("Clear all RC to Param")
            onTriggered:    _activeVehicle.clearAllParamMapRC()
            visible:        _showRCToParam
        }
        QGCMenuSeparator { }
        QGCMenuItem {
            text:           qsTr("Reboot Vehicle")
            onTriggered:    mainWindow.showMessageDialog(qsTr("Reboot Vehicle"),
                                                         qsTr("Select Ok to reboot vehicle."),
                                                         Dialog.Cancel | Dialog.Ok,
                                                         function() { _activeVehicle.rebootVehicle() })
        }
    }

    QGCFileDialog {
        id:             fileDialog
        folder:         _appSettings.parameterSavePath
        nameFilters:    [ qsTr("Parameter Files (*.%1)").arg(_appSettings.parameterFileExtension) , qsTr("All Files (*)") ]

        onAcceptedForSave: (file) => {
            controller.saveToFile(file)
            close()
        }

        onAcceptedForLoad: (file) => {
            close()
            if (controller.buildDiffFromFile(file)) {
                parameterDiffDialog.createObject(mainWindow).open()
            }
        }
    }

    Component {
        id: parameterDiffDialog

        ParameterDiffDialog {
            paramController: _controller
        }
    }

    Component {
        id: rcToParamDialog

        RCToParamDialog {
            tuningFact: _selectedFact
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 2
        spacing: ScreenTools.defaultFontPixelWidth

        QGCFlickable {
            id:                 groupScroll
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 12
            Layout.fillHeight:  true
            clip:               true
            pixelAligned:       true
            contentHeight:      groupedViewCategoryColumn.height
            flickableDirection: Flickable.VerticalFlick

            ColumnLayout {
                id:             groupedViewCategoryColumn
                anchors.left:   parent.left
                anchors.right:  parent.right
                spacing:        Math.ceil(ScreenTools.defaultFontPixelHeight * 0.25)

                QGCButton {
                    Layout.fillWidth:   true
                    text:               qsTr("ALL")
                    height:             _rowHeight
                    checked:            controller.currentGroup === null
                    autoExclusive:      true

                    onClicked: {
                        if (!checked) _rowWidth = 10
                        checked = true
                        controller.currentGroup = null
                    }
                }

                Repeater {
                    model: controller.allGroups

                    QGCButton {
                        Layout.fillWidth:   true
                        text:               object.name
                        height:             _rowHeight
                        checked:            object == controller.currentGroup
                        autoExclusive:      true

                        onClicked: {
                            if (!checked) _rowWidth = 10
                            checked = true
                            controller.currentGroup = object
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            RowLayout {
                id:             header
                Layout.fillWidth: true
                spacing:        ScreenTools.defaultFontPixelWidth

                QGCTextField {
                    id:                     searchText
                    Layout.fillWidth:       true
                    placeholderText:        qsTr("Search")
                    onDisplayTextChanged: controller.searchText = displayText
                }

                QGCButton {
                    text: qsTr("Clear")
                    onClicked: {
                        if(ScreenTools.isMobile) {
                            Qt.inputMethod.hide();
                        }
                        clearTimer.start()
                    }
                }

                QGCCheckBox {
                    text:       qsTr("Show modified only")
                    checked:    controller.showModifiedOnly
                    onClicked:  controller.showModifiedOnly = checked
                    visible:    QGroundControl.multiVehicleManager.activeVehicle.px4Firmware
                }

                QGCButton {
                    Layout.alignment:   Qt.AlignRight
                    text:               qsTr("Tools")
                    onClicked:          toolsMenu.popup()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: ScreenTools.defaultFontPixelWidth

                TableView {
                    id:                 tableView
                    Layout.fillWidth:   true
                    Layout.fillHeight:  true
                    Layout.leftMargin:  ScreenTools.defaultFontPixelWidth
                    columnSpacing:      ScreenTools.defaultFontPixelWidth
                    rowSpacing:         ScreenTools.defaultFontPixelHeight / 4
                    model:              controller.parameters
                    clip:               true

                    property real _nameColWidth: ScreenTools.defaultFontPixelWidth * 10
                    property var _colWidths: [_nameColWidth,
                                              ScreenTools.defaultFontPixelWidth * 10,
                                              ScreenTools.defaultFontPixelWidth * 18]
                    contentWidth:       _colWidths[0] + _colWidths[1] + _colWidths[2] + columnSpacing * 2

                    function _updateNameColWidth(newWidth) {
                        if (newWidth > _nameColWidth) {
                            _nameColWidth = newWidth
                        }
                    }

                    function _resetNameColWidth() {
                        _nameColWidth = ScreenTools.defaultFontPixelWidth * 10
                    }

                    onModelChanged: {
                        _resetNameColWidth()
                        positionViewAtRow(0, TableView.AlignLeft | TableView.AlignTop)
                        forceLayoutTimer.start()
                    }

                    Timer {
                        id:             forceLayoutTimer
                        interval:       500
                        repeat:         false
                        onTriggered:    {
                            _resetNameColWidth()
                            tableView.forceLayout()
                        }
                    }

                    onTopRowChanged: forceLayoutTimer.start()

                    delegate: Item {
                        id: delegateItem
                        implicitWidth:  column === 0 ? Math.max(nameTextMetrics.width + infoBtnSize + 4, tableView._nameColWidth) :
                                        tableView._colWidths[column]
                        implicitHeight: _rowHeight
                        clip:           true

                        property Fact fact: model.fact
                        property real infoBtnSize: ScreenTools.defaultFontPixelHeight * 0.75 + 2

                        TextMetrics {
                            id: nameTextMetrics
                            text: fact.name
                            font.pointSize: ScreenTools.defaultFontPointSize
                            font.family: ScreenTools.normalFontFamily
                        }

                        onImplicitWidthChanged: {
                            if (column === 0) tableView._updateNameColWidth(implicitWidth)
                        }

                        Loader {
                            id: cellLoader
                            anchors.fill: parent
                            anchors.margins: ScreenTools.defaultFontPixelHeight / 8
                            sourceComponent: {
                                if (column === 0) return nameComponent
                                if (column === 1) return rangeComponent
                                return valueComponent
                            }

                            property Fact delegateFact: delegateItem.fact
                            property int delegateColumn: column
                        }
                    }

                    Component {
                        id: nameComponent

                        RowLayout {
                            spacing: 2

                            QGCLabel {
                                Layout.fillWidth: true
                                text: delegateFact.name
                                verticalAlignment: Text.AlignVCenter
                            }

                            Rectangle {
                                Layout.preferredWidth:  ScreenTools.defaultFontPixelHeight * 0.75
                                Layout.preferredHeight: width
                                Layout.alignment:       Qt.AlignVCenter
                                radius:                 width / 2
                                color:                  infoMA.containsMouse ? qgcPal.buttonHighlight : qgcPal.button
                                border.color:           qgcPal.buttonBorder
                                border.width:           1

                                QGCLabel {
                                    anchors.centerIn: parent
                                    text: "!"
                                    font.bold: true
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    color: infoMA.containsMouse ? qgcPal.buttonHighlightText : qgcPal.buttonText
                                }

                                QGCMouseArea {
                                    id: infoMA
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: _selectedFact = delegateFact
                                }
                            }
                        }
                    }

                    Component {
                        id: rangeComponent

                        QGCLabel {
                            text: {
                                if (delegateFact.bitmaskStrings.length > 0) return qsTr("Bitmask")
                                if (delegateFact.enumStrings.length > 0) return qsTr("%1 options").arg(delegateFact.enumStrings.length)
                                if (!delegateFact.minIsDefaultForType || !delegateFact.maxIsDefaultForType)
                                    return delegateFact.minString + " ~ " + delegateFact.maxString
                                return "-"
                            }
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            color: qgcPal.text
                        }
                    }

                    Component {
                        id: valueComponent

                        Loader {
                            id: valueLoader
                            property Fact vFact: delegateFact
                            sourceComponent: {
                                if (vFact.bitmaskStrings.length > 0) return bitmaskValueComponent
                                if (vFact.enumStrings.length > 0) return enumValueComponent
                                return textValueComponent
                            }
                        }
                    }

                    Component {
                        id: textValueComponent

                        QGCTextField {
                            id: valueField
                            text: vFact.valueString
                            unitsLabel: vFact.units
                            showUnits: true
                            showHelp: false
                            numericValuesOnly: !vFact.typeIsString
                            verticalAlignment: Text.AlignVCenter

                            onEditingFinished: {
                                var errorString = vFact.validate(text, false)
                                if (errorString === "") {
                                    vFact.value = text
                                } else {
                                    text = vFact.valueString
                                }
                            }
                        }
                    }

                    Component {
                        id: enumValueComponent

                        QGCComboBox {
                            model: vFact.enumStrings
                            sizeToContents: true
                            property bool _indexModel: vFact ? vFact.enumValues.length === 0 : true
                            property int _enumIndex: vFact.enumIndex
                            on_EnumIndexChanged: {
                                Qt.callLater(function() { currentIndex = _enumIndex })
                            }
                            onModelChanged: {
                                Qt.callLater(function() { currentIndex = vFact.enumIndex })
                            }
                            Component.onCompleted: currentIndex = vFact.enumIndex
                            onActivated: (index) => {
                                if (_indexModel) {
                                    vFact.value = index
                                } else {
                                    vFact.value = vFact.enumValues[index]
                                }
                            }
                        }
                    }

                    Component {
                        id: bitmaskValueComponent

                        QGCBitmaskComboBox {
                            fact: vFact
                        }
                    }
                }

                Rectangle {
                    id: detailPanel
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 28
                    Layout.fillHeight: true
                    color: qgcPal.windowShade
                    visible: _selectedFact !== null
                    border.color: qgcPal.windowShadeLight
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.margins: ScreenTools.defaultFontPixelWidth
                            spacing: ScreenTools.defaultFontPixelWidth

                            QGCLabel {
                                Layout.fillWidth: true
                                text: _selectedFact ? _selectedFact.name : ""
                                font.bold: true
                                font.pointSize: ScreenTools.mediumFontPointSize
                            }

                            QGCButton {
                                Layout.preferredWidth: height
                                text: "X"
                                font.bold: true
                                onClicked: _selectedFact = null
                            }
                        }

                        QGCFlickable {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            contentWidth: detailContent.width
                            contentHeight: detailContent.height
                            flickableDirection: Flickable.VerticalFlick

                            ColumnLayout {
                                id: detailContent
                                width: detailPanel.width - ScreenTools.defaultFontPixelWidth * 2
                                spacing: ScreenTools.defaultFontPixelHeight / 2

                            QGCLabel {
                                Layout.fillWidth: true
                                text: _selectedFact ? _selectedFact.shortDescription : ""
                                wrapMode: Text.WordWrap
                                visible: _selectedFact && _selectedFact.shortDescription !== ""
                            }

                            QGCLabel {
                                Layout.fillWidth: true
                                text: _selectedFact ? _selectedFact.longDescription : ""
                                wrapMode: Text.WordWrap
                                visible: _selectedFact && _selectedFact.longDescription !== ""
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: qgcPal.windowShadeLight
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: ScreenTools.defaultFontPixelWidth * 2

                                QGCLabel {
                                    text: _selectedFact ? qsTr("Min: ") + _selectedFact.minString : ""
                                    visible: _selectedFact && !_selectedFact.minIsDefaultForType
                                }
                                QGCLabel {
                                    text: _selectedFact ? qsTr("Max: ") + _selectedFact.maxString : ""
                                    visible: _selectedFact && !_selectedFact.maxIsDefaultForType
                                }
                                QGCLabel {
                                    text: _selectedFact ? qsTr("Default: ") + _selectedFact.defaultValueString : ""
                                    visible: _selectedFact && _selectedFact.defaultValueAvailable
                                }
                            }

                            QGCLabel {
                                Layout.fillWidth: true
                                text: qsTr("Vehicle reboot required after change")
                                visible: _selectedFact && _selectedFact.vehicleRebootRequired
                                color: qgcPal.warningText
                            }

                            QGCLabel {
                                Layout.fillWidth: true
                                text: qsTr("Application restart required after change")
                                visible: _selectedFact && _selectedFact.qgcRebootRequired
                                color: qgcPal.warningText
                            }

                            QGCLabel {
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                text: qsTr("Warning: Modifying values while vehicle is in flight can lead to vehicle instability and possible vehicle loss.")
                                visible: _selectedFact && _selectedFact.componentId !== -1
                                color: qgcPal.warningText
                                font.pointSize: ScreenTools.smallFontPointSize
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: qgcPal.windowShadeLight
                            }

                            QGCButton {
                                text: qsTr("Reset To Default")
                                visible: _selectedFact && _selectedFact.defaultValueAvailable
                                onClicked: {
                                    if (_selectedFact) _selectedFact.value = _selectedFact.defaultValue
                                }
                            }

                            QGCButton {
                                text: qsTr("Set RC to Param")
                                visible: _selectedFact && _showRCToParam
                                onClicked: rcToParamDialog.createObject(mainWindow).open()
                            }

                            Item { Layout.fillHeight: true }
                            } // detailContent ColumnLayout
                        } // QGCFlickable
                    } // ColumnLayout
                } // detailPanel Rectangle
            }
        }
    }
}
