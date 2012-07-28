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

#include <QDebug>
#include <QFile>
#include <QVector>

#include <QContactAddress>
#include <QContactAvatar>
#include <QContactThumbnail>
#include <QContactBirthday>
#include <QContactEmailAddress>
#include <QContactGuid>
#include <QContactName>
#include <QContactNickname>
#include <QContactNote>
#include <QContactOrganization>
#include <QContactOnlineAccount>
#include <QContactUnionFilter>
#include <QContactFavorite>
#include <QContactPhoneNumber>
#include <QContactUrl>
#include <QContactNote>
#include <QContactPresence>
#include <QContactDetailFilter>
#include <QContactLocalIdFilter>
#include <QContactManagerEngine>

#include <QVersitReader>
#include <QVersitContactImporter>

#include "seasideperson.h"
#include "seasidepeoplemodel.h"
#include "seasidepeoplemodel_p.h"

SeasidePeopleModel::SeasidePeopleModel(QObject *parent)
    : QAbstractListModel(parent)
    , priv(new SeasidePeopleModelPriv(this))
{
    QHash<int, QByteArray> roles;
    roles.insert(Qt::DisplayRole, "display");
    roles.insert(FirstNameRole, "firstName");
    roles.insert(LastNameRole, "lastName");
    roles.insert(SectionBucketRole, "sectionBucket");
    roles.insert(PersonRole, "person");
    setRoleNames(roles);
}

SeasidePeopleModel::~SeasidePeopleModel()
{
}

SeasidePeopleModel *SeasidePeopleModel::instance()
{
    static SeasidePeopleModel *spm = 0;

    if (spm)
        return spm;

    // TODO: refcount spm instance, destroy it X time after the last refcount
    // drops. this is because we're expensive to instantiate, but we should not
    // instantly destroy, for the same reason.
    spm = new SeasidePeopleModel;
    return spm;
}

int SeasidePeopleModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return priv->contactIds.size();
}

bool SeasidePeopleModel::savePerson(SeasidePerson *person)
{
    QContact contact = person->contact();

    priv->contactsPendingSave.append(contact);

    if (contact.localId()) {
        // we save the contact to our model as well; if it existed previously.
        // this covers our QContactManager being slow at informing us about saves
        // with the slight problem that our data may be a little inconsistent if
        // the QContactManager decides to save differently from what we asked
        // it to - but this is ok, because the save request finishing will fix that.
        int rowId = priv->idToIndex.value(contact.localId());
        emit dataChanged(index(rowId, 0), index(rowId, 0));
        qDebug() << Q_FUNC_INFO << "Faked save for " << contact.localId() << " row " << rowId;
    }

    // TODO: in a more complicated implementation, we'd only save
    // on a timer instead of flushing all the time
    priv->savePendingContacts();

    return true;
}

SeasidePerson *SeasidePeopleModel::personByRow(int row) const
{
    if (row < 0 || row >= priv->contactIds.count())
        return 0;

   QContactLocalId id = priv->contactIds[row];
   return priv->idToContact[id];
}

SeasidePerson *SeasidePeopleModel::personById(int id) const
{
    // TODO: can this crash? probably
    SeasidePerson *person = priv->idToContact.value(id);
    return person;
}

void SeasidePeopleModel::removePerson(SeasidePerson *person)
{
    qDebug() << Q_FUNC_INFO << "Removing " << person;
    // TODO: fake remove the contact, so it appears to happen faster
    QContactRemoveRequest *removeRequest = new QContactRemoveRequest(this);
    removeRequest->setManager(priv->manager);
    connect(removeRequest,
            SIGNAL(stateChanged(QContactAbstractRequest::State)),
            priv, SLOT(onRemoveStateChanged(QContactAbstractRequest::State)));
    removeRequest->setContactId(person->contact().id().localId());
    qDebug() << Q_FUNC_INFO << "Removing " << person->contact().id().localId();

    if (!removeRequest->start()) {
        qWarning() << Q_FUNC_INFO << "Remove request failed";
        delete removeRequest;
    }
}

QVariant SeasidePeopleModel::data(const QModelIndex& index, int role) const
{
    SeasidePerson *aperson = personByRow(index.row());
    if (!aperson)
        return QVariant();

    switch (role) {
        case Qt::DisplayRole:
            return aperson->displayLabel();
        case FirstNameRole:
            return aperson->firstName();
        case LastNameRole:
            return aperson->lastName();
        case SectionBucketRole:
            return aperson->sectionBucket();
        case PersonRole:
            return QVariant::fromValue<SeasidePerson *>(aperson);
        default:
            return QVariant();
    }
}

#include <QDir>

void SeasidePeopleModel::importContacts(const QString &path)
{
    qDebug() << QDir::currentPath();
    QFile vcf(path);
    if (!vcf.open(QIODevice::ReadOnly)) {
        qWarning() << Q_FUNC_INFO << "Cannot open " << path;
        return;
    }

    QVersitReader reader(&vcf);
    reader.startReading();
    reader.waitForFinished();

    QVersitContactImporter importer;
    importer.importDocuments(reader.results());

    QList<QContact> newContacts = importer.contacts();

    foreach (const QContact &contact, newContacts)
        priv->contactsPendingSave.append(contact);

    priv->savePendingContacts();
    qDebug() << Q_FUNC_INFO << "Imported " << newContacts.size() << " contacts " << " from " << path;
}

