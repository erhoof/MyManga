import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1
import Aurora.Controls 1.0
import QtMultimedia 5.6

Page {
    id: page
    allowedOrientations: defaultAllowedOrientations
    backgroundColor: "black"
    showNavigationIndicator: false

    property var jsonData
    property var episodeJsonData

    Component.onCompleted: {
        videoPlayer.source = "https://" + jsonData.player.host + "/" + episodeJsonData.hls.sd;
    }

    BackgroundItem {
        clip: panel.expanded

        anchors {
            top: parent.top
            bottom: panel.top
            left: parent.left
            right: parent.right
        }

        Video {
            id: videoPlayer
            anchors.fill: parent
            autoPlay: true

            onPlaybackStateChanged: {
                if(videoPlayer.playbackState === MediaPlayer.PlayingState) {
                    playPauseButton.icon.source = "image://theme/icon-m-pause"
                } else {
                    playPauseButton.icon.source = "image://theme/icon-m-play"
                }
            }

            onDurationChanged: {
                slider.maximumValue = videoPlayer.duration / 1000;
                console.log(videoPlayer.duration)
            }
        }

        onClicked: {
            panel.open = !panel.open
        }
    }

    DockedPanel {
        id: panel

        width: parent.width
        height: Theme.itemSizeSmall

        dock: Dock.Bottom

        RowLayout {
            width: parent.width
            height: parent.height

            IconButton {
                id: playPauseButton
                anchors {
                    leftMargin: Theme.paddingLarge
                }

                icon.source: "image://theme/icon-m-pause"

                onClicked: {
                    if(videoPlayer.playbackState === MediaPlayer.PlayingState) {
                        videoPlayer.pause();
                    } else {
                        videoPlayer.play();
                    }
                }
            }

            IconButton {
                icon.source: "image://theme/icon-m-previous"
            }

            IconButton {
                icon.source: "image://theme/icon-m-next"
            }

            Slider {
                id: slider

                Layout.fillWidth: true

                leftMargin: 0
                rightMargin: Theme.paddingMedium

                minimumValue: 0
                maximumValue: 100

                onReleased: {
                    videoPlayer.seek(value * 1000);
                }
            }

            Label {
                id: positionLabel
                Layout.preferredWidth: 230
            }

            IconButton {
                icon.source: "image://theme/icon-m-browser-sound"
            }

            IconButton {
                icon.source: "image://theme/icon-m-setting"
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        function formatTime(ms) {
            var totalSeconds = Math.floor(ms / 1000);
            var minutes = Math.floor(totalSeconds / 60);
            var seconds = totalSeconds % 60;
            return (minutes < 10 ? "0" + minutes : minutes) + ":" + (seconds < 10 ? "0" + seconds : seconds);
        }

        onTriggered: {
            if (videoPlayer.playbackState === MediaPlayer.PlayingState) {
                slider.value = videoPlayer.position / 1000;
                positionLabel.text = formatTime(videoPlayer.position) + " / " + formatTime(videoPlayer.duration);
            }
        }
    }
}
