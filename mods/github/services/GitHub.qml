pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia

Singleton {
    id: root

    property string username: "Loloopsmybad"
    property bool enabled: true
    property int refreshInterval: 300000

    property var profile: null
    property var contributions: null
    property var pinnedRepos: null
    property bool loading: false
    property string error: ""

    property var contributionGrid: []

    readonly property int totalContributions: {
        if (!contributions || !contributions.contributions)
            return 0;
        return contributions.contributions.reduce((sum, c) => sum + (c.count || 0), 0);
    }

    readonly property int totalStars: {
        if (!pinnedRepos)
            return 0;
        return pinnedRepos.reduce((sum, r) => sum + (r.stargazers_count || 0), 0);
    }

    function fetchProfile(): void {
        if (!enabled || !username)
            return;

        loading = true;
        error = "";

        const url = `https://api.github.com/users/${username}`;
        Requests.get(url, text => {
            try {
                root.profile = JSON.parse(text);
            } catch (e) {
                root.error = "Failed to parse profile";
            }
            root.loading = false;
        }, err => {
            root.error = "Failed to fetch profile: " + err;
            root.loading = false;
        });
    }

    function fetchContributions(): void {
        if (!enabled || !username)
            return;

        const url = `https://github-contributions-api.jogruber.de/v4/${username}`;
        Requests.get(url, text => {
            try {
                const data = JSON.parse(text);
                root.contributions = data;
                buildGrid(data.contributions);
            } catch (e) {
                console.warn("GitHub: Failed to parse contributions:", e);
            }
        }, err => {
            console.warn("GitHub: Failed to fetch contributions:", err);
        });
    }

    function buildGrid(rawContributions: var): void {
        if (!rawContributions || rawContributions.length === 0)
            return;

        // Build lookup: date string -> {count, level}
        const dateMap = {};
        for (let i = 0; i < rawContributions.length; i++) {
            const c = rawContributions[i];
            dateMap[c.date] = c;
        }

        // Today
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const todayDow = (today.getDay() + 6) % 7; // Mon=0 .. Sun=6

        // Grid position of today: row=todayDow, col=52 (rightmost)
        // Grid starts 52 weeks before the Monday of this week
        const mondayOfThisWeek = new Date(today);
        mondayOfThisWeek.setDate(mondayOfThisWeek.getDate() - todayDow);

        const gridStart = new Date(mondayOfThisWeek);
        gridStart.setDate(gridStart.getDate() - 52 * 7);

        const grid = [];

        // Row-major: outer loop = day (row), inner loop = week (col)
        // So Grid with columns=53 fills: row0-col0, row0-col1, ..., row0-col52, row1-col0, ...
        for (let row = 0; row < 7; row++) {
            for (let col = 0; col < 53; col++) {
                const d = new Date(gridStart);
                d.setDate(d.getDate() + col * 7 + row);

                if (d > today) {
                    grid.push({ date: "", count: 0, level: -1, day: row, week: col });
                    continue;
                }

                const dateStr = d.getFullYear() + "-" +
                    String(d.getMonth() + 1).padStart(2, "0") + "-" +
                    String(d.getDate()).padStart(2, "0");

                const entry = dateMap[dateStr];
                grid.push({
                    date: dateStr,
                    count: entry?.count ?? 0,
                    level: entry?.level ?? 0,
                    day: row,
                    week: col
                });
            }
        }

        root.contributionGrid = grid;
    }

    function fetchPinnedRepos(): void {
        if (!enabled || !username)
            return;

        const url = `https://api.github.com/users/${username}/repos?sort=stars&per_page=6&direction=desc`;
        Requests.get(url, text => {
            try {
                root.pinnedRepos = JSON.parse(text);
            } catch (e) {
                console.warn("GitHub: Failed to parse repos:", e);
            }
        }, err => {
            console.warn("GitHub: Failed to fetch repos:", err);
        });
    }

    function refresh(): void {
        fetchProfile();
        fetchContributions();
        fetchPinnedRepos();
    }

    Component.onCompleted: refresh()

    Timer {
        interval: root.refreshInterval
        running: root.enabled
        repeat: true
        onTriggered: root.refresh()
    }

    LoggingCategory {
        id: lc
        name: "caelestia.qml.services.github"
        defaultLogLevel: LoggingCategory.Info
    }
}
