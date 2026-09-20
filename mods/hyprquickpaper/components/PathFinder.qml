import Quickshell.Io
import QtQuick

Process {
    id: root
    required property ListModel target_model
    required property string path
    required property string cache_path

    running: false
    command: ["find", path, "-type", "f", "-printf", "%d %P\n"]
    stdout: StdioCollector {
        onStreamFinished: {
            const lines = this.text.split('\n').filter(el => el != '');

            const items = lines.map(line => {
                const firstSpace = line.indexOf(' ');
                const depth = parseInt(line.substring(0, firstSpace));
                const filePath = line.substring(firstSpace + 1);

                const parts = filePath.split('/');
                const topLevel = parts.length > 1 ? parts[0] : '';
                const parentPath = filePath.substring(0, filePath.lastIndexOf('/'));

                return {
                    depth: depth,
                    path: filePath,
                    topLevel: topLevel,
                    parent: parentPath,
                    name: parts.pop() || filePath,
                    slashCount: (filePath.match(/\//g) || []).length
                };
            });

            const sortedItems = items.sort((a, b) => {
                return a.path.localeCompare(b.path, undefined, {
                    sensitivity: "base"
                });
            });

            sortedItems.forEach(item => {
                console.log(item.path);
                root.target_model.append({
                    fileName: item.path,
                    filePath: root.path + '/' + item.path,
                    cashePath: root.cache_path + '/' + item.path
                });
            });
        }
    }
    stderr: StdioCollector {
        onStreamFinished: {
            if (text.length != 0) {
                console.error(`${root.toString()}: ${this.text}`);
            }
        }
    }
}
