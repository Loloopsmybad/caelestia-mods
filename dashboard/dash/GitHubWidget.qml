pragma ComponentBehavior: Bound

import "GitHub"
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

        ProfileHeader {
            Layout.fillWidth: true
        }

        ContributionGraph {
            Layout.fillWidth: true
        }

        PinnedRepos {
            Layout.fillWidth: true
        }
    }
}
