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

#include <QContactAvatar>
#include <QContactBirthday>
#include <QContactName>
#include <QContactFavorite>
#include <QContactPhoneNumber>
#include <QContactEmailAddress>
#include <QContactOnlineAccount>
#include <QContactOrganization>

#include "seasideperson.h"

#if 0
    case AvatarRole:
    {
        QContactAvatar avatar = mContact.detail<QContactAvatar>();
        if(!avatar.imageUrl().isEmpty()) {
            return QUrl(avatar.imageUrl()).toString();
        }
        return QString();
    }
    case ThumbnailRole:
    {
        QContactThumbnail thumb = mContact.detail<QContactThumbnail>();
        return thumb.thumbnail();
    }
    case FavoriteRole:
    {
        QContactFavorite fav = mContact.detail<QContactFavorite>();
        if(!fav.isEmpty())
            return QVariant(fav.isFavorite());
        return false;
    }
    case OnlineAccountUriRole:
    {
        QStringList list;
        foreach (const QContactOnlineAccount& account,
                 mContact.details<QContactOnlineAccount>()){
            if(!account.accountUri().isNull())
                list << account.accountUri();
        }
        return list;
    }
    case OnlineServiceProviderRole:
    {
        QStringList list;
        foreach (const QContactOnlineAccount& account,
                 mContact.details<QContactOnlineAccount>()){
            if(!account.serviceProvider().isNull())
                list << account.serviceProvider();
        }
        return list;
    }
    case IsSelfRole:
    {
        if (isSelfContact(mContact.id().localId()))
            return true;
        return false;
    }
    case EmailAddressRole:
    {
        QStringList list;
        foreach (const QContactEmailAddress& email,
                 mContact.details<QContactEmailAddress>()){
            if(!email.emailAddress().isNull())
                list << email.emailAddress();
        }
        return list;
    }
    case EmailContextRole:
    {
        QStringList list;
        foreach (const QContactEmailAddress& email,
                 mContact.details<QContactEmailAddress>()) {
            if (email.contexts().count() > 0)
                list << email.contexts().at(0);
        }
        return list;
    }
    case PhoneNumberRole:
    {
        QStringList list;
        foreach (const QContactPhoneNumber& phone,
                 mContact.details<QContactPhoneNumber>()){
            if(!phone.number().isNull())
                list << phone.number();
        }
        return list;
    }
    case PhoneContextRole:
    {
        QStringList list;
        foreach (const QContactPhoneNumber& phone,
                 mContact.details<QContactPhoneNumber>()) {
            if (phone.contexts().count() > 0)
                list << phone.contexts().at(0);
            else if (phone.subTypes().count() > 0)
                list << phone.subTypes().at(0);
        }
        return list;
    }
    case AddressRole:
    {
        QStringList list;
        QStringList fieldOrder = priv->localeHelper->getAddressFieldOrder();

        foreach (const QContactAddress& address,
                 mContact.details<QContactAddress>()) {
            QString aStr;
            QString temp;
            QString addy = address.street();
            QStringList streetList = addy.split("\n");

            for (int i = 0; i < fieldOrder.size(); ++i) {
                temp = "";
                if (fieldOrder.at(i) == "street") {
                    if (streetList.count() == 2)
                        temp += streetList.at(0);
                    else
                        temp += addy;
                } else if (fieldOrder.at(i) == "street2") {
                    if (streetList.count() == 2)
                        temp += streetList.at(1);
                }
                else if (fieldOrder.at(i) == "locale")
                    temp += address.locality();
                else if (fieldOrder.at(i) == "region")
                    temp += address.region();
                else if (fieldOrder.at(i) == "zip")
                    temp += address.postcode();
                else if (fieldOrder.at(i) == "country")
                    temp += address.country();

                if (i > 0)
                    aStr += "\n" + temp.trimmed();
                else
                    aStr += temp.trimmed();
            }

            if (aStr == "")
                aStr = address.street() + "\n" + address.locality() + "\n" +
                       address.region() + "\n" + address.postcode() + "\n" +
                       address.country();
           list << aStr;
        }
        return list;
    }
    case AddressStreetRole:
    {
        QStringList list;
        foreach (const QContactAddress& address,
                 mContact.details<QContactAddress>()){
            if(!address.street().isEmpty())
                list << address.street();
        }
        return list;
    }
    case AddressLocaleRole:
    {
        QStringList list;
        foreach (const QContactAddress& address,
                 mContact.details<QContactAddress>()) {
            if(!address.locality().isNull())
                list << address.locality();
        }
        return list;
    }
    case AddressRegionRole:
    {
        QStringList list;
        foreach (const QContactAddress& address,
                 mContact.details<QContactAddress>()) {
            if(!address.region().isNull())
                list << address.region();
        }
        return list;
    }
    case AddressCountryRole:
    {
        QStringList list;
        foreach (const QContactAddress& address,
                 mContact.details<QContactAddress>()) {
            if(!address.country().isNull())
                list << address.country();
        }
        return list;
    }
    case AddressPostcodeRole:
    {
        QStringList list;
        foreach (const QContactAddress& address,
                 mContact.details<QContactAddress>())
            list << address.postcode();
        return list;
    }

    case AddressContextRole:
    {
        QStringList list;
        foreach (const QContactAddress& address,
                 mContact.details<QContactAddress>()) {
            if (address.contexts().count() > 0)
                list << address.contexts().at(0);
        }
        return list;
    }
    case PresenceRole:
    {
        foreach (const QContactPresence& qp,
                 mContact.details<QContactPresence>()) {
            if(!qp.isEmpty())
                if(qp.presenceState() == QContactPresence::PresenceAvailable)
                    return qp.presenceState();
        }
        foreach (const QContactPresence& qp,
                 mContact.details<QContactPresence>()) {
            if(!qp.isEmpty())
                if(qp.presenceState() == QContactPresence::PresenceBusy)
                    return qp.presenceState();
        }
        return QContactPresence::PresenceUnknown;
    }

    case UuidRole:
    {
        QContactGuid guid = mContact.detail<QContactGuid>();
        if(!guid.guid().isNull())
            return guid.guid();
        return QString();
    }

    case WebUrlRole:
    {
        QStringList list;
       foreach(const QContactUrl &url, mContact.details<QContactUrl>()){
        if(!url.isEmpty())
            list << url.url();
       }
        return QStringList(list);
    }

    case WebContextRole:
    {
        QStringList list;
       foreach(const QContactUrl &url, mContact.details<QContactUrl>()){
        if(!url.contexts().isEmpty())
            list << url.contexts();
       }
        return list;
    }

    case NotesRole:
    {
        QContactNote note = mContact.detail<QContactNote>();
        if(!note.isEmpty())
            return note.note();
        return QString();
    }
    case FirstCharacterRole:
    {
        if (isSelfContact(mContact.id().localId()))
            return QString(tr("#"));

        return priv->localeHelper->getBinForString(data(row,
                    DisplayLabelRole).toString());
    }
    case DisplayLabelRole: {
    }

