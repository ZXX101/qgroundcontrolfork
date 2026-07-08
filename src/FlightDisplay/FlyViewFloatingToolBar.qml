import QtQuick

import QGroundControl
import QGroundControl.Palette
import QGroundControl.ScreenTools

Item {
    id: root

    z: QGroundControl.zOrderWidgets

    property bool _expanded: false
    property bool _onRightHalf: false
    property real _buttonSize: ScreenTools.defaultFontPixelWidth * 5.5
    property real _iconScale: 0.45
    property real _spacing: ScreenTools.defaultFontPixelWidth * 0.4
    property real _padding: ScreenTools.defaultFontPixelWidth * 0.3
    property real _topMargin: ScreenTools.defaultFontPixelHeight * 2
    property real _toolBtnSize: _buttonSize - _padding * 2
    property int _toolCount: 3

    property int _dragStartX: 0
    property int _dragStartY: 0
    property bool _wasDragging: false
    property int _hoveredToolIndex: -1
    property bool _hoveredToggle: false

    readonly property real _expandedWidth: _buttonSize + _spacing + _toolCount * _toolBtnSize + (_toolCount - 1) * _spacing + _padding
    readonly property real _extraWidth: _expandedWidth - _buttonSize

    width: _buttonSize
    height: _buttonSize

    Component.onCompleted: {
        x = (parent.width - width) / 2
        y = _topMargin
        _updateDirection()
    }

    function _updateDirection() {
        if (!parent) return
        var centerX = x + _buttonSize / 2
        _onRightHalf = centerX > parent.width / 2
    }

    on_ExpandedChanged: {
        _expandAnimation.stop()
        _collapseAnimation.stop()

        if (_expanded) {
            _updateDirection()
            var targetWidth = _expandedWidth
            var targetX = _onRightHalf ? x - _extraWidth : x
            if (targetX < 0) targetX = 0
            if (targetX + targetWidth > parent.width) targetX = parent.width - targetWidth

            _expandAnimation.targetWidth = targetWidth
            _expandAnimation.targetX = targetX
            _expandAnimation.start()
        } else {
            var collapseTargetX = _onRightHalf ? x + _extraWidth : x
            if (collapseTargetX < 0) collapseTargetX = 0
            if (collapseTargetX + _buttonSize > parent.width) collapseTargetX = parent.width - _buttonSize

            _collapseAnimation.targetX = collapseTargetX
            _collapseAnimation.start()
        }
    }

    ParallelAnimation {
        id: _expandAnimation
        property real targetWidth: root._expandedWidth
        property real targetX: 0
        NumberAnimation { target: root; property: "width"; to: _expandAnimation.targetWidth; duration: 200; easing.type: Easing.InOutCubic }
        NumberAnimation { target: root; property: "x"; to: _expandAnimation.targetX; duration: 200; easing.type: Easing.InOutCubic }
        onFinished: root._clampPosition()
    }

    ParallelAnimation {
        id: _collapseAnimation
        property real targetX: 0
        NumberAnimation { target: root; property: "width"; to: root._buttonSize; duration: 200; easing.type: Easing.InOutCubic }
        NumberAnimation { target: root; property: "x"; to: _collapseAnimation.targetX; duration: 200; easing.type: Easing.InOutCubic }
        onFinished: root._clampPosition()
    }

    function _clampPosition() {
        if (!parent) return
        if (x < 0) x = 0
        if (y < 0) y = 0
        if (x + width > parent.width) x = parent.width - width
        if (y + height > parent.height) y = parent.height - height
    }

    function _hitTestToggle(mx, my) {
        if (!_onRightHalf) {
            return mx < _buttonSize && my < _buttonSize
        } else {
            return mx > width - _buttonSize && my < _buttonSize
        }
    }

    function _hitTestTool(mx, my) {
        if (!_expanded) return -1
        var btnY = (_buttonSize - _toolBtnSize) / 2
        if (my < btnY || my > btnY + _toolBtnSize) return -1

        if (!_onRightHalf) {
            var startX = _buttonSize + _spacing
            for (var i = 0; i < _toolCount; i++) {
                var bx = startX + i * (_toolBtnSize + _spacing)
                if (mx >= bx && mx <= bx + _toolBtnSize) return i
            }
        } else {
            var startX2 = width - _buttonSize - _spacing - _toolCount * _toolBtnSize - (_toolCount - 1) * _spacing
            for (var j = 0; j < _toolCount; j++) {
                var bx2 = startX2 + j * (_toolBtnSize + _spacing)
                if (mx >= bx2 && mx <= bx2 + _toolBtnSize) return j
            }
        }
        return -1
    }

    function _updateHover(mx, my) {
        _hoveredToggle = _hitTestToggle(mx, my)
        _hoveredToolIndex = _hitTestTool(mx, my)
    }

    QGCPalette { id: qgcPal }

    Rectangle {
        id: _backgroundRect
        anchors.fill: parent
        radius: height / 2
        color: qgcPal.toolbarBackground
        opacity: 0.85
        border.width: 1
        border.color: qgcPal.buttonBorder
    }

    Item {
        id: _leftLayout
        anchors.fill: parent
        visible: !root._onRightHalf

        Rectangle {
            id: _toggleBtnLeft
            width: root._buttonSize
            height: root._buttonSize
            radius: height / 2
            color: root._hoveredToggle ? qgcPal.buttonHighlight : "transparent"
            anchors.left: parent.left
            anchors.top: parent.top

            Image {
                anchors.centerIn: parent
                width: root._buttonSize * root._iconScale
                height: width
                source: root._expanded ? "/xfres/tools-collapse.png" : "/xfres/tools-expand.png"
                fillMode: Image.PreserveAspectFit
            }
        }

        Row {
            id: _toolRowLeft
            anchors.left: _toggleBtnLeft.right
            anchors.leftMargin: root._spacing
            anchors.verticalCenter: parent.verticalCenter
            spacing: root._spacing
            visible: root._expanded
            clip: true

            Repeater {
                model: [
                    "/xfres/center-on-device.png",
                    "/xfres/center-on-remote.png",
                    "/xfres/rangefinder.png"
                ]

                Rectangle {
                    width: root._toolBtnSize
                    height: width
                    radius: width / 2
                    color: root._hoveredToolIndex === index ? qgcPal.buttonHighlight : "transparent"

                    Image {
                        anchors.centerIn: parent
                        width: parent.width * 0.7
                        height: width
                        source: modelData
                        fillMode: Image.PreserveAspectFit
                    }
                }
            }
        }
    }

    Item {
        id: _rightLayout
        anchors.fill: parent
        visible: root._onRightHalf

        Rectangle {
            id: _toggleBtnRight
            width: root._buttonSize
            height: root._buttonSize
            radius: height / 2
            color: root._hoveredToggle ? qgcPal.buttonHighlight : "transparent"
            anchors.right: parent.right
            anchors.top: parent.top

            Image {
                anchors.centerIn: parent
                width: root._buttonSize * root._iconScale
                height: width
                source: root._expanded ? "/xfres/tools-collapse.png" : "/xfres/tools-expand.png"
                fillMode: Image.PreserveAspectFit
                mirror: true
            }
        }

        Row {
            id: _toolRowRight
            anchors.right: _toggleBtnRight.left
            anchors.rightMargin: root._spacing
            anchors.verticalCenter: parent.verticalCenter
            spacing: root._spacing
            visible: root._expanded
            clip: true

            Repeater {
                model: [
                    "/xfres/center-on-device.png",
                    "/xfres/center-on-remote.png",
                    "/xfres/rangefinder.png"
                ]

                Rectangle {
                    width: root._toolBtnSize
                    height: width
                    radius: width / 2
                    color: root._hoveredToolIndex === index ? qgcPal.buttonHighlight : "transparent"

                    Image {
                        anchors.centerIn: parent
                        width: parent.width * 0.7
                        height: width
                        source: modelData
                        fillMode: Image.PreserveAspectFit
                    }
                }
            }
        }
    }

    MouseArea {
        id: _dragArea
        anchors.fill: parent
        hoverEnabled: true
        drag.target: root
        drag.axis: Drag.XAndYAxis
        drag.minimumX: 0
        drag.minimumY: 0
        drag.maximumX: root.parent ? root.parent.width - root._buttonSize : 0
        drag.maximumY: root.parent ? root.parent.height - root.height : 0
        preventStealing: true

        onPressed: (mouse) => {
            root.anchors.left = undefined
            root.anchors.right = undefined
            root.anchors.top = undefined
            root.anchors.bottom = undefined
            root.anchors.horizontalCenter = undefined
            root.anchors.verticalCenter = undefined
            _dragStartX = mouse.x
            _dragStartY = mouse.y
            _wasDragging = false
        }

        onPositionChanged: (mouse) => {
            _updateHover(mouse.x, mouse.y)
            if (pressed && (Math.abs(mouse.x - _dragStartX) > 5 || Math.abs(mouse.y - _dragStartY) > 5)) {
                _wasDragging = true
            }
        }

        onReleased: (mouse) => {
            if (!_wasDragging) {
                if (_hitTestToggle(mouse.x, mouse.y)) {
                    root._expanded = !root._expanded
                } else {
                    var toolIdx = _hitTestTool(mouse.x, mouse.y)
                    if (toolIdx >= 0) {
                        console.log("Tool button clicked:", toolIdx)
                    }
                }
            } else {
                root._updateDirection()
            }
            root._clampPosition()
        }

        onContainsMouseChanged: {
            if (!containsMouse) {
                _hoveredToggle = false
                _hoveredToolIndex = -1
            }
        }
    }
}
