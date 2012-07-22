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
    anchors.fill: parent

    tools: mainTools

    // baseThumbnailSize is used to request images, and display size will be <=
    property int baseThumbnailSize: 160
    property int thumbnailSize: 0
    property int padding: 2

    Component.onCompleted: updateThumbnailSize()
    onWidthChanged: updateThumbnailSize()
    onPaddingChanged: updateThumbnailSize()
    onBaseThumbnailSizeChanged: updateThumbnailSize()
    
    // Calculate the thumbnail size to fit items of approximately 160px
    // onto each row with a minimal amount of extra space. The goal is
    // to avoid having a large unused area on the right edge.
    function updateThumbnailSize() {
        var itemsPerRow = Math.floor(width / baseThumbnailSize)
        // Ideally, this would use (padding*(itemsPerRow-1)), but GridView's
        // behavior on cellWidth requires the rightmost item to have padding.
        thumbnailSize = Math.floor((width - padding * itemsPerRow) / itemsPerRow)
    }

    GridView {
        id: grid
        anchors.centerIn: parent

        width: parent.width
        height: parent.height

        flow: GridView.LeftToRight
        maximumFlickVelocity: 3000
        model: gallery
        cellHeight: thumbnailSize + padding
        cellWidth: thumbnailSize + padding
        cacheBuffer: cellHeight * 3

        delegate:
            Image {
                width: thumbnailSize
                height: thumbnailSize
                sourceSize: Qt.size(baseThumbnailSize, baseThumbnailSize)
                asynchronous: true
                source: "image://nemoThumbnail/" + url

                MouseArea {
                    anchors.fill: parent
                    onClicked: appWindow.pageStack.push(Qt.resolvedUrl("ImagePage.qml"), {imageId: index, galleryModel: gallery } )
                }
            }

    }

    DocumentGalleryModel {
        id: gallery

        rootType : DocumentGallery.Image
        properties : [ "url", "width", "height" ]
        filter : GalleryWildcardFilter {
            property : "fileName";
            value : "*.jpg";
        }
    }

    ToolBarLayout {
        id: mainTools
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            anchors.right: (parent === undefined) ? undefined : parent.right
            //onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }

    states: State {
        name: "active"
        when: status == PageStatus.Active || status == PageStatus.Activating

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
