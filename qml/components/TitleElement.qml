import QtQuick 2.0
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0

BackgroundItem {
    id: updatesItem
    height: 310

    Row {
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        Image {
            id: image
            width: 200
            height: parent.height
            fillMode: Image.PreserveAspectCrop
            source: model.image

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: image.width
                    height: image.height
                    radius: 10
                }
            }

            BusyIndicator {
                size: BusyIndicatorSize.Medium
                anchors.centerIn: image
                running: image.status != Image.Ready
            }
        }

        Column {
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: image.right
                right: parent.right

                topMargin: -Theme.paddingSmall
                bottomMargin: -Theme.paddingSmall
                leftMargin: Theme.paddingMedium
            }

            Label {
                id: name
                width: parent.width
                text: model.name
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall
            }

            Text {
                width: parent.width
                anchors {
                    top: name.bottom
                    bottom: parent.bottom
                }

                color: Theme.secondaryColor
                text: model.description
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }

    onClicked: {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", 'https://api.remanga.org/api/v2/titles/' + model.id + '/', true);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var jsonResponse = JSON.parse(xhr.responseText);
                    pageStack.push(Qt.resolvedUrl("../pages/TitlePage.qml"), {jsonData: jsonResponse})
                }
            }
        };

        xhr.send();
    }
}
