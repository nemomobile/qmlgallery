import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.gallery 1.1

Page{
    id: imagepage
    anchors.fill:parent

    tools: imgTools

    property alias imageId: imageview.currentIndex
    property alias galleryModel: imageview.model

    ListView{
        id: imageview
        anchors.fill:parent

        orientation: ListView.Horizontal
        highlightRangeMode: ListView.StrictlyEnforceRange

        //Set duration to 0 to skip listview animation when passing from grid to listview
        highlightMoveDuration: 1
        highlightResizeDuration: 1

        cacheBuffer:2*width

        snapMode: ListView.SnapOneItem

        delegate: Item{
            id: imgContainer

            width: imageview.width
            height: imageview.height

            PinchArea{
                id: pinchImg
                anchors.fill :rect

                //width: ((img.width * img.scale) > imgContainer.width) ? imgContainer.width : img.width*img.scale
                //height:((img.height * img.scale) > imgContainer.height) ? imgContainer.height : img.height*img.scale

                //Disable the pincharea if the listview is scrolling, to avoid problems
                enabled: !imageview.moving
                pinch.target: img
                pinch.maximumScale: 5
                pinch.dragAxis: Pinch.NoDrag

                property real lastContentX: 0
                property real lastContentY: 0
                property real lastScaleX: 1
                property real lastScaleY: 1
                property real deltaX: 0
                property real deltaY: 0
                property real preX : 0
                property real preY : 0
                property bool initializedX: false
                property bool initializedY: false
                property bool isZoomingOut: false


                function updateContentX(){

                    //Only calculate the correct ContentX if the image is wider than the screen, otherwise keep it centered (contentX = 0 in the else branch)
                    if (width == imageview.width){

                        //Anchors the image to the left
                        if (flickImg.contentX < 0){
                            deltaX = 0.0
                            lastContentX = 0.0
                            flickImg.contentX = 0.0
                        }
                        else {
                            //if the right end of the image is inside the screen area, lock it to the right and zoom out using right edge as an anchor
                            if ((flickImg.contentWidth - flickImg.contentX < parent.width) && isZoomingOut){

                                //align to the right
                                flickImg.contentX -= parent.width - (flickImg.contentWidth - flickImg.contentX)

                                //Algo: set variable as if a new pinch starting from right edge were triggered
                                lastContentX = flickImg.contentX
                                deltaX = flickImg.contentX + parent.width
                                lastScaleX = img.scale
                                flickImg.contentX = (lastContentX + deltaX * ((img.scale / lastScaleX) - 1.0 ))
                            }
                            else{
                                flickImg.contentX = (lastContentX + deltaX * ((img.scale / lastScaleX) - 1.0 ))
                            }
                        }
                    }
                    else{
                        flickImg.contentX = 0
                    }
                }

                function updateContentY(){

                    //Only calculate the correct ContentX if the image is wider than the screen, otherwise keep it centered (contentX = 0 in the else branch)
                    if (height == imageview.height){

                        //Anchors the image to the left when zooming out
                        if (flickImg.contentY < 0){
                            deltaY = 0.0
                            lastContentY = 0.0
                            flickImg.contentY = 0.0
                        }
                        else {
                            //if the right end of the image is inside the screen area, lock it to the right and zoom out using right edge as an anchor
                            if ((flickImg.contentHeight - flickImg.contentY < parent.height) && isZoomingOut){

                                //align to the right
                                flickImg.contentY -= parent.height - (flickImg.contentHeight - flickImg.contentY)

                                //Algo: set variable as if a new pinch starting from right edge were triggered
                                lastContentY = flickImg.contentY
                                deltaY = flickImg.contentY + parent.height
                                lastScaleY = img.scale
                                flickImg.contentY = (lastContentY + deltaY * ((img.scale / lastScaleY) - 1.0 ))
                            }
                            else{
                                flickImg.contentY = (lastContentY + deltaY * ((img.scale / lastScaleY) - 1.0 ))
                            }
                        }
                    }
                    else{
                        flickImg.contentY = 0
                    }
                }


                onPinchUpdated:{

                    //Am I zooming in or out?
                    if (pinch.scale > pinch.previousScale) isZoomingOut = false
                    else isZoomingOut = true

                    //saving contentX and contentY to a temp variable, since flickable will reset them when contentHeight/Width is changed
                    preX = flickImg.contentX
                    preY = flickImg.contentY
                    flickImg.contentHeight = (img.height * img.scale); flickImg.contentWidth = (img.width * img.scale)
                    flickImg.contentX = preX
                    flickImg.contentY = preY

                    //Get updated "zoom center point" values when the image is completely zoomed out
                    if(img.scale == 1){
                        //This is so that everytime you zoom out, the new zoom is started with updated values
                        initializedX = false
                        initializedY = false
                    }

                    //i.e. everytime the image is wider than the screen, it should actually be
                    // img.width == imageview.width, but this condition is rarely met because of numeric error
                    if (width == imageview.width)
                    {
                        if (!initializedX )
                        {
                            //If it has not already been set by the "if (height == imageview.height)" branch, set the scale here
                            lastScaleX = img.scale

                            lastContentX = flickImg.contentX
                            deltaX = flickImg.contentX + pinch.center.x
                            initializedX = true;
                        }

                    }

                    if (height == imageview.height)
                    {
                        if (!initializedY)
                        {
                            //If it has not already been set by the "if (width == imageview.width)", set the scale here
                            lastScaleY = img.scale

                            lastContentY = flickImg.contentY
                            deltaY = flickImg.contentY + pinch.center.y
                            initializedY = true;
                        }

                    }

                    updateContentY();
                    updateContentX();
                }

                onPinchFinished: {
                    lastContentX = flickImg.contentX
                    lastContentY = flickImg.contentY

                    initializedX = false
                    initializedY = false
                }

            }

            Item{
                id: rect
                anchors.centerIn:parent

                width: (parent.width > img.width*img.scale) ? img.width*img.scale : parent.width
                height:(parent.height > img.height*img.scale) ? img.height*img.scale : parent.height

                Flickable{
                    id: flickImg

                    anchors.fill:rect

                    transformOrigin: Item.TopLeft

                    Image{
                        id: img

                        //For Harmattan/Nemo ( THIS PART HAS TO BE FIXED , THE IMAGE IS NOT SCALED TO FILL THE SCREEN ATM)
                        property real imgRatio: galleryModel.get(index).width / galleryModel.get(index).height
                        property bool fitsVertically: imgRatio < (imgContainer.width / imgContainer.height)
                        width: (fitsVertically) ? (imageview.height * imgRatio) : imageview.width
                        height: (fitsVertically) ? (imageview.height) : (imageview.width / imgRatio)

                        //For Simulator:
                        //width: 480
                        //fillMode: Image.PreserveAspectFit

                        transformOrigin: Item.TopLeft
                        asynchronous: true
                        source: url
                        sourceSize.width: 2000
                        sourceSize.height: 2000

                        //Disable ListView scrolling if you're zooming
                        onScaleChanged: {
                            if (scale != 1 && imageview.interactive == true) imageview.interactive = false
                            else if (scale == 1 && imageview.interactive == false) imageview.interactive = true
                        }

                    }

                }

            }

        }


    }

    ToolBarLayout {
            id: imgTools
            ToolIcon {
                platformIconId: "toolbar-back"
                anchors.left: (parent === undefined) ? undefined : parent.left
                onClicked: appWindow.pageStack.pop()
            }
    }

}
