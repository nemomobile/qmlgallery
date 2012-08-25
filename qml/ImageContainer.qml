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
    property variant imgController: imageController
    property bool isVideo: galleryModel.isVideo(index)

    //used inside ImagePage's imgFlickable to get the bounding rectangle of the image
    property variant image: img

    width: imgController.imgContainerWidth
    height: imgController.imgContainerHeight

    function resetZoom() {
        //resetting all variables related to pinch-to-zoom
        img.scale = 1
        flickImg.contentX = flickImg.contentY = 0
        pinchImg.lastContentX = pinchImg.lastContentY = pinchImg.deltaX = pinchImg.deltaY = 0
        pinchImg.lastScaleX = pinchImg.lastScaleY = 1
        pinchImg.isZoomingOut = false
    }

    PinchArea {
        id: pinchImg
        anchors.fill: imgContainer

        //Disable the pincharea if the listview is scrolling, to avoid problems
        enabled: (!imgController.moving && !isVideo)
        pinch.target: img
        pinch.maximumScale: 5
        pinch.dragAxis: Pinch.NoDrag

        property real lastContentX: 0
        property real lastContentY: 0
        property real lastScaleX: 1
        property real lastScaleY: 1
        property real deltaX: 0
        property real deltaY: 0
        property bool initializedX: false
        property bool initializedY: false
        property bool isZoomingOut: false


        function updateContentX() {

            //Only calculate the correct ContentX if the image is wider than the screen, otherwise keep it centered (contentX = 0 in the else branch)
            if (rect.width == imgController.width) {

                //Anchors the image to the left
                if (flickImg.contentX < 0){
                    deltaX = 0.0
                    lastContentX = 0.0
                    flickImg.contentX = 0.0
                }
                else {
                    //if the right end of the image is inside the screen area, lock it to the right and zoom out using right edge as an anchor
                    if ((flickImg.contentWidth - flickImg.contentX < parent.width) && isZoomingOut) {

                        //align to the right
                        flickImg.contentX -= parent.width - (flickImg.contentWidth - flickImg.contentX)

                        //Algo: set variable as if a new pinch starting from right edge were triggered
                        lastContentX = flickImg.contentX
                        deltaX = flickImg.contentX + parent.width
                        lastScaleX = img.scale
                    }

                    flickImg.contentX = (lastContentX + deltaX * ((img.scale / lastScaleX) - 1.0 ))
                }
            }
            else {
                flickImg.contentX = 0
            }
        }

        function updateContentY() {

            //Only calculate the correct ContentY if the image is taller than the screen, otherwise keep it centered (contentY = 0 in the else branch)
            if (rect.height == imgController.height) {

                //Anchors the image to the top when zooming out
                if (flickImg.contentY < 0) {
                    deltaY = 0.0
                    lastContentY = 0.0
                    flickImg.contentY = 0.0
                }
                else {
                    //if the bottom end of the image is inside the screen area, lock it to the bottom and zoom out using bottom edge as an anchor
                    if ((flickImg.contentHeight - flickImg.contentY < parent.height) && isZoomingOut) {
                        //align to the bottom
                        flickImg.contentY -= parent.height - (flickImg.contentHeight - flickImg.contentY)

                        //Algo: set variable as if a new pinch starting from bottom edge were triggered
                        lastContentY = flickImg.contentY
                        deltaY = flickImg.contentY + parent.height
                        lastScaleY = img.scale
                    }
                    flickImg.contentY = (lastContentY + deltaY * ((img.scale / lastScaleY) - 1.0 ))
                }
            }
            else {
                flickImg.contentY = 0
            }
        }


        onPinchUpdated: {
            //Am I zooming in or out?
            if (pinch.scale > pinch.previousScale) isZoomingOut = false
            else isZoomingOut = true

            //Get updated "zoom center point" values when the image is completely zoomed out
            if(img.scale == 1) {
                //This is so that everytime you zoom out, the new zoom is started with updated values
                initializedX = false
                initializedY = false
            }

            //i.e. everytime the image is wider than the screen, it should actually be
            // img.width == imgController.width, but this condition is rarely met because of numeric error
            if (rect.width == imgController.width) {
                if (!initializedX ) {
                    //If it has not already been set by the "if (height == parent.imgController.height)" branch, set the scale here
                    lastScaleX = img.scale

                    lastContentX = flickImg.contentX
                    deltaX = flickImg.contentX + pinch.center.x
                    initializedX = true;
                }

            }

            if (rect.height == imgController.height) {
                if (!initializedY) {
                    //If it has not already been set by the "if (width == imgController.width)", set the scale here
                    lastScaleY = img.scale

                    lastContentY = flickImg.contentY
                    deltaY = flickImg.contentY + pinch.center.y
                    initializedY = true;
                }
            }
            // updateContentX and updateContentY are called after the scale on the target item updates bindings
        }

        onPinchFinished: {
            lastContentX = flickImg.contentX
            lastContentY = flickImg.contentY

            initializedX = false
            initializedY = false
        }

    }

    Item {
        id: rect
        anchors.centerIn: parent

        width: Math.min(img.width*img.scale, parent.width)
        height: Math.min(img.height*img.scale, parent.height)

        Flickable {
            id: flickImg

            anchors.fill: rect
            transformOrigin: Item.TopLeft

            contentWidth: img.width * img.scale
            contentHeight: img.height * img.scale

            onContentWidthChanged: {
                pinchImg.updateContentX()
                pinchImg.updateContentY()
            }
            onContentHeightChanged: {
                pinchImg.updateContentX()
                pinchImg.updateContentY()
            }

            Image {
                id: img
                width: (fitsVertically) ? (imgController.height * imgRatio) : imgController.width
                height: (fitsVertically) ? (imgController.height) : (imgController.width / imgRatio)

                property int imgWidth: isVideo ? videoThumbnailSize : (info.available ? info.metaData.width : 0)
                property int imgHeight: isVideo ? videoThumbnailSize : (info.available ? info.metaData.height : 0)
                property real imgRatio: imgWidth / imgHeight
                property bool fitsVertically: imgRatio < (imgContainer.width / imgContainer.height)

                //DocumentGalleryItem automatically recognizes the rootType of the file
                DocumentGalleryItem {
                    id: info
                    item: galleryModel.get(index).itemId
                    autoUpdate: true
                    properties: ["width", "height", "url"]
                }

                transformOrigin: Item.TopLeft
                asynchronous: true
                source: isVideo ? "qrc:/images/DefaultVideoThumbnail.jpg" : galleryModel.get(index).url
                sourceSize.width: 1200

                //Disable ListView scrolling if you're zooming
                onScaleChanged: {
                    if (scale != 1 && imgController.flickAreaEnabled == true) imgController.flickAreaEnabled = false
                    else if (scale == 1 && imgController.flickAreaEnabled == false) imgController.flickAreaEnabled = true
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        if (!isVideo) {
                            if (imgController.doubleClickTimer.running) resetZoom()
                            else imgController.doubleClickTimer.start()
                        }
                    }
                }
            }
        }
    }
}
