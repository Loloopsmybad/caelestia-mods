pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

ColumnLayout {
    id: root

    spacing: Tokens.spacing.medium

    StyledText {
        text: qsTr("Pinned Repositories")
        font: Tokens.font.title.small
        color: Colours.palette.m3onSurface
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 3
        columnSpacing: Tokens.spacing.medium
        rowSpacing: Tokens.spacing.medium

        Repeater {
            model: GitHub.pinnedRepos ?? []

            delegate: RepoCard {
                required property var modelData
                required property int index

                Layout.fillWidth: true
                Layout.preferredHeight: implicitHeight

                repo: modelData
            }
        }
    }
}
