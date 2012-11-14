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

PinchArea {
    anchors.fill: parent

    property variant pinchTarget
    property variant connectedFlickable
    property variant targetContainer

    pinch.target: pinchTarget
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

    function resetZoom() {
        //resetting all variables related to pinch-to-zoom
        pinchTarget.scale = 1
        connectedFlickable.contentX = connectedFlickable.contentY = 0
        lastContentX = lastContentY = 0
        deltaX = deltaY = 0
        lastScaleX = lastScaleY = 1
        isZoomingOut = false
    }

    function updateContentX() {
        //Only calculate the correct ContentX if the image is wider than the screen, otherwise keep it centered (contentX = 0 in the else branch)
        if (connectedFlickable.width == targetContainer.width) {

            //Anchors the image to the left
            if (connectedFlickable.contentX < 0){
                deltaX = 0.0
                lastContentX = 0.0
                connectedFlickable.contentX = 0.0
            }
            else {
                //if the right end of the image is inside the screen area, lock it to the right and zoom out using right edge as an anchor
                if ((connectedFlickable.contentWidth - connectedFlickable.contentX < parent.width) && isZoomingOut) {

                    //align to the right
                    connectedFlickable.contentX -= parent.width - (connectedFlickable.contentWidth - connectedFlickable.contentX)

                    //Algo: set variable as if a new pinch starting from right edge were triggered
                    lastContentX = connectedFlickable.contentX
                    deltaX = connectedFlickable.contentX + parent.width
                    lastScaleX = pinchTarget.scale
                }

                connectedFlickable.contentX = (lastContentX + deltaX * ((pinchTarget.scale / lastScaleX) - 1.0 ))
            }
        }
        else {
            connectedFlickable.contentX = 0
        }
    }

    function updateContentY() {
        //Only calculate the correct ContentY if the image is taller than the screen, otherwise keep it centered (contentY = 0 in the else branch)
        if (connectedFlickable.height == targetContainer.height) {

            //Anchors the image to the top when zooming out
            if (connectedFlickable.contentY < 0) {
                deltaY = 0.0
                lastContentY = 0.0
                connectedFlickable.contentY = 0.0
            }
            else {
                //if the bottom end of the image is inside the screen area, lock it to the bottom and zoom out using bottom edge as an anchor
                if ((connectedFlickable.contentHeight - connectedFlickable.contentY < parent.height) && isZoomingOut) {
                    //align to the bottom
                    connectedFlickable.contentY -= parent.height - (connectedFlickable.contentHeight - connectedFlickable.contentY)

                    //Algo: set variable as if a new pinch starting from bottom edge were triggered
                    lastContentY = connectedFlickable.contentY
                    deltaY = connectedFlickable.contentY + parent.height
                    lastScaleY = pinchTarget.scale
                }
                connectedFlickable.contentY = (lastContentY + deltaY * ((pinchTarget.scale / lastScaleY) - 1.0 ))
            }
        }
        else {
            connectedFlickable.contentY = 0
        }
    }

    onPinchUpdated: {
        //Am I zooming in or out?
        if (pinch.scale > pinch.previousScale) isZoomingOut = false
        else isZoomingOut = true

        //Get updated "zoom center point" values when the image is completely zoomed out
        if(pinchTarget.scale == 1) {
            //This is so that everytime you zoom out, the new zoom is started with updated values
            initializedX = false
            initializedY = false
        }

        //i.e. everytime the image is wider than the screen, it should actually be
        // pinchTarget.width == targetContainer.width, but this condition is rarely met because of numeric error
        if (connectedFlickable.width == targetContainer.width) {
            if (!initializedX ) {
                //If it has not already been set by the "if (height == parent.targetContainer.height)" branch, set the scale here
                lastScaleX = pinchTarget.scale

                lastContentX = connectedFlickable.contentX
                deltaX = connectedFlickable.contentX + pinch.center.x
                initializedX = true;
            }

        }

        if (connectedFlickable.height == targetContainer.height) {
            if (!initializedY) {
                //If it has not already been set by the "if (width == targetContainer.width)", set the scale here
                lastScaleY = pinchTarget.scale

                lastContentY = connectedFlickable.contentY
                deltaY = connectedFlickable.contentY + pinch.center.y
                initializedY = true;
            }
        }
        // updateContentX and updateContentY are called after the scale on the target item updates bindings
    }

    onPinchFinished: {
        lastContentX = connectedFlickable.contentX
        lastContentY = connectedFlickable.contentY

        initializedX = false
        initializedY = false
    }

}
