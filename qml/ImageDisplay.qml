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

Item {
    id: imageItem
    property bool isVideo: false
    property bool pinchEnabled: true
    property bool flickEnabled: pinchImg.totalScale == 1
    property int pageWidth: 0
    property int pageHeight: 0
    property variant doubleClickTimer: timer
    property string source: ""
    property int doubleClickInterval: 350
    anchors.centerIn: parent

    function resetZoom() {
        if(imageItem.width <= 0)
            return
        if(imageItem.width == imageItem.height) {
            // @todo for some reason first image shown is with
            // width == height causing wrong aspect ratio to be set.
            // Figure out why. This still works. -vranki
            console.log("resetZoom workaround")
            return
        }
        flickImg.contentWidth = imageItem.width
        flickImg.contentHeight = imageItem.height
        flickImg.returnToBounds()
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
            contentWidth: imageItem.width
            contentHeight: imageItem.height

            PinchArea {
                id: pinchImg
                width: Math.max(flickImg.contentWidth, flickImg.width)
                height: Math.max(flickImg.contentHeight, flickImg.height)
                property real totalScale: flickImg.contentWidth / imageItem.width
                pinch.minimumScale: 1
                pinch.maximumScale: 5
                property real initialWidth
                property real initialHeight
                onPinchStarted: {
                    initialWidth = flickImg.contentWidth
                    initialHeight = flickImg.contentHeight
                }

                onPinchUpdated: {
                    // adjust content pos due to drag
                    flickImg.contentX += pinch.previousCenter.x - pinch.center.x
                    flickImg.contentY += pinch.previousCenter.y - pinch.center.y

                    if(initialWidth * pinch.scale < imageItem.width) {
                        flickImg.contentWidth = imageItem.width
                        flickImg.contentHeight = imageItem.height
                        return
                    }
                    if(initialWidth * pinch.scale > imageItem.width*5) {
                        flickImg.contentWidth = imageItem.width*5
                        flickImg.contentHeight = imageItem.height*5
                        return
                    }
                    // resize content
                    flickImg.resizeContent(initialWidth * pinch.scale, initialHeight * pinch.scale, pinch.center)
                }

                onPinchFinished: {
                    // Move its content within bounds.
                    flickImg.returnToBounds()
                }

                Image {
                    source: imageItem.source
                    id: img
                    asynchronous: true
                    transformOrigin: Item.TopLeft
                    sourceSize.width: 1200
                    width: flickImg.contentWidth
                    height: flickImg.contentHeight

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (!isVideo) {
                                if (timer.running) resetZoom()
                                else timer.start()
                            }
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: timer
        interval: doubleClickInterval
    }
}
