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
import org.nemomobile.qmlgallery 1.0

Page {
    anchors.fill: parent
    tools: mainTools

    GalleryView {

        model: GalleryModel {
            id: gallery
        }

        delegate: GalleryDelegate {
            MouseArea {
                anchors.fill: parent
                onClicked: appWindow.pageStack.push(Qt.resolvedUrl("ImagePage.qml"), {parameterIndex: index, galleryModel: gallery} )
            }
        }
    }

    Loader {
        id: choiceLoader
        anchors.fill: parent
    }

    property int currentFilter: 0
    ListModel {
        id: filterModel
        ListElement { name: "Images & Video" }
        ListElement { name: "Video only" }
        ListElement { name: "Images only" }
    }

    property int currentSort: -1
    ListModel {
        id: sortModel
        ListElement { name: "Filename"; sortProperty: "fileName"; ascending: true }
        ListElement { name: "File type"; sortProperty: "mimeType"; ascending: true }
        ListElement { name: "Clear sorting"; sortProperty: ""; ascending: false } // dummy
    }

    ToolBarLayout {
        id: mainTools
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            anchors.right: (parent === undefined) ? undefined : parent.right
            onClicked: (pageMenu.status === DialogStatus.Closed) ? pageMenu.open() : pageMenu.close()
        }
    }

    Menu {
        id: pageMenu

        MenuLayout {
            MenuItem {
                text: "Filter: " + filterModel.get(currentFilter).name
                onClicked: {
                    choiceLoader.source = Qt.resolvedUrl("FileTypeChoiceDialog.qml")
                    choiceLoader.item.open()
                }
            }
            MenuItem {
                text: (currentSort >= 0) ? ("Sort: " + sortModel.get(currentSort).name) : "Sort"
                onClicked: {
                    choiceLoader.source = Qt.resolvedUrl("SortDialog.qml")
                    choiceLoader.item.open()
                }
            }
            MenuItem {
                text: "Slideshow"
                onClicked: appWindow.pageStack.push(Qt.resolvedUrl("ImageSlideshowPage.qml"), { visibleIndex: 0, galleryModel: gallery })
                enabled: gallery.count > 0
            }
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
