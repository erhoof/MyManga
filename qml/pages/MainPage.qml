import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1
import Aurora.Controls 1.0
import QtGraphicalEffects 1.0

Page {
    id: page
    allowedOrientations: defaultAllowedOrientations

    AppBar {
        id: appBar

        headerText: qsTr("AniLibria")

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
            spacing: Theme.paddingLarge

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
                        id: todayImage
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        source: model.image
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: todayImage.width
                                height: todayImage.height
                                radius: 10
                            }
                        }

                        BusyIndicator {
                            size: BusyIndicatorSize.Medium
                            anchors.centerIn: todayImage
                            running: todayImage.status != Image.Ready
                        }
                    }

                    onClicked: {
                        var xhr = new XMLHttpRequest();
                        xhr.open("GET", 'https://api.anilibria.app/api/v1/anime/releases/' + model.id, true);

                        xhr.onreadystatechange = function() {
                            if (xhr.readyState === XMLHttpRequest.DONE) {
                                if (xhr.status === 200) {
                                    var jsonResponse = JSON.parse(xhr.responseText)
                                    pageStack.push(Qt.resolvedUrl("TitlePage.qml"), {jsonData: jsonResponse})
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

            Button {
                id: scheduleButton
                preferredWidth: parent.width
                text: qsTr("Schedule")
                icon.source: "image://theme/icon-m-date"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("SchedulePage.qml"), {})
                }
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

            Button {
                id: randomTitleButton
                preferredWidth: parent.width
                text: qsTr("Random Title")
                icon.source: "image://theme/icon-m-shuffle"

                onClicked: {
                    var xhr = new XMLHttpRequest();
                    xhr.open("GET", 'https://api.anilibria.app/api/v1/anime/releases/random?limit=1', true);

                    xhr.onreadystatechange = function() {
                        if (xhr.readyState === XMLHttpRequest.DONE) {
                            if (xhr.status === 200) {
                                var jsonResponse = JSON.parse(xhr.responseText)

                                var xhrTitle = new XMLHttpRequest();
                                xhrTitle.open("GET", 'https://api.anilibria.app/api/v1/anime/releases/' + jsonResponse[0].id, true);

                                xhrTitle.onreadystatechange = function() {
                                    if (xhrTitle.readyState === XMLHttpRequest.DONE) {
                                        if (xhrTitle.status === 200) {
                                            var jsonResponse = JSON.parse(xhrTitle.responseText);
                                            pageStack.push(Qt.resolvedUrl("TitlePage.qml"), {jsonData: jsonResponse})
                                        }
                                    }
                                };

                                xhrTitle.send();
                            }
                        }
                    };

                    xhr.send();
                }
            }

            /*Rectangle {
                width: parent.width
                opacity: 0
                height: 0.1
            }*/

            ListView {
                id: updatesListView

                anchors {
                    left: parent.left
                    right: parent.right
                }

                spacing: Theme.paddingLarge
                height: contentHeight

                model: ListModel {
                    id: updatesModel
                    property var image
                    property var name
                    property var description
                    property var id
                }

                delegate: Loader {
                    width: parent.width
                    source: "../components/TitleElement.qml"
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
