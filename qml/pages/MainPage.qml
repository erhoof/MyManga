import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1
import Aurora.Controls 1.0

Page {
    id: page
    allowedOrientations: defaultAllowedOrientations

    AppBar {
        id: appBar

        headerText: "AniLibria"

        AppBarSpacer {}

        AppBarButton {
            icon.source: "image://theme/icon-m-search"
            onClicked: {
                pageStack.push(Qt.resolvedUrl("SearchPage.qml"), {});
            }
        }

        AppBarButton {
            icon.source: "image://theme/icon-m-more"

            onClicked: popup.open()
        }

        PopupMenu {
            id: popup

            PopupMenuItem {
                text: qsTr("Profile")
                hint: "@username"
                icon.source: "image://theme/icon-m-contact"
            }

            PopupMenuDividerItem {}

            PopupMenuItem {
                text: qsTr("Favorites")
                icon.source: "image://theme/icon-m-favorite"
            }

            PopupMenuItem {
                text: qsTr("History")
                icon.source: "image://theme/icon-m-history"
            }

            PopupMenuItem {
                text: qsTr("Settings")
                icon.source: "image://theme/icon-m-setting"
            }
        }
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
            spacing: Theme.paddingMedium

            SectionHeader {
                id: upcomingHeader
                anchors {
                    left: parent.left
                    right: parent.right
                }
                horizontalAlignment: Qt.AlignLeft
                text: qsTr("Today")
            }

            SilicaListView {
                id: upcomingListView

                height: 300
                anchors {
                    left: parent.left
                    right: parent.right
                }

                spacing: Theme.paddingMedium
                orientation: ListView.Horizontal
                clip: true

                HorizontalScrollDecorator { flickable: upcomingListView }

                model: ListModel {
                    id: upcomingModel
                    property var image
                    property var id
                }
                delegate: BackgroundItem {
                    id: upcomingItem

                    width: 200
                    height: parent.height

                    Image {
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        source: model.image
                        clip: true
                    }

                    onClicked: {
                        var xhr = new XMLHttpRequest();
                        xhr.open("GET", 'https://api.anilibria.app/api/v1/anime/releases/' + model.id, true);

                        xhr.onreadystatechange = function() {
                            if (xhr.readyState === XMLHttpRequest.DONE) {
                                if (xhr.status === 200) {
                                    var jsonResponse = JSON.parse(xhr.responseText)
                                    pageStack.push(Qt.resolvedUrl("TitlePage.qml"), {jsonData: jsonRespponse})
                                }
                            }
                        };

                        xhr.send();
                    }
                }

                Component.onCompleted: {
                    var xhr = new XMLHttpRequest();
                    xhr.open("GET", 'https://api.anilibria.app/api/v1/anime/schedule/now', true);

                    xhr.onreadystatechange = function() {
                        if (xhr.readyState === XMLHttpRequest.DONE) {
                            if (xhr.status === 200) {
                                var jsonResponse = JSON.parse(xhr.responseText);
                                for (var key in jsonResponse.today) {
                                    upcomingModel.append({
                                        image: 'https://api.anilibria.app' + jsonResponse.today[key].release.poster.optimized.src,
                                        id: jsonResponse.today[key].release.id,
                                    })
                                }
                            }
                        }
                    };

                    xhr.send();
                }
            }

            SecondaryButton {
                id: scheduleButton
                preferredWidth: parent.width
                text: qsTr("Schedule")
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
                        text: qsTr("Now all ways to support us are available")
                    }
                }

                Icon {
                    Layout.alignment: Qt.AlignRight
                    source: "image://theme/icon-m-battery-saver"
                }
            }

            SectionHeader {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                horizontalAlignment: Qt.AlignLeft
                text: qsTr("Updates")
            }

            SecondaryButton {
                id: randomTitleButton
                preferredWidth: parent.width
                text: qsTr("Random Title")
            }

            ListView {
                id: updatesListView

                anchors {
                    left: parent.left
                    right: parent.right
                }

                spacing: Theme.paddingMedium
                height: contentHeight

                clip: true

                model: ListModel {
                    id: updatesModel
                    property var image
                    property var name
                    property var description
                    property var id
                }
                delegate: BackgroundItem {
                    id: updatesItem
                    width: parent.width
                    height: 300
                    clip: true

                    Row {
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        height: parent.height

                        Image {
                            id: image
                            width: 200
                            height: parent.height
                            fillMode: Image.PreserveAspectCrop
                            source: model.image
                        }

                        Column {
                            anchors {
                                left: image.right
                                right: parent.right

                                leftMargin: Theme.paddingMedium
                            }

                            Label {
                                id: name
                                width: parent.width
                                text: model.name
                            }

                            Text {
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                }

                                color: Theme.secondaryColor
                                text: model.description
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                            }
                        }
                    }

                    onClicked: {
                        var xhr = new XMLHttpRequest();
                        xhr.open("GET", 'https://api.anilibria.app/api/v1/anime/releases/' + model.id, true);

                        xhr.onreadystatechange = function() {
                            if (xhr.readyState === XMLHttpRequest.DONE) {
                                if (xhr.status === 200) {
                                    var jsonResponse = JSON.parse(xhr.responseText);
                                    pageStack.push(Qt.resolvedUrl("TitlePage.qml"), {jsonData: jsonResponse})
                                }
                            }
                        };

                        xhr.send();
                    }
                }

                Component.onCompleted: {
                    var xhr = new XMLHttpRequest();
                    xhr.open("GET", 'https://api.anilibria.app/api/v1/anime/releases/latest?limit=5', true);

                    xhr.onreadystatechange = function() {
                        if (xhr.readyState === XMLHttpRequest.DONE) {
                            if (xhr.status === 200) {
                                var jsonResponse = JSON.parse(xhr.responseText);
                                for (var key in jsonResponse) {
                                    updatesModel.append({
                                        image: 'https://api.anilibria.app/' + jsonResponse[key].poster.optimized.src,
                                        name: jsonResponse[key].name.main,
                                        description: jsonResponse[key].description,
                                        id: jsonResponse[key].id
                                    })
                                }
                            }
                        }
                    };

                    xhr.send();
                }
            }
        }
    }
}
