import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1
import Aurora.Controls 1.0
import QtGraphicalEffects 1.0

Page {
    id: page
    allowedOrientations: defaultAllowedOrientations

    Component.onCompleted: {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", 'https://api.anilibria.app/api/v1/anime/schedule/now', true);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var jsonResponse = JSON.parse(xhr.responseText);
                    for (var key in jsonResponse.today) {
                        todayModel.append({
                            image: 'https://api.anilibria.app/' + jsonResponse.today[key].release.poster.optimized.src,
                            name: jsonResponse.today[key].release.name.main,
                            description: jsonResponse.today[key].release.description,
                            id: jsonResponse.today[key].release.id
                        })
                    }
                    for (key in jsonResponse.tomorrow) {
                        tomorrowModel.append({
                            image: 'https://api.anilibria.app/' + jsonResponse.tomorrow[key].release.poster.optimized.src,
                            name: jsonResponse.tomorrow[key].release.name.main,
                            description: jsonResponse.tomorrow[key].release.description,
                            id: jsonResponse.tomorrow[key].release.id
                        })
                    }
                    for (key in jsonResponse.yesterday) {
                        yesterdayModel.append({
                            image: 'https://api.anilibria.app/' + jsonResponse.yesterday[key].release.poster.optimized.src,
                            name: jsonResponse.yesterday[key].release.name.main,
                            description: jsonResponse.yesterday[key].release.description,
                            id: jsonResponse.yesterday[key].release.id
                        })
                    }
                }
            }
        };

        xhr.send();
    }

    AppBar {
        id: appBar

        headerText: qsTr("Schedule")
    }

    SilicaFlickable {
        id: mainFlickable

        anchors {
            top: appBar.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right

            leftMargin: Theme.horizontalPageMargin
        }

        contentHeight: column.height + Theme.paddingLarge

        VerticalScrollDecorator { flickable: column }

        Column {
            id: column
            width: parent.width - Theme.horizontalPageMargin
            spacing: Theme.paddingLarge

            SectionHeader {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                horizontalAlignment: Qt.AlignLeft
                text: qsTr("Today")
            }

            ListView {
                id: todayList
                anchors {
                    left: parent.left
                    right: parent.right
                }

                spacing: Theme.paddingLarge
                height: contentHeight

                model: ListModel {
                    id: todayModel
                    property var image
                    property var name
                    property var description
                    property var id
                }

                delegate: Loader {
                    width: parent.width
                    source: "../components/TitleElement.qml"
                }
            }

            SectionHeader {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                horizontalAlignment: Qt.AlignLeft
                text: qsTr("Tomorrow")
            }

            ListView {
                anchors {
                    left: parent.left
                    right: parent.right
                }

                spacing: Theme.paddingLarge
                height: contentHeight

                model: ListModel {
                    id: tomorrowModel
                    property var image
                    property var name
                    property var description
                    property var id
                }

                delegate: Loader {
                    width: parent.width
                    source: "../components/TitleElement.qml"
                }
            }

            SectionHeader {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                horizontalAlignment: Qt.AlignLeft
                text: qsTr("Yesterday")
            }

            ListView {
                anchors {
                    left: parent.left
                    right: parent.right
                }

                spacing: Theme.paddingLarge
                height: contentHeight

                model: ListModel {
                    id: yesterdayModel
                    property var image
                    property var name
                    property var description
                    property var id
                }

                delegate: Loader {
                    width: parent.width
                    source: "../components/TitleElement.qml"
                }
            }
        }
    }
}
