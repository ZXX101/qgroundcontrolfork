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
import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.Controls
import QGroundControl.ScreenTools

ColumnLayout {
    Layout.fillWidth: true
    Layout.margins: ScreenTools.defaultFontPixelHeight / 2
    property var    _settingsManager:            QGroundControl.settingsManager
    property var    _videoManager:              QGroundControl.videoManager
    property var    _videoSettings:             _settingsManager.videoSettings
    property string _videoSource:               _videoSettings.videoSource.rawValue
    property bool   _isRTSP:                    _videoManager.isStreamSource && (_videoSource === _videoSettings.rtspVideoSource)
    property bool   _videoAutoStreamConfig:     _videoManager.autoStreamConfigured
    property bool   _videoSourceDisabled:       _videoSource === _videoSettings.disabledVideoSource

    LabelledFactComboBox {
        Layout.fillWidth:   true
        label:              qsTr("Video Source")
        indexModel:         false
        fact:               _videoSettings.videoSource
        visible:            fact.visible
        enabled:            !_videoAutoStreamConfig
    }

    RowLayout {
        Layout.fillWidth:   true
        visible:            _isRTSP && _videoSettings.rtspUrl.visible
        enabled:            !_videoAutoStreamConfig
        spacing:            ScreenTools.defaultFontPixelWidth * 2

        QGCLabel {
            text:               qsTr("RTSP URL")
            Layout.fillWidth:   true
        }

        FactTextField {
            id:                 rtspUrlField
            Layout.fillWidth:   true
            fact:               _videoSettings.rtspUrl
        }
    }

    LabelledFactTextField {
        Layout.fillWidth:   true
        label:              qsTr("Aspect Ratio")
        fact:               _videoSettings.aspectRatio
        visible:            !_videoSourceDisabled && !_videoAutoStreamConfig && _videoManager.isStreamSource && _videoSettings.aspectRatio.visible
    }

    LabelledFactComboBox {
        Layout.fillWidth:   true
        label:              qsTr("Video Decode Priority")
        fact:               _videoSettings.forceVideoDecoder
        visible:            !_videoSourceDisabled && fact.visible
        indexModel:         false
    }
}
