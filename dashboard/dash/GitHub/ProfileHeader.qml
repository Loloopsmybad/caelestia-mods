pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import M3Shapes
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.images
import qs.services

RowLayout {
    id: root

    spacing: Tokens.spacing.medium

    MaterialShape {
        id: avatarShape

        implicitSize: 64
        shape: MaterialShape.Pill
        color: Colours.layer(Colours.palette.m3surfaceContainerHighest, 2)
        layer.enabled: true

        CachingImage {
            id: avatar

            anchors.fill: parent
            path: GitHub.profile?.avatar_url ?? ""
        }

        Item {
            anchors.fill: parent
            layer.enabled: true
            layer.effect: Mask {
                maskSource: avatarShape
            }

            Loader {
                anchors.centerIn: parent
                active: avatar.status !== Image.Ready

                sourceComponent: MaterialIcon {
                    text: "person"
                    color: Colours.palette.m3onSurfaceVariant
                    fontStyle: Tokens.font.icon.extraLarge
                    fill: 1
                }
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.small

        StyledText {
            text: GitHub.profile?.login ?? "Loading..."
            font: Tokens.font.title.medium
            color: Colours.palette.m3onSurface
        }

        StyledText {
            text: GitHub.profile?.name ?? ""
            font: Tokens.font.body.medium
            color: Colours.palette.m3onSurfaceVariant
            visible: text !== ""
        }

        RowLayout {
            spacing: Tokens.spacing.large

            StatBadge {
                label: qsTr("Followers")
                value: GitHub.profile?.followers ?? 0
            }

            StatBadge {
                label: qsTr("Following")
                value: GitHub.profile?.following ?? 0
            }

            StatBadge {
                label: qsTr("Stars")
                value: GitHub.totalStars
            }

            StatBadge {
                label: qsTr("Contributions")
                value: GitHub.totalContributions
            }
        }
    }

    component StatBadge: ColumnLayout {
        required property string label
        required property int value

        spacing: 2

        StyledText {
            text: parent.value.toLocaleString()
            font: Tokens.font.title.large
            color: Colours.palette.m3primary
        }

        StyledText {
            text: parent.label
            font: Tokens.font.label.small
            color: Colours.palette.m3onSurfaceVariant
        }
    }
}
