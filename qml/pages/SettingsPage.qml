import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1
import Aurora.Controls 1.0
import QtGraphicalEffects 1.0
import ru.erhoof.imagefetcher 1.0

Page {
    PageFetcher {
        id: pageFetcher
    }

    Component.onCompleted: {
        blacklistSwitch.checked = (pageFetcher.getSetting("tag-blacklist") === "true")
        artworkSwitch.checked = (pageFetcher.getSetting("artwork-blacklist") === "true")
        ageRatingSwitch.checked = (pageFetcher.getSetting("age-blacklist") === "true")

        removeCacheButton.value = (Math.round(pageFetcher.getCacheSize()* 100) / 100) + " MB";
    }

    AppBar {
        id: appBar
        headerText: qsTr("Settings")
    }

    Column {
        anchors {
            top: appBar.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        id: column
        width: parent.width - Theme.horizontalPageMargin
        spacing: Theme.paddingMedium

        SectionHeader {
            horizontalAlignment: Qt.AlignLeft
            text: qsTr("Content preferences")
        }

        TextSwitch {
            id: blacklistSwitch
            text: qsTr("Disable tags blacklist")
            description: qsTr("May enable explicit content")

            onCheckedChanged: {
                pageFetcher.setSetting("tag-blacklist", (checked ? "true" : "false"))
            }
        }

        TextSwitch {
            id: artworkSwitch
            text: qsTr("Disable artwork blacklist")
            description: qsTr("May enable explicit artworks")

            onCheckedChanged: {
                pageFetcher.setSetting("artwork-blacklist", (checked ? "true" : "false"))
            }
        }

        TextSwitch {
            id: ageRatingSwitch
            text: qsTr("Disable age restrictions")
            description: qsTr("May enable explicit content")

            onCheckedChanged: {
                pageFetcher.setSetting("age-blacklist", (checked ? "true" : "false"))
            }
        }

        SectionHeader {
            horizontalAlignment: Qt.AlignLeft
            text: qsTr("Remove data")
        }

        ValueButton {
            id: removeCacheButton
            label: qsTr("Pages cache")

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
                            removeCacheButton.value = (Math.round(pageFetcher.getCacheSize()* 100) / 100) + " MB";
                        }
                    }
                }
            }

            onClicked: {
                pageStack.push(cacheDialog);
            }
        }
    }
}
