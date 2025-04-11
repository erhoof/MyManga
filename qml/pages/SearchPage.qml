import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1
import Aurora.Controls 1.0

import "."

Page {
    id: page

    allowedOrientations: defaultAllowedOrientations

    property var splitViewRef

    AppBar {
        id: searchHeader

        AppBarSearchField {
            id: searchField
            placeholderText: qsTr("Title name")
        }

        AppBarButton {
            icon.source: "image://theme/icon-m-search"

            onClicked: {
                searchModel.clear()

                var xhr = new XMLHttpRequest();
                xhr.open("GET", 'https://api.anilibria.tv/v3/title/search?search=' + searchField.text, true);

                xhr.onreadystatechange = function() {
                    if (xhr.readyState === XMLHttpRequest.DONE) {
                        if (xhr.status === 200) {
                            var jsonResponse = JSON.parse(xhr.responseText);
                            for (var key in jsonResponse.list) {
                                searchModel.append({
                                    image: 'https://anilibria.top' + jsonResponse.list[key].posters.small.url,
                                    name: jsonResponse.list[key].names.en,
                                    description: jsonResponse.list[key].description,
                                    titleID: jsonResponse.list[key].id
                                })
                            }
                        }
                    }
                };

                xhr.send();
            }
        }

        AppBarButton {
            icon.source: "image://theme/icon-m-filter"

            onClicked: splitView.push(searchPage)
        }
    }

    SilicaListView {
        id: searchListView

        anchors {
            top: searchHeader.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right

            margins: Theme.horizontalPageMargin
        }

        clip: true
        spacing: Theme.paddingMedium

        VerticalScrollDecorator { flickable: updatesListView }

        model: ListModel {
            id: searchModel
            property var image
            property var name
            property var description
            property var titleID
        }
        delegate: BackgroundItem {
            id: searchItem
            width: parent.width
            height: 300

            /*Row {
                height: parent.height
                anchors.fill: parent
                spacing: Theme.paddingMedium*/

                Image {
                    id: image

                    width: 200
                    height: parent.height
                    //Layout.fillHeight: true
                    fillMode: Image.PreserveAspectFit
                    source: model.image
                }

                ColumnLayout {
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: image.right
                        right: parent.right

                        leftMargin: Theme.paddingMedium
                    }

                    Label {
                        id: name
                        text: model.name
                    }

                    Text {
                        Layout.preferredWidth: parent.width
                        Layout.preferredHeight: parent.height - name.height

                        color: Theme.secondaryColor
                        text: model.description
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                    }
                //}
            }

            onClicked: {
                var xhr = new XMLHttpRequest();
                xhr.open("GET", 'https://api.anilibria.tv/v3/title?id=' + model.titleID, true);

                xhr.onreadystatechange = function() {
                    if (xhr.readyState === XMLHttpRequest.DONE) {
                        if (xhr.status === 200) {
                            var jsonResponse = JSON.parse(xhr.responseText);

                            var page = Qt.createComponent("TitlePage.qml")
                                .createObject(this, {jsonData: jsonResponse});

                            pageStack.push(page)
                        }
                    }
                };

                xhr.send();
            }
        }
    }
}
