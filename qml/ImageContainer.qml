/*
 * Copyright (C) 2012 Andrea Bernabei <and.bernabei@gmail.com>
 *
 * You may use this file under the terms of the BSD license as follows:
 *
 * "Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *   * Neither the name of Nemo Mobile nor the names of its contributors
 *     may be used to endorse or promote products derived from this
 *     software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 */

import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.gallery 1.1

Item {
    id: imgContainer
    property int index: -1
    property variant pinchingController
    property variant pageStack
    property string imageSource: ""
    property string videoSource: ""
    property bool isVideo: false
    property alias flickableArea: flickImg
    property int doubleClickInterval: 350
    property alias image: img
    property int videoThumbnailSize: 480

    width: parent.width
    height: parent.height

    signal clickedWhileZoomed()

    function showVideoPlayer() {
        pageStack.push(Qt.resolvedUrl("VideoPlayer.qml"),
                       {videoSource: imgContainer.videoSource},
                       true)
    }

    Timer {
        id: doubleClickTimer
        interval: doubleClickInterval
    }

    Flickable {
        id: flickImg

        //we need this so that when the image IS zoomed-in and we pop the page we don't see
        //the part of the image which is out of the Page
        clip: true

        interactive: img.scale > 1

        anchors.centerIn: parent
        width: Math.min(img.width*img.scale, imgContainer.width)
        height: Math.min(img.height*img.scale, imgContainer.height)

        transformOrigin: Item.TopLeft

        contentWidth: img.width * img.scale
        contentHeight: img.height * img.scale

        onContentWidthChanged: {
            //this check is because the first time this slot is called, pinchingController isn't set yet
            if (pinchingController && pinchingController.pinch.active) {
                pinchingController.updateContentX()
                pinchingController.updateContentY()
            }
        }
        onContentHeightChanged: {
            if (pinchingController && pinchingController.pinch.active) {
                pinchingController.updateContentX()
                pinchingController.updateContentY()
            }
        }

        Image {
            id: img
            width: (fitsVertically) ? (imgContainer.height * imgRatio) : imgContainer.width
            height: (fitsVertically) ? (imgContainer.height) : (imgContainer.width / imgRatio)

            property int imgWidth: isVideo ? videoThumbnailSize : implicitWidth
            property int imgHeight: isVideo ? videoThumbnailSize : implicitHeight
            property real imgRatio: imgWidth / imgHeight
            property bool fitsVertically: imgRatio < (imgContainer.width / imgContainer.height)

            transformOrigin: Item.TopLeft
            asynchronous: true
            source: isVideo ? "qrc:/images/DefaultVideoThumbnail.jpg" : imageSource
            sourceSize.width: 1200

            MouseArea {
                anchors.fill: parent

                //this is only called when img.scale != 1
                //----> WARNING!!!: this causes a problem! double-press will call the zoomIn/Out function, while only
                //doubleCLICK will stop the toolbarTimer in ImagePage! So if you double-press (and keep it pressed)
                //both the zoomIn/Out function will be called and the toolBar in ImagePage will show/hide!!
                //TODO: look for a way to fix this
                onClicked: {
                    imgContainer.clickedWhileZoomed()
                }

                onPressed: {
                    //setting mouse.accepted to false means we'll only receive the onPressed of this event,
                    //the rest will be propagated to the area underneath
                    //if img.scale == 1 send events underneath, otherwise emit the signal (to make it
                    //propagate beyond the Flickable parent)
                    if (img.scale == 1) mouse.accepted = false

                    if (!isVideo) {
                        if (doubleClickTimer.running) {
                            if (img.scale != 1) {
                                pinchingController.resetZoom()
                            }
                            //TODO: IMPLEMENT ZOOM-IN VIA DOUBLECLICK IN THE ELSE BRANCH
                            //something like pinchingController.zoomIn()
                        }
                        else doubleClickTimer.start()
                    }
                    else showVideoPlayer()
                }
            }
        }
    }
}
