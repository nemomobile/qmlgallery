/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef SEASIDEPROXYMODEL_H
#define SEASIDEPROXYMODEL_H

#include <QSortFilterProxyModel>
#include "seasidepeoplemodel.h"

class SeasideProxyModelPriv;

class SeasideProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_ENUMS(FilterType)

public:
    SeasideProxyModel(QObject *parent = 0);
    virtual ~SeasideProxyModel();

    enum FilterType {
        FilterAll,
        FilterFavorites,
    };

    enum StringType {
        Primary,
        Secondary,
    };

    Q_INVOKABLE virtual void setFilter(FilterType filter);
    Q_INVOKABLE int getSourceRow(int row) const;

    // for fastscroll support
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int length READ count NOTIFY countChanged)
    int count() const { return rowCount(QModelIndex()); }
    Q_INVOKABLE QVariantMap get(int row) const;

    // API
    Q_INVOKABLE bool savePerson(SeasidePerson *person)
    {
        SeasidePeopleModel *model = static_cast<SeasidePeopleModel *>(sourceModel());
        return model->savePerson(person);
    }
    Q_INVOKABLE SeasidePerson *personByRow(int row) const
    {
        SeasidePeopleModel *model = static_cast<SeasidePeopleModel *>(sourceModel());
        return model->personByRow(getSourceRow(row));
    }
    Q_INVOKABLE SeasidePerson *personById(int id) const
    {
        SeasidePeopleModel *model = static_cast<SeasidePeopleModel *>(sourceModel());
        return model->personById(id);
    }
    Q_INVOKABLE void removePerson(SeasidePerson *person)
    {
        SeasidePeopleModel *model = static_cast<SeasidePeopleModel *>(sourceModel());
        model->removePerson(person);
    }
    Q_INVOKABLE void importContacts(const QString &path)
    {
        SeasidePeopleModel *model = static_cast<SeasidePeopleModel *>(sourceModel());
        model->importContacts(path);
    }

signals:
    void countChanged();

protected:
    virtual bool filterAcceptsRow(int source_row, const QModelIndex& source_parent) const;
    virtual bool lessThan(const QModelIndex& left, const QModelIndex& right) const;

private slots:
    void readSettings();

private:
    SeasideProxyModelPriv *priv;
    Q_DISABLE_COPY(SeasideProxyModel);
};

#endif // SEASIDEPROXYMODEL_H
