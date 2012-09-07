PROJECT_NAME = qmlgallery
QT += declarative opengl

# qml API we provide
qml_api.files = qml/api/*
qml_api.path = $$[QT_INSTALL_IMPORTS]/org/nemomobile/$$PROJECT_NAME
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
PKGCONFIG += libresourceqt1

packagesExist(qdeclarative-boostable) {
    message("Building with qdeclarative-boostable support")
    DEFINES += HAS_BOOSTER
    PKGCONFIG += qdeclarative-boostable
} else {
    warning("qdeclarative-boostable not available; startup times will be slow er")                                                                         
}
