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
    Rectangle {
        anchors.fill: parent
        color: "#101010"
        z: -1
    }

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
        currentIndex:       missionController ? missionController.currentPlanViewSeqNum : -1
        highlightMoveDuration: 250

        delegate: Loader {
            sourceComponent: object.sequenceNumber === 0 ? nullComponent : waypointCardComponent
            width: missionListView.width - (ScreenTools.defaultFontPixelWidth)
            asynchronous: false

            Component {
                id: nullComponent
                Item { width: 0; height: 0 }
            }

            Component {
                id: waypointCardComponent
                XFMissionWaypointCard {
                    missionItem:    object
                    onClicked: (sequenceNumber) => {
                        if (missionController) {
                            missionController.setCurrentPlanViewSeqNum(sequenceNumber, false)
                        }
                    }
                    onRemove: {
                        if (missionController) {
                            var actualIndex = -1
                            for (var i = 0; i < missionController.visualItems.count; i++) {
                                if (missionController.visualItems.get(i) === missionItem) {
                                    actualIndex = i
                                    break
                                }
                            }
                            if (actualIndex > 0) {
                                missionController.removeVisualItem(actualIndex)
                            }
                        }
                    }
                }
            }
        }
    }
}
