import QtQuick 1.1
import com.nokia.meego 1.0

SelectionDialog {

    titleText: "Sort by"
    model: ListModel {
        ListElement {name: "Date"}
        ListElement {name: "Filename"}
        ListElement {name: "Filetype"}
    }

    //Sort by date by default
    //This dialog is not destroyed once it's created, so we don't need to check the current filtering status
    // NOTE: Consider storing sort and filter selections in parent properties, and showing both dialogs
    // in same Loader for using less memory. Not an issue yet due to small application implmenetation
    selectedIndex: 0

    onSelectedIndexChanged: {
        switch(model.get(selectedIndex).name) {
        case "Date":
            // Sort by date in ascending order
            gallery.sortProperties = ["dateTaken"]
            break;
        case "Filename":
            // sort by filename in ascending order
            gallery.sortProperties = ["fileName"]
            break;
        case "Filetype":
            // sort by file extension in ascending order
            gallery.sortProperties = ["fileExtension"];
            break;
        }
    }
}
