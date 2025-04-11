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
                var page = Qt.createComponent("SearchPage.qml").createObject(this, {});
                pageStack.push(page)
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
                hint: "@erhoof"
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
                text: qsTr("Changes")
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
                    property var jsonData
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
                        var page = Qt.createComponent("TitlePage.qml")
                            .createObject(this, {jsonData: model.jsonData});

                        pageStack.push(page)
                    }
                }

                Component.onCompleted: {
                    var xhr = new XMLHttpRequest();
                    xhr.open("GET", 'https://api.anilibria.tv/v3/title/changes?limit=6', true);

                    xhr.onreadystatechange = function() {
                        if (xhr.readyState === XMLHttpRequest.DONE) {
                            if (xhr.status === 200) {
                                var jsonResponse = JSON.parse(xhr.responseText);
                                for (var key in jsonResponse.list) {
                                    upcomingModel.append({
                                        image: 'https://anilibria.top' + jsonResponse.list[key].posters.medium.url,
                                        jsonData: jsonResponse.list[key],
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
                    property var jsonData
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
                        var page = Qt.createComponent("TitlePage.qml")
                            .createObject(this, {jsonData: model.jsonData});

                        pageStack.push(page)
                    }
                }

                Component.onCompleted: {
                    var xhr = new XMLHttpRequest();
                    xhr.open("GET", 'https://api.anilibria.tv/v3/title/updates?limit=5', true);

                    xhr.onreadystatechange = function() {
                        if (xhr.readyState === XMLHttpRequest.DONE) {
                            if (xhr.status === 200) {
                                var jsonResponse = JSON.parse(xhr.responseText);
                                for (var key in jsonResponse.list) {
                                    updatesModel.append({
                                        image: 'https://anilibria.top' + jsonResponse.list[key].posters.small.url,
                                        name: jsonResponse.list[key].names.en,
                                        description: jsonResponse.list[key].description,
                                        jsonData: jsonResponse.list[key],
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