#endif

SeasidePerson::SeasidePerson(QObject *parent)
    : QObject(parent)
{

}

SeasidePerson::SeasidePerson(const QContact &contact, QObject *parent)
    : QObject(parent)
    , mContact(contact)
{
    recalculateDisplayLabel();
}

SeasidePerson::~SeasidePerson()
{
    emit contactRemoved();
}

// QT5: this needs to change type
int SeasidePerson::id() const
{
    return mContact.id().localId();
}

QString SeasidePerson::firstName() const
{
    QContactName nameDetail = mContact.detail<QContactName>();
    return nameDetail.firstName();
}

void SeasidePerson::setFirstName(const QString &name)
{
    qDebug() << Q_FUNC_INFO << "Setting to " << name;
    QContactName nameDetail = mContact.detail<QContactName>();
    nameDetail.setFirstName(name);
    mContact.saveDetail(&nameDetail);
    emit firstNameChanged();
    recalculateDisplayLabel();
}

QString SeasidePerson::lastName() const
{
    QContactName nameDetail = mContact.detail<QContactName>();
    return nameDetail.lastName();
}

void SeasidePerson::setLastName(const QString &name)
{
    qDebug() << Q_FUNC_INFO << "Setting to " << name;
    QContactName nameDetail = mContact.detail<QContactName>();
    nameDetail.setLastName(name);
    mContact.saveDetail(&nameDetail);
    emit lastNameChanged();
    recalculateDisplayLabel();
}

// small helper to avoid inconvenience
static QString generateDisplayLabel(QContact mContact)
{
    //REVISIT: Move this or parts of this to localeutils.cpp
    QString displayLabel;
    QContactName name = mContact.detail<QContactName>();
    QString nameStr1 = name.firstName();
    QString nameStr2 = name.lastName();

    if (!nameStr1.isNull())
        displayLabel.append(nameStr1);

    if (!nameStr2.isNull()) {
        if (!displayLabel.isEmpty())
            displayLabel.append(" ");
        displayLabel.append(nameStr2);
    }

    if (!displayLabel.isEmpty())
        return displayLabel;

    foreach (const QContactPhoneNumber& phone, mContact.details<QContactPhoneNumber>()) {
        if(!phone.number().isNull())
            return phone.number();
    }

    foreach (const QContactOnlineAccount& account,
             mContact.details<QContactOnlineAccount>()){
        if(!account.accountUri().isNull())
            return account.accountUri();
    }

    foreach (const QContactEmailAddress& email,
             mContact.details<QContactEmailAddress>()){
        if(!email.emailAddress().isNull())
            return email.emailAddress();
    }

    QContactOrganization company = mContact.detail<QContactOrganization>();
    if (!company.name().isNull())
        return company.name();

    return "(unnamed)"; // TODO: localisation
}

