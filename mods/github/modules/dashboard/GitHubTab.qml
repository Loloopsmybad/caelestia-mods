pragma ComponentBehavior: Bound

import "dash/GitHub"
import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.images
import qs.services

Item {
    id: root

    implicitWidth: 800
    implicitHeight: content.implicitHeight + content.anchors.margins * 2

    ColumnLayout {
        id: content

        anchors.fill: parent
        anchors.margins: Tokens.padding.large
        spacing: Tokens.spacing.large

        // ── Header ──
        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.medium

            Rectangle {
                id: avatarContainer
                implicitWidth: 56
                implicitHeight: 56
                radius: height / 2
                color: Colours.layer(Colours.palette.m3surfaceContainerHighest, 2)
                clip: true

                Image {
                    id: avatar
                    anchors.fill: parent
                    source: GitHub.profile?.avatar_url ?? ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                    mipmap: true
                    visible: status === Image.Ready
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

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    text: GitHub.profile?.login ?? "Loading..."
                    font: Tokens.font.title.large
                    color: Colours.palette.m3onSurface
                }

                RowLayout {
                    spacing: Tokens.spacing.small

                    StyledText {
                        text: (GitHub.profile?.followers ?? 0) + " followers"
                        font: Tokens.font.body.medium
                        color: Colours.palette.m3onSurfaceVariant
                    }

                    StyledText {
                        text: "·"
                        font: Tokens.font.body.medium
                        color: Colours.palette.m3.onSurfaceVariant
                        visible: (GitHub.profile?.public_repos ?? 0) > 0
                    }

                    StyledText {
                        text: (GitHub.profile?.public_repos ?? 0) + " repos"
                        font: Tokens.font.body.medium
                        color: Colours.palette.m3onSurfaceVariant
                        visible: (GitHub.profile?.public_repos ?? 0) > 0
                    }
                }
            }

            RowLayout {
                spacing: Tokens.spacing.small

                IconButton {
                    icon: "refresh"
                    onClicked: GitHub.refresh()
                }

                IconButton {
                    icon: "open_in_new"
                    onClicked: {
                        const url = `https://github.com/${GitHub.username}`;
                        Hypr.runCmd(["xdg-open", url]);
                    }
                }
            }
        }

        // ── Contributions ──
        StyledRect {
            Layout.fillWidth: true
            Layout.preferredHeight: contribCol.implicitHeight + Tokens.padding.large * 2

            radius: Tokens.rounding.extraLarge
            color: Colours.layer(Colours.palette.m3surfaceContainer, 1)

            ColumnLayout {
                id: contribCol
                anchors.fill: parent
                anchors.margins: Tokens.padding.large
                spacing: Tokens.spacing.medium

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: qsTr("Contributions")
                        font: Tokens.font.title.small
                        color: Colours.palette.m3onSurface
                    }

                    Item { Layout.fillWidth: true }

                    RowLayout {
                        spacing: Tokens.spacing.small

                        StyledText {
                            text: qsTr("Less")
                            font: Tokens.font.label.small
                            color: Colours.palette.m3onSurfaceVariant
                        }

                        Repeater {
                            model: [0.0, 0.25, 0.5, 0.75, 1.0]

                            Rectangle {
                                required property real modelData
                                implicitWidth: 10
                                implicitHeight: 10
                                radius: 2
                                color: {
                                    const level = modelData;
                                    if (level === 0) return Colours.layer(Colours.palette.m3surfaceContainerHighest, 1);
                                    return Qt.rgba(0.15 + level * 0.25, 0.6 + level * 0.2, 0.35 + level * 0.1, 0.8 + level * 0.2);
                                }
                            }
                        }

                        StyledText {
                            text: qsTr("More")
                            font: Tokens.font.label.small
                            color: Colours.palette.m3onSurfaceVariant
                        }
                    }
                }

                ContributionGraph {
                    Layout.fillWidth: true
                }
            }
        }

        // ── Repos grid ──
        GridLayout {
            Layout.fillWidth: true
            columns: 3
            columnSpacing: Tokens.spacing.medium
            rowSpacing: Tokens.spacing.medium

            Repeater {
                model: GitHub.pinnedRepos ?? []

                delegate: StyledRect {
                    required property var modelData
                    required property int index

                    Layout.fillWidth: true
                    implicitHeight: repoCol.implicitHeight + Tokens.padding.large * 2

                    radius: Tokens.rounding.extraLarge
                    color: Colours.layer(Colours.palette.m3surfaceContainer, 1)

                    ColumnLayout {
                        id: repoCol
                        anchors.fill: parent
                        anchors.margins: Tokens.padding.large
                        spacing: Tokens.spacing.small

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Tokens.spacing.extraSmall

                            MaterialIcon {
                                text: "folder"
                                color: Colours.palette.m3primary
                                fontStyle: Tokens.font.icon.small
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.name ?? ""
                                font: Tokens.font.label.large
                                color: Colours.palette.m3onSurface
                                elide: Text.ElideRight
                            }
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: modelData.description ?? ""
                            font: Tokens.font.body.small
                            color: Colours.palette.m3onSurfaceVariant
                            elide: Text.ElideRight
                            maximumLineCount: 3
                            wrapMode: Text.Wrap
                            visible: text !== ""
                        }

                        Item { Layout.fillHeight: true }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Tokens.spacing.medium

                            RowLayout {
                                spacing: Tokens.spacing.extraSmall
                                visible: modelData.language !== null

                                Rectangle {
                                    implicitWidth: 8
                                    implicitHeight: 8
                                    radius: 4
                                    color: getLangColor(modelData.language)
                                }

                                StyledText {
                                    text: modelData.language ?? ""
                                    font: Tokens.font.label.small
                                    color: Colours.palette.m3onSurfaceVariant
                                }
                            }

                            Item { Layout.fillWidth: true }

                            RowLayout {
                                spacing: Tokens.spacing.extraSmall
                                MaterialIcon { text: "star"; color: Colours.palette.m3.onSurfaceVariant; fontStyle: Tokens.font.icon.small }
                                StyledText { text: (modelData.stargazers_count ?? 0).toLocaleString(); font: Tokens.font.label.small; color: Colours.palette.m3.onSurfaceVariant }
                            }

                            RowLayout {
                                spacing: Tokens.spacing.extraSmall
                                MaterialIcon { text: "call_split"; color: Colours.palette.m3.onSurfaceVariant; fontStyle: Tokens.font.icon.small }
                                StyledText { text: (modelData.forks_count ?? 0).toLocaleString(); font: Tokens.font.label.small; color: Colours.palette.m3.onSurfaceVariant }
                            }
                        }
                    }
                }
            }
        }
    }

    function getLangColor(lang: string): color {
        const c = {
            "JavaScript":"#f1e05a","TypeScript":"#3178c6","Python":"#3572A5",
            "Rust":"#dea584","Go":"#00ADD8","C":"#555555","C++":"#f34b7d",
            "Java":"#b07219","Ruby":"#701516","PHP":"#4F5D95","Swift":"#F05138",
            "Kotlin":"#A97BFF","Dart":"#00B4AB","Shell":"#89e051","QML":"#44a51c",
            "Lua":"#000080","Nix":"#7e7eff"
        };
        return c[lang] ?? Colours.palette.m3outline;
    }
}
