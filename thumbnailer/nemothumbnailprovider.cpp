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

#include <QFile>
#include <QCryptographicHash>
#include <QDebug>
#include <QDesktopServices>
#include <QDir>
#include <QImageReader>
#include <QDateTime>

#include "nemothumbnailprovider.h"

static inline QString cachePath()
{
    return QDesktopServices::storageLocation(QDesktopServices::CacheLocation) + ".nemothumbs";
}

static void setupCache()
{
    // the syscalls make baby jesus cry; but this protects us against sins like users
    QDir d(cachePath());
    if (!d.exists())
        d.mkpath(cachePath());
    if (!d.exists("raw"))
        d.mkdir("raw");

    // in the future, we might store a nicer UI version which can blend in with our UI better, but
    // we'll always want the raw version.
}

static QByteArray cacheKey(const QString &id, const QSize &requestedSize)
{
    QByteArray baId = id.toLatin1(); // is there a more efficient way than a copy?

    // check if we have it in cache
    QCryptographicHash hash(QCryptographicHash::Sha1);

    hash.addData(baId.constData(), baId.length());
    return hash.result().toHex() + "nemo" +
           QString::number(requestedSize.width()).toLatin1() + "x" +
           QString::number(requestedSize.height()).toLatin1();
}

static QImage attemptCachedServe(const QString &id, const QByteArray &hashKey)
{
    QFile fi(cachePath() + QDir::separator() + "raw" + QDir::separator() + hashKey);
    QFileInfo info(fi);
    if (info.exists() && info.lastModified() >= QFileInfo(id).lastModified()) {
        if (fi.open(QIODevice::ReadOnly)) {
            // cached file exists! hooray.
            QImage img;
            img.load(&fi, "JPG");
            return img;
        }
    }

    return QImage();
}

static void writeCacheFile(const QByteArray &hashKey, const QImage &img)
{
    QFile fi(cachePath() + QDir::separator() + "raw" + QDir::separator() + hashKey);
    if (!fi.open(QIODevice::WriteOnly)) {
        qWarning() << "Couldn't cache to " << fi.fileName();
        return;
    }
    img.save(&fi, "JPG");
    fi.flush();
    fi.close();
}

QImage NemoThumbnailProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    setupCache();

    // needed for stupid things like gallery model, which pass us a url
    if (id.startsWith("file://")) {
        qWarning() << Q_FUNC_INFO << "Removing file:// prefix, before: " << id;
        QString &nid = const_cast<QString &>(id);
        nid = nid.remove(0, 7);
    }

    qDebug() << Q_FUNC_INFO << "Requested image: " << id << " with size " << requestedSize;

    // sourceSize should indicate what size thumbnail you want. i.e. if you want a 120x120px thumbnail,
    // set sourceSize: Qt.size(120, 120).
    if (!requestedSize.isValid())
        qFatal("You must request a sourceSize whenever you use nemoThumbnail");

    if (size)
        *size = requestedSize;

    QByteArray hashData = cacheKey(id, requestedSize);
    QImage img = attemptCachedServe(id, hashData);
    if (!img.isNull()) {
        qDebug() << Q_FUNC_INFO << "Read " << id << " from cache";
        return img;
    }

    // cache couldn't satisfy us.
    // step 1: read source image in
    QImageReader ir(id);
    img = ir.read();

    // don't pollute the cache with false positives
    if (img.isNull())
        return QImage();

    if (img.size() == requestedSize)
        return img;

    // step 2: scale to target size
    if (img.height() == img.width()) {
        // in the case of a squared image, there's no need to crop
        img = img.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
    } else  if (img.height() >= requestedSize.height() && img.width() >= requestedSize.width()) {
        // if the image is larger than the desired size (on both dimensions)
        // then crop, and scale down
        if (img.width() < img.height()) {
            int cropPosition = (img.height() - img.width()) / 2;
            img = img.copy(0, cropPosition, img.width(), img.width());
            img = img.scaledToWidth(requestedSize.width(), Qt::SmoothTransformation);
        } else {
            int cropPosition = (img.width() - img.height()) / 2;
            img = img.copy(cropPosition, 0, img.height(), img.height());
            img = img.scaledToHeight(requestedSize.height(), Qt::SmoothTransformation);
        }
    } else if ((img.width() <= requestedSize.width() && img.height() >= requestedSize.height()) ||
               (img.width() >= requestedSize.width() && img.height() <= requestedSize.height())) {
        // if the image is smaller than the desired size on one dimension, scale it up,
        // then crop down to thumbnail size.
        if (img.width() <= requestedSize.width() && img.height() >= requestedSize.height()) {
            img = img.scaledToWidth(requestedSize.width(), Qt::SmoothTransformation);
            int cropPosition = (img.height() - img.width()) / 2;
            img = img.copy(0, cropPosition, img.width(), img.width());
        } else {
            img = img.scaledToHeight(requestedSize.height(), Qt::SmoothTransformation);
            int cropPosition = (img.width() - img.height()) / 2;
            img = img.copy(cropPosition, 0, img.height(), img.height());
        }
    } else {
        // if the image is smaller on both dimensions, scale it up, and use the requested
        // size to do the cropping
        if (img.width() < img.height()) {
            img = img.scaledToWidth(requestedSize.width(), Qt::SmoothTransformation);
            int cropPosition = (img.height() - requestedSize.height()) / 2;
            img = img.copy(0, cropPosition, img.width(), img.width());
        } else {
            img = img.scaledToHeight(requestedSize.height(), Qt::SmoothTransformation);
            int cropPosition = (img.width() - requestedSize.width()) / 2;
            img = img.copy(cropPosition, 0, img.height(), img.height());
        }
    }

    // step 3: write to cache for next time
    writeCacheFile(hashData, img);
    qDebug() << Q_FUNC_INFO << "Wrote " << id << " to cache";
    return img;
}
