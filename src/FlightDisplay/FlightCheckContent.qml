/****************************************************************************
 *
 * Flight Check Content for QGroundControl
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Palette

//飞行检查内容组件，显示连接、传感器、电机、安全、飞行等检查项
Rectangle {
    id:                 root
    width:              contentLayout.width + ScreenTools.defaultFontPixelWidth * 2
    height:             contentLayout.height + ScreenTools.defaultFontPixelHeight
    color:              Qt.rgba(0, 0, 0, 0.7)  //半透明深色背景
    radius:             ScreenTools.defaultFontPixelWidth / 2
    border.width:       0  //无边框

    property var activeVehicle

    QGCPalette { id: qgcPal }

    ColumnLayout {
        id:                 contentLayout
        anchors.centerIn:   parent
        spacing:            ScreenTools.defaultFontPixelHeight * 0.5

        //表格标题行
        RowLayout {
            spacing: ScreenTools.defaultFontPixelWidth * 2

            QGCLabel { text: qsTr("类别"); font.bold: true; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8 }
            QGCLabel { text: qsTr("设置项"); font.bold: true; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 25 }
            QGCLabel { text: qsTr("数据"); font.bold: true; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8 }
            QGCLabel { text: qsTr("状态"); font.bold: true; Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8 }
        }

        //分隔线
        Rectangle {
            Layout.fillWidth:   true
            height:             1
            color:              qgcPal.text
        }

        //连接检查
        CheckSection {
            sectionTitle:   qsTr("连接")
            items: [
                { name: "TCP Link 192.168.144.68:2000", value: "", icon: "" }
            ]
        }

        //传感器检查
        CheckSection {
            sectionTitle:   qsTr("传感器")
            items: [
                { name: qsTr("罗盘"), value: "", icon: "/xfres/checkGreen.png" },
                { name: qsTr("加速度计"), value: "", icon: "/xfres/checkGreen.png" },
                { name: qsTr("陀螺仪"), value: "", icon: "/xfres/checkGreen.png" },
                { name: qsTr("EKF"), value: "", icon: "/xfres/checkGreen.png" }
            ]
        }

        //电机检查
        CheckSection {
            sectionTitle:   qsTr("电机")
            items: [
                { name: qsTr("M1温度"), value: "50°", icon: "" },
                { name: qsTr("M2温度"), value: "23°", icon: "" },
                { name: qsTr("M3温度"), value: "32°", icon: "" },
                { name: qsTr("M4温度"), value: "30°", icon: "" }
            ]
        }

        //安全检查
        CheckSection {
            sectionTitle:   qsTr("安全")
            items: [
                { name: qsTr("低电压保护设置"), value: "5.2V", status: qsTr("返航") },
                { name: qsTr("软件断联保护"), value: "5s", status: qsTr("降落") },
                { name: qsTr("遥控器失控保护"), value: "950", status: qsTr("降落") }
            ]
        }

        //飞行检查
        CheckSection {
            sectionTitle:   qsTr("飞行")
            items: [
                { name: qsTr("返航高度"), value: "", status: "20m" }
            ]
        }
    }

    //检查项分组组件
    component CheckSection: ColumnLayout {
        spacing: ScreenTools.defaultFontPixelHeight * 0.25

        property string sectionTitle
        property var items: []

        RowLayout {
            spacing: ScreenTools.defaultFontPixelWidth * 2

            //类别列
            QGCLabel {
                text:                   sectionTitle
                font.bold:              true
                Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 8
            }

            //设置项列（第一项）
            QGCLabel {
                text:                   items.length > 0 ? items[0].name : ""
                Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 25
            }

            //数据列（第一项）
            QGCLabel {
                text:                   items.length > 0 ? items[0].value : ""
                Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 8
            }

            //状态列（第一项）- 可能是图标或文本
            Item {
                Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 8
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight

                //状态图标
                Image {
                    anchors.centerIn:       parent
                    width:                  ScreenTools.defaultFontPixelHeight * 0.8
                    height:                 width
                    source:                 (items.length > 0 && items[0].icon !== undefined && items[0].icon !== "") ? items[0].icon : ""
                    fillMode:               Image.PreserveAspectFit
                    visible:                items.length > 0 && items[0].icon !== undefined && items[0].icon !== ""
                }

                //状态文本（如果没有图标）
                QGCLabel {
                    anchors.centerIn:       parent
                    text:                   (items.length > 0 && items[0].status !== undefined) ? items[0].status : ""
                    visible:                items.length > 0 && items[0].status !== undefined && items[0].status !== "" && !(items[0].icon !== undefined && items[0].icon !== "")
                }
            }
        }

        //后续项（类别列空白）
        Repeater {
            model: items.length > 1 ? items.slice(1) : []

            RowLayout {
                spacing: ScreenTools.defaultFontPixelWidth * 2

                //类别列（空白）
                QGCLabel {
                    text:                   ""
                    Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 8
                }

                //设置项列
                QGCLabel {
                    text:                   modelData.name !== undefined ? modelData.name : ""
                    Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 25
                }

                //数据列
                QGCLabel {
                    text:                   modelData.value !== undefined ? modelData.value : ""
                    Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 8
                }

                //状态列 - 可能是图标或文本
                Item {
                    Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 8
                    Layout.preferredHeight: ScreenTools.defaultFontPixelHeight

                    //状态图标
                    Image {
                        anchors.centerIn:       parent
                        width:                  ScreenTools.defaultFontPixelHeight * 0.8
                        height:                 width
                        source:                 (modelData.icon !== undefined && modelData.icon !== "") ? modelData.icon : ""
                        fillMode:               Image.PreserveAspectFit
                        visible:                modelData.icon !== undefined && modelData.icon !== ""
                    }

                    //状态文本（如果没有图标）
                    QGCLabel {
                        anchors.centerIn:       parent
                        text:                   modelData.status !== undefined ? modelData.status : ""
                        visible:                modelData.status !== undefined && modelData.status !== "" && !(modelData.icon !== undefined && modelData.icon !== "")
                    }
                }
            }
        }

        //分隔线
        Rectangle {
            Layout.fillWidth:   true
            height:             1
            color:              qgcPal.windowShade
        }
    }
}