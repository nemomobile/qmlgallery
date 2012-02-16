import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.gallery 1.1

Page {
    anchors.fill: parent

    //tools: commonTools

    GridView {
        id: grid
        anchors.centerIn: parent

        width: parent.width
        height: parent.height

        flow: GridView.LeftToRight
        maximumFlickVelocity: 3000
        model: gallery
        cellHeight: 120
        cellWidth: 120

        delegate:
            Image {
                width: grid.cellWidth
                height: grid.cellHeight
                fillMode: Image.PreserveAspectFit
                sourceSize.width:  120
                clip:true
                asynchronous: true
                //smooth: true
                source:  url

                MouseArea{
                    anchors.fill: parent
                    onClicked: appWindow.pageStack.push(imagepage, {imageId: index, galleryModel: gallery } )

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


}
