import QtQuick 1.1
import com.nokia.meego 1.0

PageStackWindow {
    id: appWindow

    initialPage: mainPage

    MainPage {
        id: mainPage
    }

    ImagePage{
        id: imagepage
    }

    /*ToolBarLayout {
        id: commonTools
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            anchors.right: (parent === undefined) ? undefined : parent.right
            onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }*/



    /*Menu {
        id: myMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem { text: qsTr("Open image")
                onClicked: appWindow.pageStack.push(imagepage)
            }
        }
    }*/
}
