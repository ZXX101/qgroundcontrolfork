import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtPositioning

import QGroundControl
import QGroundControl.ScreenTools
import QGroundControl.Vehicle
import QGroundControl.Controls
import QGroundControl.FactControls
import QGroundControl.Palette

//显示类组件 - 简单航点编辑器
//编辑简单任务项目的详细参数，包括：
//  1. 命令描述 - 显示当前命令的描述信息
//  2. 高度设置 - 设置航点高度和高度模式（相对/绝对/地形）
//  3. 参数字段 - 显示命令的参数输入框（下拉框、文本框、复选框）
//  4. 速度设置 - 可选的飞行速度设置
//  5. 相机设置 - 相机触发相关参数
Rectangle {
    id:     _root
    width:  availableWidth
    height: editorColumn.height + (_margin * 2)
    color:  xfDarkBackgroundEnabled ? "#101010" : qgcPal.windowShadeDark
    radius: _radius

    property bool _specifiesAltitude:       missionItem.specifiesAltitude
    property real _margin:                  ScreenTools.defaultFontPixelHeight / 2
    property real _altRectMargin:           ScreenTools.defaultFontPixelWidth / 2
    property var  _controllerVehicle:       missionItem.masterController.controllerVehicle
    property int  _globalAltMode:           missionItem.masterController.missionController.globalAltitudeMode
    property bool _globalAltModeIsMixed:    _globalAltMode == QGroundControl.AltitudeModeMixed
    property real _radius:                  ScreenTools.defaultFontPixelWidth / 2
    property bool xfFieldOutlineEnabled:    false
    property bool xfCoordinateFieldsEnabled: false
    property bool xfDarkBackgroundEnabled: false
    readonly property color _xfFieldOutlineColor: "#2A2A2A"
    readonly property int _mavCmdNavWaypoint: 16
    property real _effectiveFlightSpeed: {
        // 向前查找速度设置指令，得到本航点实际使用的速度
        var controller = missionItem.masterController.missionController
        if (!controller) {
            return NaN
        }
        var revision = controller.speedProfileRevision // 建立绑定依赖，速度变化时重新计算
        return controller.effectiveFlightSpeed(missionItem)
    }

    function updateAltitudeModeText() {
        if (missionItem.altitudeMode === QGroundControl.AltitudeModeRelative) {
            altModeLabel.text = QGroundControl.altitudeModeShortDescription(QGroundControl.AltitudeModeRelative)
        } else if (missionItem.altitudeMode === QGroundControl.AltitudeModeAbsolute) {
            altModeLabel.text = QGroundControl.altitudeModeShortDescription(QGroundControl.AltitudeModeAbsolute)
        } else if (missionItem.altitudeMode === QGroundControl.AltitudeModeCalcAboveTerrain) {
            altModeLabel.text = QGroundControl.altitudeModeShortDescription(QGroundControl.AltitudeModeCalcAboveTerrain)
        } else if (missionItem.altitudeMode === QGroundControl.AltitudeModeTerrainFrame) {
            altModeLabel.text = QGroundControl.altitudeModeShortDescription(QGroundControl.AltitudeModeTerrainFrame)
        } else {
            altModeLabel.text = qsTr("Internal Error")
        }
    }

    Component.onCompleted: updateAltitudeModeText()

    Connections {
        target:                 missionItem
        onAltitudeModeChanged:  updateAltitudeModeText()
    }

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }
    Component { id: altModeDialogComponent; AltModeDialog { } }

    Column {
        id:                 editorColumn
        anchors.margins:    _margin
        anchors.left:       parent.left
        anchors.right:      parent.right
        anchors.top:        parent.top
        spacing:            _margin

        QGCLabel {
            width:          parent.width
            wrapMode:       Text.WordWrap
            // font.pointSize: ScreenTools.smallFontPointSize
            text:           missionItem.rawEdit ?
                                qsTr("Provides advanced access to all commands/parameters. Be very careful!") :
                                missionItem.commandDescription
        }

        GridLayout {
            anchors.left:   parent.left
            anchors.right:  parent.right
            columns:        2
            visible:        _root.xfCoordinateFieldsEnabled && missionItem.command === _root._mavCmdNavWaypoint

            QGCLabel {
                text: qsTr("Longitude")
            }

            QGCTextField {
                Layout.fillWidth:       true
                horizontalAlignment:    Text.AlignRight
                numericValuesOnly:      true
                text: missionItem.coordinate && !isNaN(missionItem.coordinate.longitude) ? missionItem.coordinate.longitude.toFixed(7) : "0"
                showBorder: _root.xfFieldOutlineEnabled || qgcPal.globalTheme === QGCPalette.Light
                borderColor: _root.xfFieldOutlineEnabled ? _root._xfFieldOutlineColor : qgcPal.buttonBorder

                onEditingFinished: {
                    const value = parseFloat(text)
                    if (!isNaN(value) && missionItem.coordinate) {
                        const coordinate = missionItem.coordinate
                        missionItem.coordinate = QtPositioning.coordinate(
                            isNaN(coordinate.latitude) ? 0 : coordinate.latitude,
                            value,
                            isNaN(coordinate.altitude) ? 0 : coordinate.altitude)
                    }
                }
            }

            QGCLabel {
                text: qsTr("Latitude")
            }

            QGCTextField {
                Layout.fillWidth:       true
                horizontalAlignment:    Text.AlignRight
                numericValuesOnly:      true
                text: missionItem.coordinate && !isNaN(missionItem.coordinate.latitude) ? missionItem.coordinate.latitude.toFixed(7) : "0"
                showBorder: _root.xfFieldOutlineEnabled || qgcPal.globalTheme === QGCPalette.Light
                borderColor: _root.xfFieldOutlineEnabled ? _root._xfFieldOutlineColor : qgcPal.buttonBorder

                onEditingFinished: {
                    const value = parseFloat(text)
                    if (!isNaN(value) && missionItem.coordinate) {
                        const coordinate = missionItem.coordinate
                        missionItem.coordinate = QtPositioning.coordinate(
                            value,
                            isNaN(coordinate.longitude) ? 0 : coordinate.longitude,
                            isNaN(coordinate.altitude) ? 0 : coordinate.altitude)
                    }
                }
            }
        }

        ColumnLayout {
            anchors.left:       parent.left
            anchors.right:      parent.right
            spacing:            _margin
            visible:            missionItem.isTakeoffItem && missionItem.wizardMode // Hack special case for takeoff item

            QGCLabel {
                text:               qsTr("Move '%1' %2 to the %3 location. %4")
                .arg(_controllerVehicle.vtol ? qsTr("T") : qsTr("T"))
                .arg(_controllerVehicle.vtol ? qsTr("Transition Direction") : qsTr("Takeoff"))
                .arg(_controllerVehicle.vtol ? qsTr("desired") : qsTr("climbout"))
                .arg(_controllerVehicle.vtol ? (qsTr("Ensure distance from launch to transition direction is far enough to complete transition.")) : "")
                Layout.fillWidth:   true
                wrapMode:           Text.WordWrap
                visible:            !initialClickLabel.visible
            }

            QGCLabel {
                text:               qsTr("Ensure clear of obstacles and into the wind.")
                Layout.fillWidth:   true
                wrapMode:           Text.WordWrap
                visible:            !initialClickLabel.visible
            }

            QGCButton {
                text:               qsTr("Done")
                Layout.fillWidth:   true
                visible:            !initialClickLabel.visible
                onClicked: {
                    missionItem.wizardMode = false
                }
            }

            QGCLabel {
                id:                 initialClickLabel
                text:               missionItem.launchTakeoffAtSameLocation ?
                                        qsTr("Click in map to set planned Takeoff location.") :
                                        qsTr("Click in map to set planned Launch location.")
                Layout.fillWidth:   true
                wrapMode:           Text.WordWrap
                visible:            missionItem.isTakeoffItem && !missionItem.launchCoordinate.isValid
            }
        }

        Column {
            anchors.left:       parent.left
            anchors.right:      parent.right
            spacing:            _altRectMargin
            visible:            !missionItem.wizardMode

            ColumnLayout {
                anchors.left:   parent.left
                anchors.right:  parent.right
                spacing:        0
                visible:        _specifiesAltitude

                QGCLabel {
                    Layout.fillWidth:   true
                    wrapMode:           Text.WordWrap
                    // font.pointSize:     ScreenTools.smallFontPointSize
                    text:               qsTr("Altitude below specifies the approximate altitude of the ground. Normally 0 for landing back at original launch location.")
                    visible:            missionItem.isLandCommand
                }

                MouseArea {
                    Layout.preferredWidth:  childrenRect.width
                    Layout.preferredHeight: childrenRect.height

                    onClicked: {
                        if (_globalAltModeIsMixed) {
                            var removeModes = []
                            var updateFunction = function(altMode){ missionItem.altitudeMode = altMode }
                            if (!_controllerVehicle.supportsTerrainFrame) {
                                removeModes.push(QGroundControl.AltitudeModeTerrainFrame)
                            }
                            if (!QGroundControl.corePlugin.options.showMissionAbsoluteAltitude && missionItem.altitudeMode !== QGroundControl.AltitudeModeAbsolute) {
                                removeModes.push(QGroundControl.AltitudeModeAbsolute)
                            }
                            removeModes.push(QGroundControl.AltitudeModeMixed)
                            altModeDialogComponent.createObject(mainWindow, { rgRemoveModes: removeModes, updateAltModeFn: updateFunction }).open()
                        }
                    }

                    RowLayout {
                        spacing: _altRectMargin

                        QGCLabel {
                            Layout.alignment:   Qt.AlignBaseline
                            text:               qsTr("Altitude")
                            // font.pointSize:     ScreenTools.smallFontPointSize
                        }
                        QGCLabel {
                            id:                 altModeLabel
                            Layout.alignment:   Qt.AlignBaseline
                            visible:            _globalAltMode !== QGroundControl.AltitudeModeRelative
                        }
                        QGCColoredImage {
                            height:     ScreenTools.defaultFontPixelHeight / 2
                            width:      height
                            source:     "/res/DropArrow.svg"
                            color:      qgcPal.text
                            visible:    _globalAltModeIsMixed
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth:   true
                    spacing:            _altRectMargin

                    QGCButton {
                        text:                   "-10"
                        _horizontalPadding:     0
                        Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 5
                        onClicked:              missionItem.altitude.rawValue = Math.max(0, missionItem.altitude.rawValue - 10)
                    }

                    QGCButton {
                        text:                   "+10"
                        _horizontalPadding:     0
                        Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 5
                        onClicked:              missionItem.altitude.rawValue = missionItem.altitude.rawValue + 10
                    }

                    FactTextField {
                        id:                 altField
                        Layout.fillWidth:   true
                        fact:               missionItem.altitude
                        showBorder:         _root.xfFieldOutlineEnabled || qgcPal.globalTheme === QGCPalette.Light
                        borderColor:        _root.xfFieldOutlineEnabled ? _root._xfFieldOutlineColor : qgcPal.buttonBorder
                    }
                }

                QGCLabel {
                    // font.pointSize:     ScreenTools.smallFontPointSize
                    text:               qsTr("Actual AMSL alt sent: %1 %2").arg(missionItem.amslAltAboveTerrain.valueString).arg(missionItem.amslAltAboveTerrain.units)
                    visible:            missionItem.altitudeMode === QGroundControl.AltitudeModeCalcAboveTerrain
                }
            }

            ColumnLayout {
                anchors.left:   parent.left
                anchors.right:  parent.right
                spacing:        _margin

                Repeater {
                    model: missionItem.comboboxFacts

                    ColumnLayout {
                        Layout.fillWidth:   true
                        spacing:            0

                        QGCLabel {
                            // font.pointSize: ScreenTools.smallFontPointSize
                            text:           object.name
                            visible:        object.name !== ""
                        }

                        FactComboBox {
                            Layout.fillWidth:   true
                            indexModel:         false
                            model:              object.enumStrings
                            fact:               object
                            showBorder:         _root.xfFieldOutlineEnabled || qgcPal.globalTheme === QGCPalette.Light
                            borderColor:        _root.xfFieldOutlineEnabled ? _root._xfFieldOutlineColor : qgcPal.buttonBorder
                            popupBorderColor:   _root.xfFieldOutlineEnabled ? _root._xfFieldOutlineColor : qgcPal.text
                        }
                    }
                }
            }

            GridLayout {
                anchors.left:   parent.left
                anchors.right:  parent.right
                flow:           GridLayout.TopToBottom
                rows:           missionItem.textFieldFacts.count +
                                missionItem.nanFacts.count +
                                (missionItem.speedSection.available ? 1 : 0)
                columns:        2

                Repeater {
                    model: missionItem.textFieldFacts

                    QGCLabel { text: object.name }
                }

                Repeater {
                    model: missionItem.nanFacts

                    QGCCheckBox {
                        text:           object.name
                        checked:        !isNaN(object.rawValue)
                        onClicked:      object.rawValue = checked ? 0 : NaN
                        indicatorBorderColor: _root.xfFieldOutlineEnabled ? _root._xfFieldOutlineColor : qgcPal.text
                    }
                }

                QGCCheckBox {
                    id:         flightSpeedCheckbox
                    text:       qsTr("Flight Speed")
                    checked:    missionItem.speedSection.specifyFlightSpeed
                    onClicked:  missionItem.speedSection.specifyFlightSpeed = checked
                    visible:    missionItem.speedSection.available
                    indicatorBorderColor: _root.xfFieldOutlineEnabled ? _root._xfFieldOutlineColor : qgcPal.text
                }


                Repeater {
                    model: missionItem.textFieldFacts

                    FactTextField {
                        showUnits:          true
                        fact:               object
                        Layout.fillWidth:   true
                        enabled:            !object.readOnly
                        showBorder:         _root.xfFieldOutlineEnabled || qgcPal.globalTheme === QGCPalette.Light
                        borderColor:        _root.xfFieldOutlineEnabled ? _root._xfFieldOutlineColor : qgcPal.buttonBorder
                    }
                }

                Repeater {
                    model: missionItem.nanFacts

                    FactTextField {
                        showUnits:          true
                        fact:               object
                        Layout.fillWidth:   true
                        enabled:            !isNaN(object.rawValue)
                        showBorder:         _root.xfFieldOutlineEnabled || qgcPal.globalTheme === QGCPalette.Light
                        borderColor:        _root.xfFieldOutlineEnabled ? _root._xfFieldOutlineColor : qgcPal.buttonBorder
                    }
                }

                RowLayout {
                    Layout.fillWidth:   true
                    spacing:            _altRectMargin
                    visible:            missionItem.speedSection.available

                    QGCButton {
                        text:                   "-1"
                        _horizontalPadding:     0
                        Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 5
                        enabled:                flightSpeedCheckbox.checked
                        onClicked:              missionItem.speedSection.flightSpeed.rawValue = Math.max(0.1, missionItem.speedSection.flightSpeed.rawValue - 1)
                    }

                    QGCButton {
                        text:                   "+1"
                        _horizontalPadding:     0
                        Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 5
                        enabled:                flightSpeedCheckbox.checked
                        onClicked:              missionItem.speedSection.flightSpeed.rawValue = missionItem.speedSection.flightSpeed.rawValue + 1
                    }

                    FactTextField {
                        fact:               missionItem.speedSection.flightSpeed
                        Layout.fillWidth:   true
                        enabled:            flightSpeedCheckbox.checked
                        visible:            flightSpeedCheckbox.checked
                        showBorder:         _root.xfFieldOutlineEnabled || qgcPal.globalTheme === QGCPalette.Light
                        borderColor:        _root.xfFieldOutlineEnabled ? _root._xfFieldOutlineColor : qgcPal.buttonBorder
                    }

                    QGCTextField {
                        Layout.fillWidth:   true
                        visible:            !flightSpeedCheckbox.checked
                        readOnly:           true
                        horizontalAlignment: Text.AlignRight
                        text:               !isNaN(_effectiveFlightSpeed) && _effectiveFlightSpeed > 0 ? Number(_effectiveFlightSpeed).toFixed(1) : "--"
                        showBorder:         _root.xfFieldOutlineEnabled || qgcPal.globalTheme === QGCPalette.Light
                        borderColor:        _root.xfFieldOutlineEnabled ? _root._xfFieldOutlineColor : qgcPal.buttonBorder
                    }
                }
            }

            CameraSection {
                checked:    xfWaypointLayoutEnabled || missionItem.cameraSection.settingsSpecified
                visible:    missionItem.cameraSection.available
                xfFieldOutlineEnabled: _root.xfFieldOutlineEnabled
                xfFieldOutlineColor:   _root._xfFieldOutlineColor
                xfWaypointLayoutEnabled: _root.xfCoordinateFieldsEnabled && missionItem.command === _root._mavCmdNavWaypoint
            }
        }
    }
}
