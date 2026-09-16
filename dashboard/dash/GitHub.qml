pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

Item {
    id: root

    implicitWidth: layout.implicitWidth + layout.anchors.margins * 2
    implicitHeight: layout.implicitHeight + layout.anchors.margins * 2

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: Tokens.padding.large
        spacing: Tokens.spacing.medium

        // Header with avatar and stats
        ProfileHeader {
            Layout.fillWidth: true
        }

        // Contribution graph
        ContributionGraph {
            Layout.fillWidth: true
        }

        // Pinned repos
        PinnedRepos {
            Layout.fillWidth: true
        }
    }
}
