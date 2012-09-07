import QtQuick 1.1
import com.nokia.meego 1.0

SelectionDialog {

    titleText: "Sort by"

    // Handle item selection here instead in selectedIndexChanged to react on same selection
    function itemSelected(selection) {
        // Check if we need to change from asc to desc or vice versa
        if (selection === selectedIndex)
            model.setProperty(selection, "ascending", !model.get(selection).ascending);

        var property = model.get(selection).sortProperty
        if (property && model.get(selection).ascending)
            property = "-" + property
        gallery.sortProperties = [ property ]

        if (property) 
            selectedIndex = selection
        else
            selectedIndex = -1

        currentSort = selectedIndex
    }

    model: sortModel
    selectedIndex: currentSort

    // Delegate modified from default meego SelectionDialog delegate
    delegate: Component {
        id: defaultDelegate

        Item {
            id: delegateItem
            property bool selected: index === selectedIndex

            height: root.platformStyle.itemHeight
            anchors.left: parent.left
            anchors.right: parent.right

            MouseArea {
                id: delegateMouseArea
                anchors.fill: parent;
                onPressed: {
                    itemSelected(index);
                }
                onClicked:  accept();
            }

            Rectangle {
                id: backgroundRect
                anchors.fill: parent
                color: delegateItem.selected ? root.platformStyle.itemSelectedBackgroundColor : root.platformStyle.itemBackgroundColor
            }

            BorderImage {
                id: background
                anchors.fill: parent
                source: delegateMouseArea.pressed ? root.platformStyle.itemPressedBackground :
                        delegateItem.selected ? root.platformStyle.itemSelectedBackground :
                        root.platformStyle.itemBackground
            }

            Text {
                id: itemText
                elide: Text.ElideRight
                color: delegateItem.selected ? root.platformStyle.itemSelectedTextColor : root.platformStyle.itemTextColor
                anchors.verticalCenter: delegateItem.verticalCenter
                anchors.left: parent.left
                anchors.right: directionIcon.right
                anchors.leftMargin: root.platformStyle.itemLeftMargin
                anchors.rightMargin: root.platformStyle.itemRightMargin
                text: name
                font: root.platformStyle.itemFont
            }
            Image {
                id: directionIcon
                // If the item is selected, show sort direction
                source: selected ? (ascending ? "qrc:/images/up_arrow.png" : "qrc:/images/down_arrow.png") : ""
                anchors.right: parent.right
                height: parent.height / 2
                width: parent.height / 2
                anchors.verticalCenter: parent.verticalCenter
                smooth: true
            }
        }
    }
}
