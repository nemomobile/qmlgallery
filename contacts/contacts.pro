TARGET = nemocontacts
PLUGIN_IMPORT_PATH = org/nemomobile/contacts

CONFIG += link_pkgconfig
packagesExist(icu-i18n) {
    DEFINES += HAS_ICU
} else {
    warning("ICU not detected. This may cause problems with i18n.")
}

SOURCES += plugin.cpp \
           localeutils.cpp \
           seasidepeoplemodel.cpp \
           seasidepeoplemodel_p.cpp \
           seasideperson.cpp \
           seasideproxymodel.cpp

HEADERS += localeutils_p.h \
           seasidepeoplemodel.h \
           seasidepeoplemodel_p.h \
           seasideperson.h \
           seasideproxymodel.h



# do not edit below here, move this to a shared .pri?
TEMPLATE = lib
CONFIG += qt plugin hide_symbols
QT += declarative
CONFIG += mobility
MOBILITY += contacts versit

target.path = $$[QT_INSTALL_IMPORTS]/$$PLUGIN_IMPORT_PATH
INSTALLS += target

qmldir.files += $$PWD/qmldir
qmldir.path +=  $$[QT_INSTALL_IMPORTS]/$$$$PLUGIN_IMPORT_PATH
INSTALLS += qmldir
