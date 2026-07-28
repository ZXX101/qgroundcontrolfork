import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.ScreenTools
import QGroundControl.Controls
import QGroundControl.FactControls
import QGroundControl.Palette

// Camera section for mission item editors
Column {
    anchors.left:   parent.left
    anchors.right:  parent.right
    spacing:        _margin

    property alias buttonGroup:  cameraSectionHeader.buttonGroup
    property alias showSpacer:      cameraSectionHeader.showSpacer
    property alias checked:         cameraSectionHeader.checked

    property var    _camera:        missionItem.cameraSection
    property real   _fieldWidth:    ScreenTools.defaultFontPixelWidth * 16
    property real   _margin:        ScreenTools.defaultFontPixelWidth / 2
    property bool   xfFieldOutlineEnabled: false
    property color  xfFieldOutlineColor:   "#2A2A2A"
    property bool   xfWaypointLayoutEnabled: false

    QGCPalette {
        id: qgcPal
        colorGroupEnabled: enabled
    }

    SectionHeader {
        id:             cameraSectionHeader
        anchors.left:   parent.left
        anchors.right:  parent.right
        text:           qsTr("Camera")
        checked:        false
    }

    Column {
        anchors.left:   parent.left
        anchors.right:  parent.right
        spacing:        _margin
        visible:        cameraSectionHeader.checked

        FactComboBox {
            id:             cameraActionCombo
            anchors.left:   parent.left
            anchors.right:  parent.right
            fact:           _camera.cameraAction
            indexModel:     false
            showBorder:     xfFieldOutlineEnabled || qgcPal.globalTheme === QGCPalette.Light
            borderColor:    xfFieldOutlineEnabled ? xfFieldOutlineColor : qgcPal.buttonBorder
            popupBorderColor: xfFieldOutlineEnabled ? xfFieldOutlineColor : qgcPal.text
        }

        ColumnLayout {
            anchors.left:   parent.left
            anchors.right:  parent.right
            spacing:        _margin
            visible:        xfWaypointLayoutEnabled

            RowLayout {
                Layout.fillWidth: true

                QGCLabel {
                    text: qsTr("Gimbal")
                }

                Item {
                    Layout.fillWidth: true
                }

                QGCCheckBox {
                    id: xfGimbalCheckBox
                    checked: _camera.specifyGimbal
                    onClicked: _camera.specifyGimbal = checked
                    indicatorBorderColor: xfFieldOutlineEnabled ? xfFieldOutlineColor : qgcPal.text
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: xfGimbalCheckBox.checked

                QGCLabel {
                    text: qsTr("Pitch")
                }

                Item {
                    Layout.fillWidth: true
                }

                QGCButton {
                    text: "-10"
                    _horizontalPadding: 0
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
                    enabled: xfGimbalCheckBox.checked

                    onClicked: {
                        const currentValue = Number(_camera.gimbalPitch.rawValue)
                        _camera.gimbalPitch.rawValue = Math.max(-90, (isNaN(currentValue) ? 0 : currentValue) - 10)
                    }
                }

                QGCButton {
                    text: "+10"
                    _horizontalPadding: 0
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
                    enabled: xfGimbalCheckBox.checked

                    onClicked: {
                        const currentValue = Number(_camera.gimbalPitch.rawValue)
                        _camera.gimbalPitch.rawValue = Math.min(0, (isNaN(currentValue) ? 0 : currentValue) + 10)
                    }
                }

                QGCTextField {
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                    enabled: xfGimbalCheckBox.checked
                    horizontalAlignment: Text.AlignRight
                    numericValuesOnly: true
                    text: {
                        const rawValue = Number(_camera.gimbalPitch.rawValue)
                        return isNaN(rawValue) ? "0" : rawValue.toFixed(0)
                    }
                    showBorder: xfFieldOutlineEnabled || qgcPal.globalTheme === QGCPalette.Light
                    borderColor: xfFieldOutlineEnabled ? xfFieldOutlineColor : qgcPal.buttonBorder

                    onEditingFinished: {
                        const rawText = text.trim()
                        const rawValue = Number(rawText)
                        if (rawText.length > 0 && !isNaN(rawValue) && rawValue >= -90 && rawValue <= 0) {
                            clearValidationError()
                            _camera.gimbalPitch.rawValue = rawValue
                        } else {
                            const previousValue = Number(_camera.gimbalPitch.rawValue)
                            showValidationError(qsTr("Value must be between -90 and 0."), isNaN(previousValue) ? "0" : previousValue.toFixed(0))
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: xfGimbalCheckBox.checked

                QGCLabel {
                    text: qsTr("Yaw")
                }

                Item {
                    Layout.fillWidth: true
                }

                QGCButton {
                    text: "-10"
                    _horizontalPadding: 0
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
                    enabled: xfGimbalCheckBox.checked

                    onClicked: {
                        const currentValue = Number(_camera.gimbalYaw.rawValue)
                        _camera.gimbalYaw.rawValue = Math.max(-180, (isNaN(currentValue) ? 0 : currentValue) - 10)
                    }
                }

                QGCButton {
                    text: "+10"
                    _horizontalPadding: 0
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 5
                    enabled: xfGimbalCheckBox.checked

                    onClicked: {
                        const currentValue = Number(_camera.gimbalYaw.rawValue)
                        _camera.gimbalYaw.rawValue = Math.min(180, (isNaN(currentValue) ? 0 : currentValue) + 10)
                    }
                }

                FactTextField {
                    fact: _camera.gimbalYaw
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                    enabled: xfGimbalCheckBox.checked
                    showBorder: xfFieldOutlineEnabled || qgcPal.globalTheme === QGCPalette.Light
                    borderColor: xfFieldOutlineEnabled ? xfFieldOutlineColor : qgcPal.buttonBorder
                }
            }
        }

        RowLayout {
            anchors.left:   parent.left
            anchors.right:  parent.right
            spacing:        ScreenTools.defaultFontPixelWidth
            visible:        _camera.cameraAction.rawValue === 1

            QGCLabel {
                text:               qsTr("Time")
                Layout.fillWidth:   true
            }
            FactTextField {
                fact:                   _camera.cameraPhotoIntervalTime
                Layout.preferredWidth:  _fieldWidth
                showBorder:             xfFieldOutlineEnabled || qgcPal.globalTheme === QGCPalette.Light
                borderColor:            xfFieldOutlineEnabled ? xfFieldOutlineColor : qgcPal.buttonBorder
            }
        }

        RowLayout {
            anchors.left:   parent.left
            anchors.right:  parent.right
            spacing:        ScreenTools.defaultFontPixelWidth
            visible:        _camera.cameraAction.rawValue === 2

            QGCLabel {
                text:               qsTr("Distance")
                Layout.fillWidth:   true
            }
            FactTextField {
                fact:                   _camera.cameraPhotoIntervalDistance
                Layout.preferredWidth:  _fieldWidth
                showBorder:             xfFieldOutlineEnabled || qgcPal.globalTheme === QGCPalette.Light
                borderColor:            xfFieldOutlineEnabled ? xfFieldOutlineColor : qgcPal.buttonBorder
            }
        }

        RowLayout {
            anchors.left:   parent.left
            anchors.right:  parent.right
            spacing:        ScreenTools.defaultFontPixelWidth
            visible:        _camera.cameraModeSupported

            QGCCheckBox {
                id:                 modeCheckBox
                text:               qsTr("Mode")
                checked:            _camera.specifyCameraMode
                onClicked:          _camera.specifyCameraMode = checked
                indicatorBorderColor: xfFieldOutlineEnabled ? xfFieldOutlineColor : qgcPal.text
            }
            FactComboBox {
                fact:               _camera.cameraMode
                indexModel:         false
                enabled:            modeCheckBox.checked
                Layout.fillWidth:   true
                showBorder:         xfFieldOutlineEnabled || qgcPal.globalTheme === QGCPalette.Light
                borderColor:        xfFieldOutlineEnabled ? xfFieldOutlineColor : qgcPal.buttonBorder
                popupBorderColor:   xfFieldOutlineEnabled ? xfFieldOutlineColor : qgcPal.text
            }
        }

        GridLayout {
            anchors.left:   parent.left
            anchors.right:  parent.right
            columnSpacing:  ScreenTools.defaultFontPixelWidth / 2
            rowSpacing:     0
            columns:        3
            visible:        !xfWaypointLayoutEnabled

            QGCLabel { text: qsTr("Gimbal") }
            QGCLabel { text: qsTr("Pitch") }
            QGCLabel { text: qsTr("Yaw") }

            QGCCheckBox {
                id:                 gimbalCheckBox
                checked:            _camera.specifyGimbal
                onClicked:          _camera.specifyGimbal = checked
                Layout.fillWidth:   true
                indicatorBorderColor: xfFieldOutlineEnabled ? xfFieldOutlineColor : qgcPal.text
            }
            FactTextField {
                fact:           _camera.gimbalPitch
                implicitWidth:  ScreenTools.defaultFontPixelWidth * 9
                enabled:        gimbalCheckBox.checked
                showBorder:     xfFieldOutlineEnabled || qgcPal.globalTheme === QGCPalette.Light
                borderColor:    xfFieldOutlineEnabled ? xfFieldOutlineColor : qgcPal.buttonBorder
            }

            FactTextField {
                fact:           _camera.gimbalYaw
                implicitWidth:  ScreenTools.defaultFontPixelWidth * 9
                enabled:        gimbalCheckBox.checked
                showBorder:     xfFieldOutlineEnabled || qgcPal.globalTheme === QGCPalette.Light
                borderColor:    xfFieldOutlineEnabled ? xfFieldOutlineColor : qgcPal.buttonBorder
            }
        }
    }
}
