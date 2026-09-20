pragma ComponentBehavior: Bound
import QtQuick
import "."

ListView {
    id: root
    required property ConfigAdapter config
    required property ColorsAdapter colors
    property int selectedIndex: 0
    property real tileWidth: width / config.number_of_pictures - 10
    property real shearOffset: config.height * Math.abs(config.x_factor)
    property bool initialPosition: true
    property int pendingInitialIndex: -1
    property real speed: 5000

    signal selected(path: string, i: int)
    orientation: ListView.Horizontal
    spacing: -60
    clip: true
    cacheBuffer: width * 2
    leftMargin: config.x_factor < 0 ? shearOffset : 0
    Component.onCompleted: forceActiveFocus()

    onCountChanged: {
        scheduleInitialPosition();
    }
    onWidthChanged: scheduleInitialPosition()
    onContentWidthChanged: scheduleInitialPosition()

    function clampIndex(i) {
        if (count <= 0 || isNaN(i))
            return 0;

        return Math.max(0, Math.min(i, count - 1));
    }

    function clampX(x) {
        if (isNaN(x))
            return config.x_factor < 0 ? -shearOffset : 0;

        const max = maxContentX();
        const clamped = Math.max(0, Math.min(x, max));

        return config.x_factor < 0 ? clamped === 0 ? -shearOffset : clamped : clamped === 0 ? 0 : clamped === max ? x + shearOffset : clamped;
    }

    function estimatedContentWidth() {
        const itemCount = Math.max(0, count);
        const itemWidth = Math.max(0, tileWidth);
        return leftMargin + itemCount * itemWidth + Math.max(0, itemCount - 1) * spacing;
    }

    function maxContentX() {
        return Math.max(0, Math.max(contentWidth, estimatedContentWidth()) - width);
    }

    function centerOnIndex(i) {
        if (count <= 0) {
            contentX = 0;
            return;
        }

        if (width <= 0 || tileWidth <= 0)
            return;

        const targetIndex = clampIndex(i);
        const step = tileWidth + spacing;
        const itemStart = targetIndex * step;
        contentX = clampX(itemStart - width / 2 + tileWidth / 2);
    }

    function selectInitialIndex(i) {
        pendingInitialIndex = clampIndex(i);
        initialPosition = true;
        selectedIndex = pendingInitialIndex;
        scheduleInitialPosition();
    }

    function scheduleInitialPosition() {
        if (pendingInitialIndex < 0)
            return;

        initialPosition = true;
        Qt.callLater(() => {
            applyInitialPosition();
        });
    }

    function applyInitialPosition() {
        if (pendingInitialIndex < 0 || count <= 0)
            return;

        if (width <= 0 || tileWidth <= 0)
            return;

        if (estimatedContentWidth() > width && contentWidth <= width)
            return;

        const targetIndex = clampIndex(pendingInitialIndex);
        selectedIndex = targetIndex;
        centerOnIndex(targetIndex);
        pendingInitialIndex = -1;

        Qt.callLater(() => {
            initialPosition = false;
        });
    }

    function ensureVisibleAnimated(i) {
        if (count <= 0)
            return;

        const targetIndex = clampIndex(i);
        const step = tileWidth + spacing;
        const itemStart = targetIndex * step;
        const itemEnd = itemStart + tileWidth + 20;
        if (itemStart < contentX)
            contentX = clampX(itemStart);
        else if (itemEnd > contentX + width)
            contentX = clampX(itemStart - (width - step));
    }

    function activateIndex(i) {
        if (count <= 0)
            return;

        const targetIndex = clampIndex(i);
        selected(root.model.get(targetIndex).filePath, targetIndex);
    }

    Behavior on contentX {
        enabled: !root.initialPosition

        SmoothedAnimation {
            id: anim
            property int v: 10
            duration: 200
        }
    }

    onSelectedIndexChanged: {
        ensureVisibleAnimated(selectedIndex);
    }

    delegate: SelectorItem {
        colors: root.colors
        configs: root.config
        listView: root
        selectedIndex: root.selectedIndex
        onClicked: i => {
            root.forceActiveFocus()
            const targetIndex = root.clampIndex(i);
            root.selectedIndex = targetIndex;
            root.activateIndex(targetIndex);
        }
    }

    MouseArea {
        propagateComposedEvents: true
        anchors.fill: root
        onClicked: function(mouse) {
            root.forceActiveFocus()
            mouse.accepted = false
        }
        onWheel: function (wheel) {
            root.contentX = root.clampX(root.contentX - wheel.angleDelta.y * 2);
            wheel.accepted = false;
        }
    }

    Keys.onPressed: function (event) {
        let step = 1;
        const big = config.number_of_pictures;
        switch (event.key) {
        case Qt.Key_J:
        case Qt.Key_L:
        case Qt.Key_Down:
        case Qt.Key_Right:
            moveCursor(speed, selectedIndex + step);
            break;
        case Qt.Key_K:
        case Qt.Key_H:
        case Qt.Key_Up:
        case Qt.Key_Left:
            moveCursor(speed, selectedIndex - step);
            break;
        case Qt.Key_Tab:
            moveCursor(speed, wrapIndex(selectedIndex + step));
            break;
        case Qt.Key_Backtab:
            moveCursor(speed, wrapIndex(selectedIndex - step));
            break;
        case Qt.Key_D:
            moveCursor(speed * big, selectedIndex + big);
            break;
        case Qt.Key_U:
            moveCursor(speed * big, selectedIndex - big);
            break;
        case Qt.Key_Space:
        case Qt.Key_Return:
            activateIndex(selectedIndex);
            break;
        case Qt.Key_Escape:
            Qt.quit();
            break;
        default:
            return;
        }
        event.accepted = true;
    }

    function moveCursor(speed, newIndex) {
        anim.v = speed;
        selectedIndex = clampIndex(newIndex);
    }

    function wrapIndex(i) {
        if (count <= 0)
            return 0;

        return ((i % count) + count) % count;
    }
}
