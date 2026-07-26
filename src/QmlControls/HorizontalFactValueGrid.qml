/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQml

import QGroundControl.Templates as T
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Controllers
import QGroundControl.Palette
import QGroundControl.FlightMap
import QGroundControl

T.HorizontalFactValueGrid {
    id:                     _root
    Layout.preferredWidth:  topLayout.width
    Layout.preferredHeight: topLayout.height

    property bool   settingsUnlocked:       false
    property bool   showValueUnits:         true
    property string valueFontFamily:        ScreenTools.normalFontFamily
    property real   valueWidth:             0

    property real   _margins:               ScreenTools.defaultFontPixelWidth / 2
    property int    _rowMax:                2
    property real   _rowButtonWidth:        ScreenTools.minTouchPixels
    property real   _rowButtonHeight:       ScreenTools.minTouchPixels / 2
    property real   _editButtonSpacing:     2

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    ColumnLayout {
        id:         topLayout
        spacing:    ScreenTools.defaultFontPixelWidth

        RowLayout {
            spacing: parent.spacing
            RowLayout {
                id:         labelValueColumnLayout
                spacing:    ScreenTools.defaultFontPixelWidth * 0

                Repeater {
                    model: _root.columns

                    // 每列使用 GridLayout，保持两行布局
                    GridLayout {
                        rows:           object.count
                        columns:        1
                        rowSpacing:     ScreenTools.defaultFontPixelHeight * 0.25
                        columnSpacing:  0
                        flow:           GridLayout.TopToBottom

                        Repeater {
                            model: object

                            // 每个数据项：数值在上，标签在下
                            ColumnLayout {
                                spacing: 0
                                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                                InstrumentValueValue {
                                    Layout.alignment:       Qt.AlignHCenter
                                    instrumentValueData:    object
                                    showUnits:               _root.showValueUnits
                                    valueFontFamily:         _root.valueFontFamily
                                    valueWidth:              _root.valueWidth
                                }

                                InstrumentValueLabel {
                                    Layout.alignment:       Qt.AlignHCenter
                                    instrumentValueData:    object
                                }
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                spacing: 1
                visible: settingsUnlocked

                QGCButton {
                    Layout.preferredWidth:  ScreenTools.minTouchPixels
                    Layout.fillHeight:      true
                    topPadding:             0
                    bottomPadding:          0
                    leftPadding:            0
                    rightPadding:           0
                    text:                   qsTr("+")
                    enabled:                (_root.width + (2 * (_rowButtonWidth + _margins))) < screen.width
                    onClicked:              appendColumn()
                }

                QGCButton {
                    Layout.preferredWidth:  ScreenTools.minTouchPixels
                    Layout.fillHeight:      true
                    topPadding:             0
                    bottomPadding:          0
                    leftPadding:            0
                    rightPadding:           0
                    text:                   qsTr("-")
                    enabled:                _root.columns.count > 1
                    onClicked:              deleteLastColumn()
                }
            }
        }

        RowLayout {
            Layout.fillWidth:   true
            spacing:            1
            visible:            settingsUnlocked

            QGCButton {
                Layout.fillWidth:       true
                Layout.preferredHeight: ScreenTools.minTouchPixels
                topPadding:             0
                bottomPadding:          0
                leftPadding:            0
                rightPadding:           0
                text:                   qsTr("+")
                enabled:                (_root.height + (2 * (_rowButtonHeight + _margins))) < (screen.height - ScreenTools.toolbarHeight)
                onClicked:              appendRow()
            }

            QGCButton {
                Layout.fillWidth:       true
                Layout.preferredHeight: parent.height
                topPadding:             0
                bottomPadding:          0
                leftPadding:            0
                rightPadding:           0
                text:                   qsTr("-")
                enabled:                _root.rowCount > 1
                onClicked:              deleteLastRow()
            }
        }
    }

    QGCMouseArea {
        x:          labelValueColumnLayout.x
        y:          labelValueColumnLayout.y
        width:      labelValueColumnLayout.width
        height:     labelValueColumnLayout.height
        visible:    settingsUnlocked
        cursorShape:Qt.PointingHandCursor

        property var mappedLabelValueColumnLayoutPosition: _root.mapFromItem(labelValueColumnLayout, labelValueColumnLayout.x, labelValueColumnLayout.y)

        onClicked: (mouse) => {
            var columnGridLayoutItem = labelValueColumnLayout.childAt(mouse.x, mouse.y)
            var mappedMouse = labelValueColumnLayout.mapToItem(columnGridLayoutItem, mouse.x, mouse.y)
            var dataColumnItem = columnGridLayoutItem.childAt(mappedMouse.x, mappedMouse.y)
            if (dataColumnItem && dataColumnItem.children.length > 0) {
                var valueOrLabelItem = dataColumnItem.childAt(dataColumnItem.width / 2, mappedMouse.y - dataColumnItem.y)
                if (valueOrLabelItem && valueOrLabelItem.instrumentValueData !== undefined) {
                    valueEditDialog.createObject(mainWindow, { instrumentValueData: valueOrLabelItem.instrumentValueData }).open()
                }
            }
        }
    }

    Component {
        id: valueEditDialog

        InstrumentValueEditDialog { }
    }
}
