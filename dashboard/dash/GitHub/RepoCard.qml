pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

StyledRect {
    id: root

    required property var repo

    implicitHeight: content.implicitHeight + content.anchors.margins * 2

    radius: Tokens.rounding.large
    color: Colours.layer(Colours.palette.m3surfaceContainerHighest, 1)

    ColumnLayout {
        id: content

        anchors.fill: parent
        anchors.margins: Tokens.padding.medium
        spacing: Tokens.spacing.small

        // Repo name and language
        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            MaterialIcon {
                text: "folder"
                color: Colours.palette.m3primary
                fontStyle: Tokens.font.icon.small
            }

            StyledText {
                Layout.fillWidth: true
                text: root.repo.name ?? ""
                font: Tokens.font.label.large
                color: Colours.palette.m3onSurface
                elide: Text.ElideRight
            }
        }

        // Description
        StyledText {
            Layout.fillWidth: true
            text: root.repo.description ?? ""
            font: Tokens.font.body.small
            color: Colours.palette.m3onSurfaceVariant
            elide: Text.ElideRight
            maximumLineCount: 2
            wrapMode: Text.Wrap
            visible: text !== ""
        }

        // Stats row
        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.medium

            // Language
            RowLayout {
                spacing: Tokens.spacing.extraSmall
                visible: root.repo.language !== null

                Rectangle {
                    implicitWidth: 8
                    implicitHeight: 8
                    radius: 4
                    color: getLanguageColor(root.repo.language)
                }

                StyledText {
                    text: root.repo.language ?? ""
                    font: Tokens.font.label.small
                    color: Colours.palette.m3onSurfaceVariant
                }
            }

            Item { Layout.fillWidth: true }

            // Stars
            RowLayout {
                spacing: Tokens.spacing.extraSmall

                MaterialIcon {
                    text: "star"
                    color: Colours.palette.m3.tertiary
                    fontStyle: Tokens.font.icon.small
                }

                StyledText {
                    text: (root.repo.stargazers_count ?? 0).toLocaleString()
                    font: Tokens.font.label.small
                    color: Colours.palette.m3onSurfaceVariant
                }
            }

            // Forks
            RowLayout {
                spacing: Tokens.spacing.extraSmall

                MaterialIcon {
                    text: "call_split"
                    color: Colours.palette.m3.onSurfaceVariant
                    fontStyle: Tokens.font.icon.small
                }

                StyledText {
                    text: (root.repo.forks_count ?? 0).toLocaleString()
                    font: Tokens.font.label.small
                    color: Colours.palette.m3onSurfaceVariant
                }
            }
        }
    }

    function getLanguageColor(lang: string): color {
        const colors = {
            "JavaScript": "#f1e05a",
            "TypeScript": "#3178c6",
            "Python": "#3572A5",
            "Rust": "#dea584",
            "Go": "#00ADD8",
            "C": "#555555",
            "C++": "#f34b7d",
            "Java": "#b07219",
            "Ruby": "#701516",
            "PHP": "#4F5D95",
            "Swift": "#F05138",
            "Kotlin": "#A97BFF",
            "Dart": "#00B4AB",
            "Shell": "#89e051",
            "QML": "#44a51c",
            "Lua": "#000080",
            "Nix": "#7e7eff"
        };
        return colors[lang] ?? Colours.palette.m3outline;
    }
}
