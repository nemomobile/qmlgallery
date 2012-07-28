/*
 * Copyright (C) 2012 Robin Burchell <robin+nemo@viroteck.net>
 *
 * You may use this file under the terms of the BSD license as follows:
 *
 * "Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *   * Neither the name of Nemo Mobile nor the names of its contributors
 *     may be used to endorse or promote products derived from this
 *     software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 */

#ifndef SEASIDEPEOPLEMODEL_H
#define SEASIDEPEOPLEMODEL_H

#include <QAbstractListModel>

#include <QUuid>
#include <QContactManagerEngine>

QTM_USE_NAMESPACE
class SeasidePeopleModelPriv;
class SeasidePerson;

class SeasidePeopleModel: public QAbstractListModel
{
    Q_OBJECT
    Q_ENUMS(PeopleRoles)
    Q_ENUMS(FilterRoles)

public:
    SeasidePeopleModel(QObject *parent = 0);
    virtual ~SeasidePeopleModel();

    static SeasidePeopleModel *instance();

    enum PeopleRoles {
        FirstNameRole = Qt::UserRole,
        LastNameRole,
        SectionBucketRole,
        PersonRole
    };

    //From QAbstractListModel
    Q_INVOKABLE virtual int rowCount(const QModelIndex& parent= QModelIndex()) const;
    QVariant data(const QModelIndex& index, int role) const;

    //QML API
    Q_INVOKABLE bool savePerson(SeasidePerson *person);
    Q_INVOKABLE SeasidePerson *personByRow(int row) const;
    Q_INVOKABLE SeasidePerson *personById(int id) const;
    Q_INVOKABLE void removePerson(SeasidePerson *person);
    Q_INVOKABLE void importContacts(const QString &path);

private:
    SeasidePeopleModelPriv *priv;
    friend class SeasidePeopleModelPriv;
    Q_DISABLE_COPY(SeasidePeopleModel);
};

#endif // SEASIDEPEOPLEMODEL_H
