import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1
import Aurora.Controls 1.0
import QtGraphicalEffects 1.0

Page {
    id: page

    allowedOrientations: defaultAllowedOrientations

    property var jsonData

    AppBar {
        id: appBar
        headerText: jsonData.main_name

        AppBarSpacer {}

        AppBarButton {
            text: jsonData.count_bookmarks
            icon.source: "image://theme/icon-m-favorite"
            enabled: false
        }

        AppBarButton {
            icon.source: "image://theme/icon-m-more"
            enabled: false
        }
    }

    SilicaFlickable {
        anchors {
            top: appBar.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right

            topMargin: Theme.paddingMedium
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
                id: image
                anchors.horizontalCenter: parent.horizontalCenter
                source: 'https://api.remanga.org/' + jsonData.cover.high

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

            RowLayout {
                width: parent.width
                spacing: Theme.paddingMedium

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Start reading")

                    onClicked: {
                        for (var key in jsonData.player.list) {
                            var page = Qt.createComponent("PlayerPage.qml")
                                .createObject(this, {jsonData: jsonData, episodeJsonData: jsonData.player.list[key]});
                            pageStack.push(page)
                            break;
                        }
                    }

                    enabled: false
                }

                Button {
                    icon.source: "image://theme/icon-s-more"
                    enabled: false
                }
            }

            Rectangle {
                width: parent.width
                height: infoColumn.height + Theme.paddingMedium * 1.5
                color: Qt.rgba(1, 1, 1, 0.2)
                radius: 8

                Column {
                    id: infoColumn
                    anchors.verticalCenter: parent.verticalCenter
                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: Theme.paddingMedium
                    }

                    Label {
                        width: parent.width
                        text: jsonData.main_name
                        wrapMode: Text.WordWrap
                    }

                    Label {
                        width: parent.width
                        text: jsonData.secondary_name
                        wrapMode: Text.WordWrap
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeSmall
                    }

                    RowLayout {
                        Label {
                            text: qsTr("Issue year:")
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: Theme.secondaryColor
                        }

                        Label {
                            color: Theme.secondaryHighlightColor
                            //text: Qt.formatDateTime(jsonData.branches[0].new_chapter_date, "dd MMMM yyyy, hh:mm")
                            text: jsonData.issue_year
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: Theme.paddingLarge
                        color: "transparent"
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width
                            height: 2
                            color: Theme.secondaryColor
                            opacity: 0.8
                        }
                    }

                    RowLayout {
                        Label {
                            text: qsTr("Type:")
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Label {
                            color: Theme.secondaryColor
                            text: jsonData.type.name;
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }

                    RowLayout {
                        Label {
                            text: qsTr("Rating:")
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Label {
                            color: Theme.secondaryColor
                            text: jsonData.avg_rating
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }

                    RowLayout {
                        Label {
                            text: qsTr("Age rating:")
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Label {
                            color: Theme.secondaryColor
                            text: jsonData.age_limit.name;
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }

                    RowLayout {
                        Label {
                            text: qsTr("Genres:")
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Label {
                            property string joined: jsonData.genres.map(
                                                        function(genre) { return genre.name; }).join(", ")

                            color: Theme.secondaryColor
                            text: joined
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }

                    RowLayout {
                        Label {
                            text: qsTr("Categories:")
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Label {
                            property string joined: jsonData.categories.map(
                                                        function(category) { return category.name; }).join(", ")

                            color: Theme.secondaryColor
                            text: joined
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }

                    RowLayout {
                        Label {
                            text: qsTr("State:")
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Label {
                            color: Theme.secondaryColor
                            text: jsonData.status.name
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }
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
                        text: qsTr("Support ReManga")
                    }

                    Text {
                        color: Theme.secondaryColor
                        wrapMode: Text.WordWrap
                        text: qsTr("Liked our work? Support us")
                    }
                }

                Icon {
                    Layout.alignment: Qt.AlignRight
                    source: "image://theme/icon-m-battery-saver"
                }
            }

            ListView {
                id: chaptersListView

                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: contentHeight

                clip: true
                spacing: Theme.paddingMedium

                model: ListModel {
                    id: chaptersModel
                    property var id
                    property var index
                    property var chapter
                    property var tome
                    property var uploadDate
                }
                delegate: BackgroundItem {
                    id: chaptersItem
                    width: parent.width
                    height: 100

                    Rectangle {
                        anchors.fill: parent
                        color: Qt.rgba(1, 1, 1, 0.2)
                        radius: 8

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors {
                                left: parent.left
                                right: parent.right
                                margins: Theme.paddingMedium
                            }

                            RowLayout {
                                width: parent.width

                                Label {
                                    Layout.alignment: Qt.AlignLeft
                                    text: qsTr("Chapter") + " " + model.chapter
                                }

                                Label {
                                    font.pixelSize: Theme.fontSizeSmall
                                    Layout.alignment: Qt.AlignRight
                                    text: Qt.formatDateTime(new Date(model.uploadDate), "dd MMMM yyyy, hh:mm")
                                    color: Theme.secondaryHighlightColor
                                }
                            }

                            Label {
                                text: qsTr("Tome") + " " + model.tome
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }
                    }

                    onClicked: {
                        var xhr = new XMLHttpRequest();
                        xhr.open("GET", 'https://api.remanga.org/api/v2/titles/chapters/' + model.id, true)

                        xhr.onreadystatechange = function() {
                            if (xhr.readyState === XMLHttpRequest.DONE) {
                                if (xhr.status === 200) {
                                    var jsonResponse = JSON.parse(xhr.responseText);
                                    pageStack.push(Qt.resolvedUrl("PlayerPage.qml"),
                                                   {jsonData: page.jsonData,
                                                    chapterJsonData: jsonResponse
                                                   });
                                }
                            }
                        };

                        xhr.send();
                    }
                }

                function fillChaptersPage(page) {
                    var xhr = new XMLHttpRequest();
                    xhr.open("GET",
                             'https://api.remanga.org/api/v2/titles/chapters/?branch_id=' + jsonData.branches[0].id
                             + '&ordering=index&count=10000000' + "&page=" + page, true);

                    xhr.onreadystatechange = function() {
                        if (xhr.readyState === XMLHttpRequest.DONE) {
                            if (xhr.status === 200) {
                                var jsonResponse = JSON.parse(xhr.responseText);
                                for (var key in jsonResponse.results) {
                                    console.log("Adding chapter")
                                    chaptersModel.append({
                                        id: jsonResponse.results[key].id,
                                        index: jsonResponse.results[key].index,
                                        chapter: jsonResponse.results[key].chapter,
                                        tome: jsonResponse.results[key].tome,
                                        uploadDate: jsonResponse.results[key].upload_date
                                    })
                                }

                                if(jsonResponse.next) {
                                    console.log("got next:", jsonResponse.next)
                                    return jsonResponse.next
                                } else {
                                    return -1
                                }
                            } else {
                                return -1
                            }
                        }
                    };

                    xhr.send();
                }

                Component.onCompleted: {
                    var value = fillChaptersPage(1);
                    /*while (value !== -1) {
                        console.log("value:", value);
                        value = fillChaptersPage(value);
                    }*/
                }
            }
        }
    }
}