void SeasidePerson::recalculateDisplayLabel()
{
    QString oldDisplayLabel = displayLabel();
    QString newDisplayLabel = generateDisplayLabel(mContact);

    // TODO: would be lovely if mobility would let us store this somehow
    if (oldDisplayLabel != newDisplayLabel) {
        qDebug() << Q_FUNC_INFO << "Recalculated display label to " <<
            newDisplayLabel;
        mDisplayLabel = newDisplayLabel;
        emit displayLabelChanged();
    }
}

QString SeasidePerson::displayLabel() const
{
    return mDisplayLabel;
}

QString SeasidePerson::sectionBucket() const
{
//    return priv->localeHelper->getBinForString(data(row,
//                DisplayLabelRole).toString());
    // TODO: won't be at all correct for localisation
    // for some locales (asian in particular), we may need multiple bytes - not
    // just the first - also, we should use QLocale (or ICU) to uppercase, not
    // QString, as QString uses C locale.
    return displayLabel().at(0).toUpper();

}

QString SeasidePerson::companyName() const
{
    qDebug() << Q_FUNC_INFO << "STUB";
    return QString();
}

void SeasidePerson::setCompanyName(const QString &name)
{
    emit companyNameChanged();
}

bool SeasidePerson::favorite() const
{
    QContactFavorite favoriteDetail = mContact.detail<QContactFavorite>();
    return favoriteDetail.isFavorite();
}

void SeasidePerson::setFavorite(bool favorite)
{
    QContactFavorite favoriteDetail = mContact.detail<QContactFavorite>();
    favoriteDetail.setFavorite(favorite);
    mContact.saveDetail(&favoriteDetail);
    emit favoriteChanged();
}

QUrl SeasidePerson::avatarPath() const
{
    QContactAvatar avatarDetail = mContact.detail<QContactAvatar>();
    QUrl avatarUrl = avatarDetail.imageUrl();
    if (avatarUrl.isEmpty())
        return QUrl("image://theme/icon-m-telephony-contact-avatar");
    return avatarUrl;
}

void SeasidePerson::setAvatarPath(QUrl avatarPath)
{
    QContactAvatar avatarDetail = mContact.detail<QContactAvatar>();
    avatarDetail.setImageUrl(QUrl(avatarPath));
    mContact.saveDetail(&avatarDetail);
    emit avatarPathChanged();
}

QString SeasidePerson::birthday() const
{
    QContactBirthday day = mContact.detail<QContactBirthday>();
    if(!day.date().isNull())
        return day.date().toString(Qt::SystemLocaleDate);
    return QString();
}

void SeasidePerson::setBirthday(const QString &birthday)
{
    QContactBirthday day = mContact.detail<QContactBirthday>();
    day.setDate(QDate::fromString(birthday, Qt::SystemLocaleDate));
    mContact.saveDetail(&day);
    emit birthdayChanged();
}

#define LIST_PROPERTY_FROM_DETAIL_FIELD(detailType, fieldName) \
    QStringList list; \
    \
    foreach (const detailType &detail, mContact.details<detailType>()) { \
        if (!detail.fieldName().isEmpty()) \
            list << detail.fieldName(); \
    } \
    return list;

QStringList SeasidePerson::phoneNumbers() const
{
    LIST_PROPERTY_FROM_DETAIL_FIELD(QContactPhoneNumber, number);
}

// this could probably be optimised, but it's easiest: we just remove
// all the old phone number details, and add new ones
#define SET_PROPERTY_FIELD_FROM_LIST(detailType, fieldNameGet, fieldNameSet, newValueList) \
    const QList<detailType> &oldDetailList = mContact.details<detailType>(); \
    \
    if (oldDetailList.count() != newValueList.count()) { \
        foreach (detailType detail, oldDetailList) \
            mContact.removeDetail(&detail); \
    \
        foreach (const QString &value, newValueList) { \
            detailType detail; \
            detail.fieldNameSet(value); \
            mContact.saveDetail(&detail); \
        } \
    } else { \
        /* assign new numbers to the existing details. */ \
        for (int i = 0; i != newValueList.count(); ++i) { \
            detailType detail = oldDetailList.at(i); \
            detail.fieldNameSet(newValueList.at(i)); \
            mContact.saveDetail(&detail); \
        } \
    }

void SeasidePerson::setPhoneNumbers(const QStringList &phoneNumbers)
{
    SET_PROPERTY_FIELD_FROM_LIST(QContactPhoneNumber, number, setNumber, phoneNumbers)
    emit phoneNumbersChanged();
}

QStringList SeasidePerson::emailAddresses() const
{
    LIST_PROPERTY_FROM_DETAIL_FIELD(QContactEmailAddress, emailAddress);
}

void SeasidePerson::setEmailAddresses(const QStringList &emailAddresses)
{
    SET_PROPERTY_FIELD_FROM_LIST(QContactEmailAddress, emailAddress, setEmailAddress, emailAddresses)
    emit emailAddressesChanged();
}


QContact SeasidePerson::contact() const
{
    return mContact;
}

void SeasidePerson::setContact(const QContact &contact)
{
    // TODO: this should difference the two contacts, and emit the proper
    // signals
    mContact = contact;
}

