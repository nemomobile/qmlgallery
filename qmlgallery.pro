PROJECT_NAME = qmlgallery
QT += qml quick

# qml API we provide
qml_api.files = qml/api/*
qml_api.path = $$[QT_INSTALL_QML]/org/nemomobile/$$PROJECT_NAME
INSTALLS += qml_api

target.path = $$INSTALL_ROOT/usr/bin
INSTALLS += target

desktop.files = $${PROJECT_NAME}.desktop
desktop.path = $$INSTALL_ROOT/usr/share/applications
INSTALLS += desktop

RESOURCES += res.qrc

HEADERS += src/gallery.h
SOURCES += src/main.cpp \
    src/gallery.cpp

# do not edit below here
TEMPLATE = app
CONFIG -= app_bundle
TARGET = $$PROJECT_NAME

CONFIG += link_pkgconfig
PKGCONFIG += libresourceqt5

packagesExist(qdeclarative5-boostable) {
    message("Building with qdeclarative5-boostable support")
    DEFINES += HAS_BOOSTER
    PKGCONFIG += qdeclarative5-boostable
} else {
    warning("qdeclarative5-boostable not available; startup times will be slower")
}
