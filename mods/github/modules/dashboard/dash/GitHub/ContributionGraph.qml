pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

Grid {
    id: root

    Layout.fillWidth: true
    Layout.leftMargin: Tokens.padding.extraLarge
    Layout.rightMargin: Tokens.padding.small
    columns: 53
    rows: 7
    spacing: cellGap

    Repeater {
        model: GitHub.contributionGrid.length

        delegate: Rectangle {
            required property int index

            property var cell: GitHub.contributionGrid[index] ?? ({})

            width: cellSize
            height: cellSize
            radius: 2

            color: {
                const level = cell.level ?? 0;
                if (level < 0) return "transparent";
                if (level === 0) return Colours.layer(Colours.palette.m3surfaceContainerHighest, 1);
                const t = level / 4;
                return Qt.rgba(
                    0.15 + t * 0.25,
                    0.6 + t * 0.2,
                    0.35 + t * 0.1,
                    0.8 + t * 0.2
                );
            }

            ToolTip {
                visible: hoverArea.containsMouse && (cell.level ?? 0) >= 0
                text: `${cell.count ?? 0} contributions on ${cell.date ?? ""}`
            }

            MouseArea {
                id: hoverArea
                anchors.fill: parent
                hoverEnabled: true
            }
        }
    }

    readonly property real cellSize: 10
    readonly property real cellGap: 2
}
