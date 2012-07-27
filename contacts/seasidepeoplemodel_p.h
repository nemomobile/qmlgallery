/*
 * libseaside - Library that provides an interface to the Contacts application
 * Copyright (c) 2011, Robin Burchell.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 */

#ifndef SEASIDEPEOPLEMODEL_P_H
#define SEASIDEPEOPLEMODEL_P_H

#include <QObject>
#include <QVector>
#include <QStringList>
#include <QContactGuid>

#include "seasidepeoplemodel.h"
#include "localeutils_p.h"

class SeasidePeopleModelPriv : public QObject
{
    Q_OBJECT
public:
    explicit SeasidePeopleModelPriv(SeasidePeopleModel *parent);
    virtual ~SeasidePeopleModelPriv()
    {
        delete manager;
    }

    SeasidePeopleModel *q;
    QContactManager *manager;
    QContactFetchHint currentFetchHint;
    QList<QContactSortOrder> sortOrder;
    QContactFilter currentFilter;
    QList<QContactLocalId> contactIds;
    QMap<QContactLocalId, int> idToIndex;
    QMap<QContactLocalId, SeasidePerson *> idToContact;
    QVector<QStringList> data;
    QStringList headers;
    LocaleUtils *localeHelper;
    QContactGuid currentGuid;
    QList<QContact> contactsPendingSave;


    void addContacts(const QList<QContact> contactsList, int size);
    void fixIndexMap();

public slots:
    void dataReset();
    void savePendingContacts();

private slots:
    void onSaveStateChanged(QContactAbstractRequest::State requestState);
    void onRemoveStateChanged(QContactAbstractRequest::State requestState);
    void onDataResetFetchChanged(QContactAbstractRequest::State requestState);
    void onAddedFetchChanged(QContactAbstractRequest::State requestState);
    void onChangedFetchChanged(QContactAbstractRequest::State requestState);

    void contactsAdded(const QList<QContactLocalId>& contactIds);
    void contactsChanged(const QList<QContactLocalId>& contactIds);
    void contactsRemoved(const QList<QContactLocalId>& contactIds);



private:
    Q_DISABLE_COPY(SeasidePeopleModelPriv);
};

#endif // SEASIDEPEOPLEMODEL_P_H
