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

            Component.onCompleted: focus = true

            EnterKey.onClicked: {
                searchModel.clear()

                var xhr = new XMLHttpRequest();
                xhr.open("GET", 'https://api.anilibria.app/api/v1/app/search/releases?query=' + searchField.text, true);

                xhr.onreadystatechange = function() {
                    if (xhr.readyState === XMLHttpRequest.DONE) {
                        if (xhr.status === 200) {
                            var jsonResponse = JSON.parse(xhr.responseText);
                            for (var key in jsonResponse) {
                                searchModel.append({
                                    image: 'https://api.anilibria.app' + jsonResponse[key].poster.optimized.src,
                                    name: jsonResponse[key].name.main,
                                    description: jsonResponse[key].description,
                                    id: jsonResponse[key].id
                                })
                            }
                        }
                    }
                };

                xhr.send();
                focus = false;
            }
        }

        AppBarButton {
            icon.source: "image://theme/icon-m-filter"
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
            property var id
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
    }
}
