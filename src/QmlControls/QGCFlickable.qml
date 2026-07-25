import QtQuick
import QtQuick.Controls

import QGroundControl.Palette
import QGroundControl.ScreenTools

/// QGC version of Flickable control that shows horizontal/vertial scroll indicators
Flickable {
    id:                     root
    boundsBehavior:         Flickable.StopAtBounds
    clip:                   true
    maximumFlickVelocity:   (ScreenTools.realPixelDensity * 25.4) * 8

    property color indicatorColor: qgcPal.text
}
