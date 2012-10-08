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

Page {
    id: singleImagePage
    anchors.fill: parent
    tools: singleImageTools
    property string filename: ""

    ImageDisplay {
        id: singleImage
        source: parent.filename
        // @todo a lot of this is shared with ImageContainer.
        // See if it could be refactored inside ImageDisplay
        width: (fitsVertically) ? (singleImagePage.height * imgRatio) : singleImagePage.width
        height: (fitsVertically) ? (singleImagePage.height) : (singleImagePage.width / imgRatio)
        pageWidth: singleImagePage.width
        pageHeight: singleImagePage.height
        property int imgWidth: imageInfo.width
        property int imgHeight: imageInfo.height
        property real imgRatio: imgWidth / imgHeight
        property bool fitsVertically: imgRatio < (pageWidth / pageHeight)
    }

    Image {
        // @todo Used just for getting image dimensions to ImageDisplay. Could be
        // refactored away with ImageDisplay.
        id: imageInfo
        source: filename
        asynchronous: false
        visible: false
    }

    ToolBarLayout {
        id: singleImageTools
        ToolIcon {
            platformIconId: "toolbar-back"
            anchors.left: (parent === undefined) ? undefined : parent.left
            onClicked: {
                appWindow.fullscreen = false
                appWindow.pageStack.pop()
            }
        }
    }
}
