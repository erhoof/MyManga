import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1
import Aurora.Controls 1.0
import QtGraphicalEffects 1.0
import ru.erhoof.imagefetcher 1.0

Page {
    id: page

    allowedOrientations: defaultAllowedOrientations

    property var jsonData

    onStatusChanged: {
        if (PageStatus.Activating == status) {
            startReadingButton.updateButton()
        }
    }

    AppBar {
        id: appBar
        headerText: jsonData.main_name

        AppBarSpacer {}

        AppBarButton {
            property var isFavorite
            text: jsonData.count_bookmarks

            PageFetcher {
                id: pageFetcher
            }

            Component.onCompleted: {
                isFavorite = pageFetcher.isFavorite(jsonData.dir)
                if(isFavorite) {
                    icon.source = "image://theme/icon-m-favorite-selected"
                } else {
                    icon.source = "image://theme/icon-m-favorite"
                }
            }

            onClicked: {
                isFavorite = !isFavorite
                pageFetcher.setFavorite(jsonData.dir, isFavorite, jsonData.cover.low);
                if(isFavorite) {
                    icon.source = "image://theme/icon-m-favorite-selected"
                } else {
                    icon.source = "image://theme/icon-m-favorite"
                }
            }
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
                    id: startReadingButton
                    Layout.fillWidth: true
                    text: qsTr("Start reading")
                    enabled: false

                    property int savedID: 0
                    property int savedPage: 0

                    onClicked: {
                        var id = savedID;
                        if(!savedID) {
                            if(!chaptersModel.count) {
                                return
                            }

                            id = chaptersModel.get(0).id
                        }

                        var xhr = new XMLHttpRequest();
                        xhr.open("GET", 'https://api.remanga.org/api/v2/titles/chapters/' + id, true)

                        xhr.onreadystatechange = function() {
                            if (xhr.readyState === XMLHttpRequest.DONE) {
                                if (xhr.status === 200) {
                                    var jsonResponse = JSON.parse(xhr.responseText);
                                    pageStack.push(Qt.resolvedUrl("PlayerPage.qml"),
                                                   {jsonData: page.jsonData,
                                                    chapterJsonData: jsonResponse,
                                                    requestedPage: savedPage
                                                   });
                                }
                            }
                        };

                        xhr.send();
                    }

                    function updateButton() {
                        var status = pageFetcher.getReadStatus(jsonData.id)
                        if(!status.status) {
                            text = qsTr("Start reading");
                            return;
                        }

                        text = qsTr("Continue")
                                + " - "
                                + qsTr("Tome") + " " + status.status.tome
                                + ", " + qsTr("Chapter") + " " + status.status.chapter;

                        savedID = status.status.branchID
                        savedPage = status.status.page
                    }
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

            RowLayout {
                id: pageRow
                width: parent.width
                spacing: Theme.paddingMedium
                Layout.alignment: Qt.AlignRight

                property int currentPage: 0
                property int lastPage: 0

                Label {
                    id: pageLabel
                    Layout.fillWidth: true
                    text: qsTr("Updating count")
                }

                IconButton {
                    icon.source: "image://theme/icon-m-previous"
                    enabled: (pageRow.currentPage !== 0)

                    onClicked: {
                        chaptersModel.clear()
                        pageRow.currentPage -= 1

                        chaptersListView.fillChaptersPage(pageRow.currentPage + 1)
                    }
                }

                IconButton {
                    icon.source: "image://theme/icon-m-next"
                    enabled: ((pageRow.lastPage - 1) !== pageRow.currentPage)

                    onClicked: {
                        chaptersModel.clear()
                        pageRow.currentPage += 1

                        chaptersListView.fillChaptersPage(pageRow.currentPage + 1)
                    }
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
                    property var name
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
                                                    chapterJsonData: jsonResponse,
                                                    requestedPage: 0
                                                   });
                                }
                            }
                        };

                        xhr.send();
                    }
                }

                function fillChaptersPage(page) {
                    pageLabel.text = qsTr("Page") + " " + (pageRow.currentPage + 1) + " / " + pageRow.lastPage
                    console.log("page", page)

                    var xhr = new XMLHttpRequest();
                    xhr.open("GET",
                             'https://api.remanga.org/api/v2/titles/chapters/?branch_id=' + jsonData.branches[0].id
                             + '&ordering=index&count=20' + "&page=" + page, true);

                    xhr.onreadystatechange = function() {
                        if (xhr.readyState === XMLHttpRequest.DONE) {
                            if (xhr.status === 200) {
                                var jsonResponse = JSON.parse(xhr.responseText);
                                for (var key in jsonResponse.results) {
                                    chaptersModel.append({
                                        id: jsonResponse.results[key].id,
                                        name: jsonResponse.results[key].name,
                                        index: jsonResponse.results[key].index,
                                        chapter: jsonResponse.results[key].chapter,
                                        tome: jsonResponse.results[key].tome,
                                        uploadDate: jsonResponse.results[key].upload_date
                                    })                                    
                                }

                                if(jsonResponse.results) {
                                    startReadingButton.enabled = true
                                }

                                if(jsonResponse.next) {
                                    //fillChaptersPage(jsonResponse.next)
                                    //return jsonResponse.next
                                }
                            }
                        }
                    };

                    xhr.send();
                }

                Component.onCompleted: {
                    pageRow.lastPage = jsonData.branches[0].count_chapters / 20
                    fillChaptersPage(1);
                }
            }
        }
    }
}
