import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1
import Aurora.Controls 1.0
import QtMultimedia 5.6
import ru.erhoof.imagefetcher 1.0

Page {
    id: page
    allowedOrientations: defaultAllowedOrientations
    //showNavigationIndicator: false

    property var jsonData
    property var chapterJsonData
    property var requestedPage

    property var currentPage

    Component.onCompleted: {
        currentPage = requestedPage
        pageImage.updateImage(currentPage);
    }

    AppBar {
        id: appBar

        headerText: jsonData.main_name
        subHeaderText: qsTr("Chapter") + " " + chapterJsonData.chapter
                       + " (" + qsTr("Tome") + " " + chapterJsonData.tome + ")"

        AppBarSpacer {}

        AppBarButton {
            text: (currentPage + 1) + " / " + chapterJsonData.pages.length
        }

        AppBarSpacer {}

        AppBarButton {
            icon.source: "image://theme/icon-m-previous"
            enabled: (currentPage !== 0)

            onClicked: {
                currentPage -= 1
                pageImage.updateImage(currentPage)
            }
        }

        AppBarButton {
            icon.source: "image://theme/icon-m-next"
            enabled: (currentPage !== (chapterJsonData.pages.length - 1))

            onClicked: {
                currentPage += 1
                pageImage.updateImage(currentPage)
            }
        }
    }

    /*SilicaFlickable {
        id: pageFlickable

        anchors {
            top: appBar.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right

            //margins: Theme.horizontalPageMargin
        }

        //width: contentWidth
        contentHeight: pageImage.height

        //clip: true

        VerticalScrollDecorator { flickable: pageImage }*/

        MouseArea {
            id: area
            anchors {
                top: appBar.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }

            Image {
                id: pageImage
                source: ""
                fillMode: Image.PreserveAspectFit
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }

                function updateImage(id) {
                    var url = chapterJsonData.pages[currentPage][0].link;
                    pageFetcher.requestPage(url);

                    pageFetcher.setReadStatus(jsonData.id, chapterJsonData.id, chapterJsonData.tome, chapterJsonData.chapter, currentPage)
                }
            }

            onClicked: {
                if(mouse.x > area.width / 2) {
                    if(!(currentPage !== (chapterJsonData.pages.length - 1))) {
                        return
                    }

                    currentPage += 1
                } else {
                    if(currentPage === 0) {
                        return
                    }

                    currentPage -= 1
                }

                pageImage.updateImage(currentPage)
            }
        }
    //}

    PageFetcher {
        id: pageFetcher
        onPageFetched: {
            pageImage.source = path;
            //pageFlickable.contentHeight = pageImage.sourceSize.height
            //pageFlickable.scrollToTop()
        }
    }
}
