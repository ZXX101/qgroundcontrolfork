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

ColumnLayout {
    anchors.fill: parent
    QGCPalette { id: qgcPal }

    QGCListView {
        id:                 missionListView
        Layout.fillWidth:   true
        Layout.fillHeight:  true
        spacing:            ScreenTools.defaultFontPixelHeight / 4
        orientation:        ListView.Vertical
        model:              missionController ? missionController.visualItems : null
        cacheBuffer:        Math.max(height * 2, 0)
        clip:               true

        delegate: XFMissionWaypointCard {
            missionItem:    object
            width:          missionListView.width
            onClicked: (sequenceNumber) => {
                if (missionController) {
                    missionController.setCurrentPlanViewSeqNum(sequenceNumber, false)
                }
            }
            onRemove: {
                if (missionController) {
                    var removeIndex = index
                    missionController.removeVisualItem(removeIndex)
                    if (removeIndex >= missionController.visualItems.count) {
                        removeIndex--
                    }
                }
            }
        }
    }
}