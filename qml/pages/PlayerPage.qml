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
    property int currentImage: 0

    // 0 - fullscreen, 1 - zoom right, 2 - zoom left, 3 - webtoon
    property int viewMode: 0
    property int requestedViewMode: 0

    Component.onCompleted: {
        currentPage = requestedPage
        viewMode = requestedViewMode;

        if(viewMode === 0) {
            viewFullScreen.checked = true
        } else if(viewMode === 1) {
            viewZoom.checked = true
        } else if(viewMode === 2) {
            viewZoomComics.checked = true
        } else if(viewMode === 3) {
            viewWebtoon.checked = true
        }

        page.updateImage(currentPage);
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
            icon.source: "image://theme/icon-m-setting"

            PopupMenu {
                id: settingsPopup
                headerText: qsTr("Settings")

                PopupSubMenuItem {
                    id: viewModeSubmenu
                    text: qsTr("View mode")

                    function modeUpdated(mode) {
                        switch (mode) {
                        case 0:
                            viewZoom.checked = false
                            viewZoomComics.checked = false
                            viewWebtoon.checked = false
                            break
                        case 1:
                            viewFullScreen.checked = false
                            viewZoomComics.checked = false
                            viewWebtoon.checked = false
                            break
                        case 2:
                            viewFullScreen.checked = false
                            viewZoom.checked = false
                            viewWebtoon.checked = false
                            break
                        case 3:
                            viewFullScreen.checked = false
                            viewZoom.checked = false
                            viewZoomComics.checked = false
                            break
                        }

                        viewMode = mode
                        pageFetcher.setReadStatus(jsonData.id, chapterJsonData.id, chapterJsonData.tome, chapterJsonData.chapter, currentPage, viewMode)
                    }

                    PopupMenuCheckableItem {
                        id: viewFullScreen
                        text: qsTr("Full screen")
                        hint: qsTr("For large tablets")

                        onClicked: {
                            if(!checked) {
                                viewModeSubmenu.modeUpdated(0)
                            }
                        }
                    }

                    PopupMenuCheckableItem {
                        id: viewZoom
                        text: qsTr("Zoomable (Right)")
                        hint: qsTr("Starts top-right, manga")

                        onClicked: {
                            if(!checked) {
                                viewModeSubmenu.modeUpdated(1)
                            }
                        }
                    }

                    PopupMenuCheckableItem {
                        id: viewZoomComics
                        text: qsTr("Zoomable (Left)")
                        hint: qsTr("Starts top-left, comics")

                        onClicked: {
                            if(!checked) {
                                viewModeSubmenu.modeUpdated(2)
                            }
                        }
                    }

                    PopupMenuCheckableItem {
                        id: viewWebtoon
                        text: qsTr("Webtoon")
                        hint: qsTr("For pages with large height")

                        onClicked: {
                            if(!checked) {
                                viewModeSubmenu.modeUpdated(3)
                            }
                        }
                    }
                }
            }

            onClicked: {
                settingsPopup.open()
            }
        }

        AppBarButton {
            icon.source: "image://theme/icon-m-previous"
            enabled: (currentPage !== 0)

            onClicked: {
                currentPage -= 1
                currentImage = 0
                page.updateImage(currentPage)
            }
        }

        AppBarButton {
            icon.source: "image://theme/icon-m-next"
            enabled: (currentPage !== (chapterJsonData.pages.length - 1))

            onClicked: {
                currentPage += 1
                currentImage = 0
                page.updateImage(currentPage)
            }
        }
    }

    function updateImage(id) {
        //if(viewMode !== 3) {
            var url = chapterJsonData.pages[currentPage][currentImage].link;
            pageFetcher.requestPage(url);
        /*} else {
            for (var key in chapterJsonData.pages[currentPage]) {
                var webUrl = chapterJsonData.pages[currentPage][key].link;
                pageFetcher.requestPage(webUrl);
            }
        }*/

        pageFetcher.setReadStatus(jsonData.id, chapterJsonData.id, chapterJsonData.tome, chapterJsonData.chapter, currentPage, viewMode)
    }

    MouseArea {
        id: fullScreenArea
        visible: viewMode === 0

        anchors {
            top: appBar.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        Image {
            id: pageImageFullScreen
            source: ""
            fillMode: Image.PreserveAspectFit
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
        }

        onClicked: {
            if(mouse.x > fullScreenArea.width / 2) {
                if(!(currentPage !== (chapterJsonData.pages.length - 1))) {
                    return
                }

                currentPage += 1
                currentImage = 0
            } else {
                if(currentPage === 0) {
                    return
                }

                currentPage -= 1
                currentImage = 0
            }

            page.updateImage(currentPage)
        }
    }

    Flickable {
        id: flickableZoom
        visible: (viewMode === 1) || (viewMode === 2)

        anchors {
            top: appBar.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        contentWidth: Math.max(pageImageZoom.width * pageImageZoom.scale, width)
        contentHeight: Math.max(pageImageZoom.height * pageImageZoom.scale, height)

        Image {
            id: pageImageZoom
            width: page.width
            height: page.height - appBar.height
            fillMode: Image.PreserveAspectFit

            x: ( scale - 1 ) * width * 0.5
            y: ( scale - 1 ) * height * 0.5
        }

        PinchArea {
            id: pinchArea
            anchors.fill: parent
            pinch.target: pageImageZoom
            pinch.minimumScale: 1
            pinch.maximumScale: 2

            MouseArea {
                id: mousearea
                anchors.fill: parent
                onDoubleClicked: {
                    if (pageImageZoom.scale < 2) {
                        zoom_animator.from = pageImageZoom.scale;
                        zoom_animator.to = pageImageZoom.scale + 1;
                        zoom_animator.start()
                    } else if (pageImageZoom.scale >= 2) {
                        zoom_animator.from = pageImageZoom.scale;
                        zoom_animator.to = 1;
                        zoom_animator.start()
                    }
                }
            }
        }

        NumberAnimation {
            id: zoom_animator
            target: pageImageZoom
            property: "scale"
            running: false
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    //SilicaListView {
    SilicaFlickable {
        id: flickableWebtoon
        visible: (viewMode === 3)

        anchors {
            top: appBar.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        //contentWidth: Math.max(pageImageZoom.width * pageImageZoom.scale, width)
        contentHeight: Math.max(pageImageWebtoon.height * pageImageWebtoon.scale, height)

        //contentHeight: pageImageWebtoon.height

        /*function updateHeight() {
            var totalHeight = 0;
            console.log(model.count)
            for (var i = 0; i < model.count; i++) {
               totalHeight += model.get(i).height;
            }
            console.log(totalHeight)
            contentHeight = totalHeight
        }

        model: ListModel {
            id: webtoonModel
            property var image
            property var height
        }
        delegate: Image {
            id: pageImageWebtoon
            scale: 1//flickableWebtoon.width / pageImageWebtoon.width
            source: model.image
            //height: pageImageWebtoon.height * pageImageWebtoon.scale
            //width: flickableWebtoon.width
            //height: width * (height / width)
            fillMode: Image.PreserveAspectFit

            x: ( scale - 1 ) * width * 0.5
            y: ( scale - 1 ) * height * 0.5

            onStatusChanged: {
                console.log("loading image", source)
                if (status === Image.Ready) {
                    model.height = height * scale
                    console.log("setting height", model.height)
                    flickableWebtoon.updateHeight()
                    //flickableWebtoon.contentHeight = flickableWebtoon.contentHeight + height * scale
                }
            }
        }*/

        Image {
            id: pageImageWebtoon
            scale: flickableWebtoon.width / pageImageWebtoon.width
            fillMode: Image.PreserveAspectFit

            x: ( scale - 1 ) * width * 0.5
            y: ( scale - 1 ) * height * 0.5
        }

        PushUpMenu {
            id: pushUpMenu
            quickSelect: true

            MenuItem {
                text: qsTr("Previous image")
                enabled: (currentImage !== 0)

                onClicked: {
                    currentImage -= 1
                    console.log(currentImage)
                    pushUpMenu.cancelBounceBack()
                    page.updateImage(currentPage)
                }
            }

            MenuItem {
                text: qsTr("Next image")
                enabled: (currentImage !== (chapterJsonData.pages[currentPage].length - 1))

                onClicked: {
                    currentImage += 1
                    console.log(currentImage)
                    pushUpMenu.cancelBounceBack()
                    page.updateImage(currentPage)
                }
            }

            bottomMargin: 0
            MenuLabel { text: (currentImage + 1) + ' / ' + chapterJsonData.pages[currentPage].length }
        }
    }

    PageFetcher {
        id: pageFetcher
        onPageFetched: {
            /*if(viewMode === 3) {
                flickableWebtoon.model.append({
                    image: path,
                    height: 0
                })
                return
            }*/

            pageImageFullScreen.source = path

            pageImageZoom.source = path
            flickableZoom.contentY = 0
            if(pageImageZoom.scale > 1 && viewMode === 1) // japan
                flickableZoom.contentX = pageImageZoom.width
            else if(pageImageZoom.scale > 1 && viewMode === 2) // comics
                flickableZoom.contentX = 0
            //pageImageZoom.scale = 1

            flickableWebtoon.contentY = 0
            pageImageWebtoon.source = path
        }
    }
}
