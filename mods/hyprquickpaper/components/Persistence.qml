import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    required property string path
    property bool isReady: false
    property string value: ""

    signal ready(value: string);

    function save(value) {
        root.value = value;
        file.setText(root.value);
    }
    function load() {
        return value;
    }

    FileView {
        id: file
        blockLoading: true
        path: root.path

        onPathChanged: {
            if (path !== "") {
                reload();
            }
        }
        onLoaded: {
            root.isReady = true;
            root.value = text().trim();
            root.ready(root.value)
        }
    }
}
