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

Page {
    id: imageController
    anchors.fill: parent

    clip: true
    tools: imgTools

    property int imgContainerWidth: width
    property int imgContainerHeight: height
    property variant galleryModel
    // XXX: This is not actually the visible index; it's the index shown when
    // loading the page. Use middle.index instead. Should be refactored.
    property int visibleIndex: 0
    property real firstPressX
    property real pressX
    property int flickToX: 0
    property int flickFromX: 0
    property bool moving: false
    property variant leftMost: one
    property variant leftMiddle: two
    property variant middle: three
    property variant rightMiddle: four
    property variant rightMost: five
    property real swipeThreshold: 40
    property real leftMostOptimalX: -width*2
    //number of pixel you have to move before the Pinch Area is disabled
    property real pinchThreshold: 3
    property alias flickAreaEnabled: imgFlickable.enabled
    property variant doubleClickTimer: middle.image.doubleClickTimer
    property int videoThumbnailSize: 480
    //This property forces the middle item to be visible on screen by keeping the leftMost item at x = leftMostOptimalX
    //You have to set it to FALSE when you want to want to modify leftMost's x property, and set it back to true
    //to be sure that the middle item will be the one centered on screen.
    //(e.g. this is what flickTo NumberAnimation does)
    property bool keepMiddleItemAligned: true

    onWidthChanged: {
        if (!middle.isVideo)
            middle.image.resetZoom()
    }

    function showVideoPlayer() {
        appWindow.pageStack.push(Qt.resolvedUrl("VideoPlayer.qml"),
                                 {videoSource: galleryModel.get(middle.index).url},
                                 true)
    }

    function modulus(a, b) {
        if (a < 0) return (a+b) % b
        else return a % b
    }

    function isInside(x, y, rect) {
        var rectAbsolute = rect.mapToItem(imageController, rect.x, rect.y)
        return ((x > rectAbsolute.x) && (x < rectAbsolute.x + rect.width) &&
                (y > rectAbsolute.y) && (y < rectAbsolute.y + rect.height))
    }

    function swapLeftMost() {
        leftMiddle.anchors.left = undefined
        leftMost.anchors.left = rightMost.right

        //TODO: we could use a generic function instead of fixed assignments when shifting the positiong of the containers
        //shift all elements left by one position, and make leftMost become rightMost
        var oldLeftMost = leftMost
        leftMost = leftMiddle
        leftMiddle = middle
        middle = rightMiddle
        rightMiddle = rightMost
        rightMost = oldLeftMost
        //set the index (relative to galleryModel) of the image which has to be loaded by the shifted image container
        rightMost.index = modulus(middle.index + 2, galleryModel.count);
    }

    function swapRightMost() {
        rightMost.anchors.left = undefined
        leftMost.anchors.left = rightMost.right

        //shift all elements right by one position, and make rightMost become leftMost
        var oldRightMost = rightMost
        rightMost = rightMiddle
        rightMiddle = middle
        middle = leftMiddle
        leftMiddle = leftMost
        leftMost = oldRightMost
        leftMost.index = modulus(middle.index - 2, galleryModel.count);
    }

    NumberAnimation {
        id: flickTo;
        target: leftMost;
        property: "x";
        from: flickFromX;
        to: flickToX;
        duration: 300;
        easing.type: Easing.OutQuad
        onStarted: keepMiddleItemAligned = false
        onCompleted: {
            if (Math.abs(to - from) > swipeThreshold) {
                if (from > to )
                    swapLeftMost()
                else
                    swapRightMost()
            }

            keepMiddleItemAligned = true
            //This should be the only way the view can stop moving, so we set moving to false
            moving = false
        }
    }

    //This is to keep the middle item visible on screen.
    //Read the comment above the definition of keepMiddleItemAligned to know more
    Binding {
        target: leftMost
        value: leftMostOptimalX
        property: "x"
        when: keepMiddleItemAligned
    }

    ImageContainer {
        id: one;
        index: modulus(visibleIndex - 2, galleryModel.count)
        x: leftMostOptimalX
    }

    ImageContainer {
        id: two
        anchors.left: one.right
        index: modulus(visibleIndex - 1, galleryModel.count)
    }

    ImageContainer {
        id: three
        anchors.left: two.right
        index: visibleIndex
    }

    ImageContainer {
        id: four
        anchors.left: three.right
        index: modulus (visibleIndex + 1, galleryModel.count)
    }

    ImageContainer {
        id: five
        anchors.left: four.right
        index: modulus (visibleIndex + 2, galleryModel.count)
    }


    MouseArea {
        id: imgFlickable
        anchors.fill: parent
        enabled: middle.image.flickEnabled
        property bool pressedForClick: false

        //HACK: this mousarea is disabled when the image is zoomed, and the mousearea inside the imageContainer's img is disabled when zoom factor is 1,
        //so we have to get the doubleClick event here when the zoom factor is 1, and inside imageContainer's img when the image is zoomed.
        //This is due to the high number of mouse areas (pincharea, flickable, multiple mouseareas) available in the same view
        //Adding another MouseArea to handle this only made things worse
        //comment added by faenil
        onClicked: {
            if (!imageController.moving && isInside(mouse.x, mouse.y, middle.image)) {
                if (!middle.isVideo) {
                    if (doubleClickTimer.running) {}  //TODO: IMPLEMENT ZOOM-IN VIA DOUBLECLICK INSIDE THE CURLY BRACKETS
                    else doubleClickTimer.start()
                }
                else showVideoPlayer()
            }
        }

        onPressed: {
            firstPressX = mouseX
            pressX = mouseX
            pressedForClick = true

            //if the animation is running, make it stop and immediately slide to the image that you were going to
            //this allows very fast scrolling
            if (flickTo.running) flickTo.stop()
        }

        onPositionChanged: {
            if (Math.abs(firstPressX - mouseX) > pinchThreshold && moving == false) {
                moving = true
                pressedForClick = false
            }

            //Only move the image if we're sure the user isn't trying to pinch
            if (moving) {
                leftMost.x = leftMost.x - (pressX - mouseX)
                pressX = mouseX
            }
        }

        onReleased: {
            if (middle.x >= swipeThreshold) {
                //move it left
                flickToX = leftMostOptimalX + imgContainerWidth
            }
            else if (middle.x <= -swipeThreshold) {
                //move it right
                flickToX = leftMostOptimalX -imgContainerWidth
            }
            else {
                //bring it back
                flickToX = leftMostOptimalX
            }

            if (pressedForClick) {
                appWindow.fullscreen = !appWindow.fullscreen
                pressedForClick = false
            }

            flickFromX = leftMost.x
            flickTo.start()
        }
    }

    Menu {
        id: pageMenu
        MenuLayout {
            MenuItem {
                text: "Slideshow"
                onClicked: appWindow.pageStack.push(Qt.resolvedUrl("ImageSlideshowPage.qml"),
                                                    {visibleIndex: imageController.middle.index,
                                                    galleryModel: imageController.galleryModel},
                                                    true)
            }
        }
    }

    ToolBarLayout {
        id: imgTools
        ToolIcon {
            platformIconId: "toolbar-back"
            anchors.left: (parent === undefined) ? undefined : parent.left
            onClicked: {
                appWindow.fullscreen = false
                appWindow.pageStack.pop()
            }
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            anchors.right: (parent === undefined) ? undefined : parent.right
            onClicked: (pageMenu.status === DialogStatus.Closed) ? pageMenu.open() : pageMenu.close()
        }
    }
}
