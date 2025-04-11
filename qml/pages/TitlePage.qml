import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1
import QtMultimedia 5.6
import Aurora.Controls 1.0

Page {
    id: page

    allowedOrientations: defaultAllowedOrientations

    property var jsonData

    AppBar {
        id: appBar
        headerText: jsonData.names.ru

        AppBarSpacer {}

        AppBarButton {
            text: jsonData.in_favorites
            icon.source: "image://theme/icon-m-favorite"
        }

        AppBarButton {
            icon.source: "image://theme/icon-m-more"
        }
    }

    SilicaFlickable {
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
            spacing: Theme.paddingMedium
            clip: true

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: 'https://anilibria.top' + jsonData.posters.medium.url
            }

            RowLayout {
                width: parent.width

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Start watching")

                    onClicked: {
                        for (var key in jsonData.player.list) {
                            var page = Qt.createComponent("PlayerPage.qml")
                                .createObject(this, {jsonData: jsonData, episodeJsonData: jsonData.player.list[key]});
                            pageStack.push(page)
                            break;
                        }
                    }
                }

                Button {
                    icon.source: "image://theme/icon-s-more"
                }
            }

            Label {
                width: parent.width
                text: jsonData.names.ru
            }

            Label {
                width: parent.width
                text: jsonData.names.en
            }

            Label {
                color: Theme.secondaryColor
                text: qsTr("Updated") + " " + Date(jsonData.updated * 1000).toString()
            }

            RowLayout {
                Label {
                    text: qsTr("Season:")
                }

                Label {
                    color: Theme.secondaryColor
                    text: jsonData.season.year + " " + jsonData.season.string;
                }
            }

            RowLayout {
                Label {
                    text: qsTr("Type:")
                }

                Label {
                    color: Theme.secondaryColor
                    text: jsonData.type.full_string
                }
            }

            RowLayout {
                Label {
                    text: qsTr("Genres:")
                }

                Label {
                    color: Theme.secondaryColor
                    text: jsonData.genres.join(", ")
                }
            }

            RowLayout {
                Label {
                    text: qsTr("Voice acting:")
                }

                Label {
                    color: Theme.secondaryColor
                    text: jsonData.team.voice.join(", ")
                }
            }

            RowLayout {
                Label {
                    text: qsTr("Timing:")
                }

                Label {
                    color: Theme.secondaryColor
                    text: jsonData.team.timing.join(", ")
                }
            }

            RowLayout {
                Label {
                    text: qsTr("Subtitles:")
                }

                Label {
                    color: Theme.secondaryColor
                    text: jsonData.team.translator.join(", ")
                }
            }

            RowLayout {
                Label {
                    text: qsTr("State:")
                }

                Label {
                    color: Theme.secondaryColor
                    text: jsonData.status.string
                }
            }

            Text {
                width: parent.width

                color: Theme.secondaryColor
                text: jsonData.description
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
            }

            RowLayout {
                width: parent.width

                Column {
                    Layout.fillWidth: true

                    Label {
                        text: qsTr("Support AniLibria")
                    }

                    Text {
                        color: Theme.secondaryColor
                        wrapMode: Text.WordWrap
                        text: qsTr("Liked our voice? Support us")
                    }
                }

                Icon {
                    Layout.alignment: Qt.AlignRight
                    source: "image://theme/icon-m-battery-saver"
                }
            }

            ListView {
                id: episodesListView

                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: contentHeight

                clip: true
                spacing: Theme.paddingMedium

                model: ListModel {
                    id: episodesModel
                    property var episode
                    property var updateTime
                    property var name
                    property var episodeJsonData
                }
                delegate: BackgroundItem {
                    id: episodesItem
                    width: parent.width
                    height: 100

                    Column {
                        width: parent.width

                        RowLayout {
                            width: parent.width

                            Label {
                                Layout.alignment: Qt.AlignLeft
                                text: qsTr("Episode") + " " + model.episode
                            }

                            Label {
                                Layout.alignment: Qt.AlignRight
                                text: model.name
                            }
                        }

                        Label {
                            text: Date(model.updateTime * 1000).toString()
                        }
                    }

                    onClicked: {
                        var page = Qt.createComponent("PlayerPage.qml").createObject(this, {jsonData: jsonData, episodeJsonData: episodeJsonData});
                        pageStack.push(page)
                    }
                }

                Component.onCompleted: {
                    for (var key in jsonData.player.list) {
                        console.log("add episode " + jsonData.player.list[key].name)
                        episodesModel.append({
                            episode: jsonData.player.list[key].episode,
                            updateTime: jsonData.player.list[key].created_timestamp,
                            name: jsonData.player.list[key].name,
                            episodeJsonData: jsonData.player.list[key],
                        })
                    }
                }
            }
        }
    }
}
