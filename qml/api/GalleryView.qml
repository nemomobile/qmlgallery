/*
 * Copyright (C) 2012 John Brooks <john.brooks@dereferenced.net>
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
import com.nokia.meego 1.2
import org.nemomobile.thumbnailer 1.0

GridView {
    id: grid
    anchors.fill: parent

    // baseThumbnailSize is used to request images, and display size will be <=
    property int baseThumbnailSize: 160
    property int thumbnailSize: 0
    property int padding: 2

    // Calculate the thumbnail size to fit items of approximately 160px
    // onto each row with a minimal amount of extra space. The goal is
    // to avoid having a large unused area on the right edge.
    function updateThumbnailSize() {
        var itemsPerRow = Math.floor(width / baseThumbnailSize)
        // Ideally, this would use (padding*(itemsPerRow-1)), but GridView's
        // behavior on cellWidth requires the rightmost item to have padding.
        thumbnailSize = Math.floor((width - padding * itemsPerRow) / itemsPerRow)
    }

    Component.onCompleted: updateThumbnailSize()
    onPaddingChanged: updateThumbnailSize()
    onBaseThumbnailSizeChanged: updateThumbnailSize()

    flow: GridView.LeftToRight
    maximumFlickVelocity: 3000
    cellHeight: thumbnailSize + padding
    cellWidth: thumbnailSize + padding
    cacheBuffer: cellHeight * 3

    ScrollDecorator {
        flickableItem: grid
        anchors.right: grid.right; anchors.bottom: grid.bottom
    }

    Connections {
        target: screen
        onCurrentOrientationChanged: updateThumbnailSize()
    }

    ViewPlaceholder {
        text: "No elements found..."
        enabled: parent.model.count == 0 && parent.model.progress == 1.0
    }
}
