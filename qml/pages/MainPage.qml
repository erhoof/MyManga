import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1
import Aurora.Controls 1.0
import QtGraphicalEffects 1.0
import ru.erhoof.imagefetcher 1.0

Page {
    id: page
    allowedOrientations: defaultAllowedOrientations

    AppBar {
        id: appBar

        headerText: qsTr("My Manga")

        AppBarSpacer {}

        AppBarButton {
            icon.source: "image://theme/icon-m-search"
            onClicked: {
                pageStack.push(Qt.resolvedUrl("SearchPage.qml"), {});
            }
        }

        AppBarButton {
            icon.source: "image://theme/icon-m-more"

            onClicked: {
                cacheItem.hint = qsTr("Using") + " " + (Math.round(pageFetcher.getCacheSize()* 100) / 100) + " MB";
                popup.open()
            }
        }

        PopupMenu {
            id: popup

            PopupMenuItem {
                text: qsTr("Profile")
                hint: "@username"
                icon.source: "image://theme/icon-m-contact"
                enabled: false
            }

            PopupMenuDividerItem {}

            PopupMenuItem {
                id: cacheItem
                text: qsTr("Remove cache")

                icon.source: "image://theme/icon-m-delete"

                PageFetcher {
                    id: pageFetcher
                }

                Component {
                    id: cacheDialog

                    Dialog {
                        DialogHeader {
                            id: header
                            title: qsTr("Cache cleaning")
                        }
                        Label {
                            text: qsTr("Delete all cached files?")
                            anchors.top: header.bottom
                            x: Theme.horizontalPageMargin
                            color: Theme.highlightColor
                        }

                        onDone: {
                            if (result == DialogResult.Accepted) {
                                pageFetcher.purgeCache();
                                cacheItem.hint = qsTr("Using") + " " + (Math.round(pageFetcher.getCacheSize()* 100) / 100) + " MB";
                            }
                        }
                    }
                }

                onClicked: {
                    pageStack.push(cacheDialog)
                }
            }

            PopupMenuItem {
                text: qsTr("Favorites")
                icon.source: "image://theme/icon-m-favorite"
                enabled: false
            }

            PopupMenuItem {
                text: qsTr("History")
                icon.source: "image://theme/icon-m-history"
                enabled: false
            }

            PopupMenuItem {
                text: qsTr("Settings")
                icon.source: "image://theme/icon-m-setting"
                enabled: false
            }
        }
    }

    onStatusChanged: {
        if (PageStatus.Activating == status) {
            favoritesSlider.item.update()
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

            Loader {
                id: favoritesSlider
                source: "../components/TitleSlider.qml"
                anchors {
                    left: parent.left
                    right: parent.right
                }

                onLoaded: {
                    item.sliderTitle = qsTr("Favorites")
                    item.sliderID = ""
                    item.sliderType = "favorites"
                }
            }

            Loader {
                source: "../components/TitleSlider.qml"
                anchors {
                    left: parent.left
                    right: parent.right
                }

                onLoaded: {
                    item.sliderTitle = qsTr("Popular")
                    item.sliderID = "popular-anime"
                    item.update()
                }
            }

            Loader {
                source: "../components/TitleSlider.qml"
                anchors {
                    left: parent.left
                    right: parent.right
                }

                onLoaded: {
                    item.sliderTitle = qsTr("Trending")
                    item.sliderID = "35"
                    item.update()
                }
            }

            Loader {
                source: "../components/TitleSlider.qml"
                anchors {
                    left: parent.left
                    right: parent.right
                }

                onLoaded: {
                    item.sliderTitle = qsTr("New Chapters")
                    item.sliderID = "26"
                    item.update()
                }
            }

            Loader {
                source: "../components/TitleSlider.qml"
                anchors {
                    left: parent.left
                    right: parent.right
                }

                onLoaded: {
                    item.sliderTitle = qsTr("New Season")
                    item.sliderID = "20"
                    item.update()
                }
            }

            Loader {
                source: "../components/TitleSlider.qml"
                anchors {
                    left: parent.left
                    right: parent.right
                }

                onLoaded: {
                    item.sliderTitle = qsTr("Top Manhwa - Korea")
                    item.sliderID = "26"
                    item.update()
                }
            }

            Loader {
                source: "../components/TitleSlider.qml"
                anchors {
                    left: parent.left
                    right: parent.right
                }

                onLoaded: {
                    item.sliderTitle = qsTr("Top Manga - Japan")
                    item.sliderID = "18"
                    item.update()
                }
            }

            Loader {
                source: "../components/TitleSlider.qml"
                anchors {
                    left: parent.left
                    right: parent.right
                }

                onLoaded: {
                    item.sliderTitle = qsTr("Top Manhua - China")
                    item.sliderID = "16"
                    item.update()
                }
            }

            /*RowLayout {
                width: parent.width

                Column {
                    Layout.fillWidth: true

                    Label {
                        text: qsTr("Support ReManga")
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
            }*/
        }
    }
}
