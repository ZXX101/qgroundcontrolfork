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

import QGroundControl
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Palette

//遥控器链路信号质量详情面板(云卓RCSDK),5行2列显示两端SNR/功率/MCS
ToolIndicatorPage {

    property string valueNA: qsTr("--", "No data to display")

    function _formatValue(value) { return value >= 0 ? value : valueNA }

    contentComponent: Component {
        ColumnLayout {
            spacing: ScreenTools.defaultFontPixelHeight / 2

            SettingsGroupLayout {
                heading: qsTr("链路信号质量:%1%").arg(RCSignalQuality.signalQuality)

                LabelledLabel {
                    label:      qsTr("地面端信噪比")
                    labelText:  _formatValue(RCSignalQuality.groundSnr)
                }

                LabelledLabel {
                    label:      qsTr("地面端功率")
                    labelText:  _formatValue(RCSignalQuality.groundPower)
                }

                LabelledLabel {
                    label:      qsTr("天空端信噪比")
                    labelText:  _formatValue(RCSignalQuality.skySnr)
                }

                LabelledLabel {
                    label:      qsTr("天空端功率")
                    labelText:  _formatValue(RCSignalQuality.skyPower)
                }

                LabelledLabel {
                    label:      qsTr("天空端MCS")
                    labelText:  _formatValue(RCSignalQuality.skyMcs)
                }
            }
        }
    }
}
