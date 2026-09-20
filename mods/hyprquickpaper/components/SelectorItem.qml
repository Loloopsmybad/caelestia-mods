import QtQuick
import "."

Item {
    id: root
    required property int index
    required property ConfigAdapter configs
    required property ColorsAdapter colors
    required property string fileName
    required property string filePath
    required property string cashePath
    required property int selectedIndex
    required property ListView listView

    property bool active: index === selectedIndex
    height: configs.height
    width: listView.tileWidth

    property real scaleFactor: {
        const centerX = x - listView.contentX + width / 2
        const viewportCenterX = listView.width / 2
        const frac = Math.min(
            1,
            Math.abs(centerX - viewportCenterX) / viewportCenterX
        )
        const t = 1 - frac * frac * (3 - 2 * frac)
        return 0.4 + 0.5 * t
    }

    signal clicked(index: int)

    Item {
        id: content
        anchors.centerIn: parent
        width: root.width
        height: root.height

        Text {
            id: alt
            text: ""
            color: root.colors.border_color
            anchors.centerIn: parent
            leftPadding: content.height * (-1 * root.configs.x_factor) / (root.configs.x_factor < 0 ? 2 : 1)
            font.pixelSize: 16
            font.bold: true
            visible: text !== ""
            transform: Shear {
                xFactor: root.configs.x_factor
            }
        }

        Image {
            id: img
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            verticalAlignment: Image.AlignTop

            asynchronous: true
            cache: false
            smooth: true

            source: "file://" + root.cashePath

            sourceSize.width: width
            sourceSize.height: height

            opacity: status === Image.Ready ? 1 : 0

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            transform: [
                Shear {
                    xFactor: root.configs.x_factor
                }
            ]

            Timer {
                id: retryTimer
                interval: 1000
                repeat: false
                onTriggered: {
                    let s = img.source;
                    img.source = "";
                    img.source = s;
                }
            }

            onStatusChanged: {
                if (status === Image.Error) {
                    alt.text = "Caching...";
                    retryTimer.start();
                }
            }
        }

        Rectangle {
            id: border
            z: 10
            visible: root.active

            anchors.fill: parent

            color: "transparent"

            border.width: 4
            border.color: root.colors.border_color

            transform: Shear {
                xFactor: root.configs.x_factor
            }
        }

        transform: Scale {
            xScale: root.scaleFactor
            yScale: root.scaleFactor
            origin.x: content.width / 2
            origin.y: content.height / 2
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.clicked(root.index);
        }
    }
}
