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

    tools: imgTools
    clip: true

    property variant galleryModel
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
    property bool videoPlayerRequested: false

    //this is the index which has to be passed as a parameter when creating this page
    //it will only be used for initialization
    property int parameterIndex

    property int visibleIndex

    Component.onCompleted: {
        //this is to make so that when visibleIndex is changed the image containers have already been
        //initialized
        visibleIndex = parameterIndex
        updateImagesIndexes()
    }

    //this will make so that every time visibleIndex is changed, the image containers will all load
    //the correct images.
    //visibleIndex is the reliable source to know what index is currently being displayed on screen
    onVisibleIndexChanged: {
        updateImagesIndexes()
    }

    property real swipeThreshold: 40
    property real leftMostOptimalX: -width*2
    //number of pixel you have to move before the Pinch Area is disabled
    property real pinchThreshold: 3
    //This property forces the middle item to be visible on screen by keeping the leftMost item at x = leftMostOptimalX
    //You have to set it to FALSE when you want to want to modify leftMost's x property, and set it back to true
    //to be sure that the middle item will be the one centered on screen.
    //(e.g. this is what flickTo NumberAnimation does)
    property bool keepMiddleItemAligned: true

    onWidthChanged: {
        if (!middle.isVideo)
            pinchImg.resetZoom()
    }

    function updateImagesIndexes() {
        leftMost.index = modulus(visibleIndex - 2, galleryModel.count);
        leftMiddle.index = modulus(visibleIndex - 1, galleryModel.count);
        middle.index = modulus(visibleIndex, galleryModel.count);
        rightMiddle.index = modulus(visibleIndex + 1, galleryModel.count);
        rightMost.index = modulus(visibleIndex + 2, galleryModel.count);
    }

    function modulus(a, b) {
        if (a < 0) return (a+b) % b
        else return a % b
    }

    function showVideoPlayer(fileName) {
        pageStack.push(Qt.resolvedUrl("VideoPlayer.qml"),
                       {videoSource: fileName},
                       true)
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

        visibleIndex = middle.index;
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

        visibleIndex = middle.index;

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

    ZoomController {
        id: pinchImg

        //Disable the pincharea if the listview is scrolling, to avoid problems
        enabled: (!imageController.moving && !middle.isVideo)

        pinchTarget: middle.image
        connectedFlickable: middle.flickableArea
        targetContainer: middle
    }

    Connections {
        target: middle
        onClickedWhileZoomed: listFlickable.handleClick()
        onPressedWhileNotZoomed: if (middle.isVideo) videoPlayerRequested = true
    }

    Timer {
        id: toolbarAutohideTimer
        interval: 2500
        running: !appWindow.fullscreen && (pageMenu.status === DialogStatus.Closed)
        onTriggered: appWindow.fullscreen = true
    }

    MouseArea {
        id: listFlickable
        anchors.fill: parent

        property bool pressedForClick: false

        function handleClick() {
            if (videoPlayerRequested) {
                videoPlayerRequested = false
                imageController.showVideoPlayer(middle.videoSource)
            }
            else {

                if (toolbarTimer.running) {
                    toolbarTimer.stop()
                } else {
                    toolbarTimer.start()
                }
            }
        }

        //we use this to be able to not call singleclick handlers when the user is actually doubleclicking
        Timer {
            id: toolbarTimer
            interval: 350
            onTriggered: appWindow.fullscreen = !appWindow.fullscreen
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

            //moving == true means the user isn't trying to pinch
            if (moving) {
                leftMost.x = leftMost.x - (pressX - mouseX)
                pressX = mouseX
            }
        }

        onReleased: {
            if (pressedForClick) {
                handleClick()
                pressedForClick = false
            }

            if (middle.x >= swipeThreshold) {
                //move it left
                flickToX = leftMostOptimalX + parent.width
            }
            else if (middle.x <= -swipeThreshold) {
                //move it right
                flickToX = leftMostOptimalX -parent.width
            }
            else {
                //bring it back
                flickToX = leftMostOptimalX
            }

            flickFromX = leftMost.x
            flickTo.start()
        }
    }

    ImageContainer {
        id: one; x: leftMostOptimalX
        pinchingController: pinchImg
        pageStack: appWindow.pageStack
        isVideo: galleryModel.isVideo(index)
        imageSource: galleryModel.get(index).url
        videoSource: isVideo ? galleryModel.get(index).url : ""
        visible: (middle == one || moving)
    }

    ImageContainer {
        id: two; anchors.left: one.right
        pinchingController: pinchImg
        pageStack: appWindow.pageStack
        isVideo: galleryModel.isVideo(index)
        imageSource: galleryModel.get(index).url
        videoSource: isVideo ? galleryModel.get(index).url : ""
    }

    //this is the item which is in the middle by default
    ImageContainer {
        id: three; anchors.left: two.right
        pinchingController: pinchImg
        pageStack: appWindow.pageStack
        isVideo: galleryModel.isVideo(index)
        imageSource: galleryModel.get(index).url
        videoSource: isVideo ? galleryModel.get(index).url : ""
    }

    ImageContainer {
        id: four; anchors.left: three.right
        pinchingController: pinchImg
        pageStack: appWindow.pageStack
        isVideo: galleryModel.isVideo(index)
        imageSource: galleryModel.get(index).url
        videoSource: isVideo ? galleryModel.get(index).url : ""
    }

    ImageContainer {
        id: five; anchors.left: four.right
        pinchingController: pinchImg
        pageStack: appWindow.pageStack
        isVideo: galleryModel.isVideo(index)
        imageSource: galleryModel.get(index).url
        videoSource: isVideo ? galleryModel.get(index).url : ""
    }

    Menu {
        id: pageMenu
        MenuLayout {
            MenuItem {
                text: "Slideshow"
                onClicked: appWindow.pageStack.push(Qt.resolvedUrl("ImageSlideshowPage.qml"),
                                                    { visibleIndex: imageController.visibleIndex,
                                                        controller: imageController,
                                                        galleryModel: imageController.galleryModel },
                                                    true)
                enabled: galleryModel.count > 0
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

    states: State {
        name: "active"
        when: status === PageStatus.Active || status === PageStatus.Activating

        PropertyChanges {
            target: appWindow.pageStack.toolBar
            opacity: 0.8
        }
    }

    transitions: Transition {
        from: "active"
        reversible: true

        NumberAnimation {
            target: appWindow.pageStack.toolBar
            property: "opacity"
            duration: 250
        }
    }

}
