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
        headerText: jsonData.name.main

        AppBarSpacer {}

        AppBarButton {
            text: jsonData.added_in_users_favorites
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
                source: 'https://api.anilibria.app' + jsonData.poster.optimized.src
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
                text: jsonData.name.main
            }

            Label {
                width: parent.width
                text: jsonData.name.english
            }

            Label {
                color: Theme.secondaryColor
                text: qsTr("Updated") + " " + jsonData.updated_at
            }

            RowLayout {
                Label {
                    text: qsTr("Season:")
                }

                Label {
                    color: Theme.secondaryColor
                    text: jsonData.year + " " + jsonData.season.description;
                }
            }

            RowLayout {
                Label {
                    text: qsTr("Type:")
                }

                Label {
                    color: Theme.secondaryColor
                    text: jsonData.type.description
                }
            }

            RowLayout {
                Label {
                    text: qsTr("Genres:")
                }

                Label {
                    property string joined: jsonData.genres.map(
                                                function(genre) { return genre.name; }).join(", ")

                    color: Theme.secondaryColor
                    text: joined
                }
            }

            RowLayout {
                Label {
                    text: qsTr("Voice acting:")
                }

                Label {
                    property var kindFilter: jsonData.members.filter(function(member) {
                        return member.role.value === "voicing";
                    })

                    property string nicknames: kindFilter.map(function(member) {
                        return member.nickname;
                    }).join(", ")

                    color: Theme.secondaryColor
                    text: nicknames
                }
            }

            RowLayout {
                Label {
                    text: qsTr("Timing:")
                }

                Label {
                    property var kindFilter: jsonData.members.filter(function(member) {
                        return member.role.value === "timing";
                    })

                    property string nicknames: kindFilter.map(function(member) {
                        return member.nickname;
                    }).join(", ")

                    color: Theme.secondaryColor
                    text: nicknames
                }
            }

            RowLayout {
                Label {
                    text: qsTr("Editors:")
                }

                Label {
                    property var kindFilter: jsonData.members.filter(function(member) {
                        return member.role.value === "editing";
                    })

                    property string nicknames: kindFilter.map(function(member) {
                        return member.nickname;
                    }).join(", ")

                    color: Theme.secondaryColor
                    text: nicknames
                }
            }

            RowLayout {
                Label {
                    text: qsTr("State:")
                }

                Label {
                    color: Theme.secondaryColor
                    text: jsonData.is_ongoing ? qsTr("Ongoing") : qsTr("Finished")
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
                    property var jsonData
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
                            text: updateTime
                        }
                    }

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("PlayerPage.qml"), {jsonData: model.jsonData});
                    }
                }

                Component.onCompleted: {
                    console.log("Loading episodes")
                    for (var key in jsonData.episodes) {
                        console.log("Adding episode", jsonData.episodes[key].ordinal)
                        episodesModel.append({
                            episode: jsonData.episodes[key].ordinal,
                            updateTime: jsonData.episodes[key].updated_at,
                            name: jsonData.episodes[key].name,
                            jsonData: jsonData.episodes[key],
                        })
                    }
                }
            }
        }
    }
}
