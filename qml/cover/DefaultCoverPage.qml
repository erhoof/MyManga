import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

Cover {
    objectName: "defaultCover"
    anchors.fill: parent
    transparent: true

    Component.onCompleted: {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", 'https://api.anilibria.app/api/v1/anime/releases/latest?limit=1', true);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var jsonResponse = JSON.parse(xhr.responseText);
                    for (var key in jsonResponse) {
                        horizontalImage.source = 'https://api.anilibria.app/' + jsonResponse[key].poster.optimized.src
                        verticalImage.source = horizontalImage.source
                        horizontalName.text = jsonResponse[key].name.main
                    }
                }
            }
        };

        xhr.send();
    }

    Column {
        id: verticalColumn
        anchors {
            fill: parent
            leftMargin: Theme.paddingMedium
            rightMargin: Theme.paddingMedium
        }

        opacity: (orientation === Cover.Vertical) ? 100 : 0

        Image {
            id: verticalImage

            anchors {
                //left: parent.left
                //right: parent.right
                horizontalCenter: parent.horizontalCenter
            }
            width: 200
            height: parent.height - verticalName.height - Theme.paddingMedium * 2
            fillMode: Image.PreserveAspectCrop

            source: ""

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: verticalImage.width
                    height: verticalImage.height
                    radius: 10
                }
            }

            BusyIndicator {
                size: BusyIndicatorSize.Medium
                anchors.centerIn: verticalImage
                running: verticalImage.status != Image.Ready
            }
        }

        Label {
            id: verticalName

            anchors {
                topMargin: Theme.paddingLarge
            }
            height: 70

            width: parent.width
            text: qsTr("Last updated")
            font: Theme.fontSizeSmall
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignBottom
        }
    }

    Row {
        id: horizontalRow
        anchors {
            fill: parent
            leftMargin: Theme.paddingMedium * 2
            rightMargin: Theme.paddingMedium
        }

        opacity: (orientation === Cover.Horizontal) ? 100 : 0

        Image {
            id: horizontalImage
            height: parent.height - Theme.paddingMedium * 2

            fillMode: Image.PreserveAspectFit
            source: ""

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: horizontalImage.width
                    height: horizontalImage.height
                    radius: 10
                }
            }

            BusyIndicator {
                size: BusyIndicatorSize.Medium
                anchors.centerIn: horizontalImage
                running: horizontalImage.status != Image.Ready
            }
        }

        Column {
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: horizontalImage.right
                right: parent.right

                leftMargin: Theme.paddingMedium
            }

            Label {
                id: horizontalLabel
                topPadding: -Theme.paddingSmall

                width: parent.width - horizontalImage.width - Theme.paddingMedium
                text: qsTr("Last updated")
                font: Theme.fontSizeSmall
            }

            Text {
                id: horizontalName

                width: parent.width
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
                text: qsTr("How anime sounds!")
            }
        }
    }

    /*CoverTemplate {
        objectName: "applicationCover"
        primaryText: "AniLibria"
        secondaryText: "Так звучит аниме!"
        icon {
            source: Qt.resolvedUrl("../icons/AniClient.svg")
            sourceSize { width: icon.width; height: icon.height }
        }
    }*/
}
