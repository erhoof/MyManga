#include <QNetworkReply>
#include <QNetworkRequest>
#include <QObject>
#include <QStandardPaths>
#include <QCryptographicHash>
#include <QFileInfo>
#include <QDir>

#include "pagefetcher.h"

PageFetcher::PageFetcher(QObject *parent) : QObject(parent),
    manager(new QNetworkAccessManager(this))
{
    connect(manager, &QNetworkAccessManager::finished, this, &PageFetcher::onPageDownloaded);
}

void PageFetcher::requestPage(const QString &url)
{
    auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(path + "/cache");
    if(!dir.exists()) {
        qDebug() << "Creating cache directory";
        dir.mkpath(".");
    }

    QUrl qUrl(url);
    auto nameChecksum = getChecksum(url);
    auto fileExtension = QFileInfo(qUrl.fileName()).suffix();

    auto fullPath = path + "/cache/" + nameChecksum + + "." + fileExtension;
    qDebug() << "Reading file '" << fullPath << "'";

    QFile file(fullPath);
    if(file.exists()) {
        qDebug() << "Got file from cache";
        emit pageFetched(fullPath);
        return;
    }

    qDebug() << "Requesting file from the network";
    QNetworkRequest request(qUrl);
    request.setRawHeader("Referer", "https://remanga.org/");

    lastPath = fullPath;
    manager->get(request);
}

Q_INVOKABLE void PageFetcher::purgeCache() {
    auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(path + "/cache");
    if(!dir.exists()) {
        return;
    }

    foreach (QString file, dir.entryList(QDir::NoDotAndDotDot | QDir::AllEntries)) {
        QString filePath = dir.absoluteFilePath(file);
        if (QFileInfo(filePath).isDir()) {
            continue;
        }

        QFile::remove(filePath);
    }
}

Q_INVOKABLE double PageFetcher::getCacheSize() {
    auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(path + "/cache");
    if(!dir.exists()) {
        return 0.0;
    }

    double totalSize = 0.0;
    QFileInfoList fileList = dir.entryInfoList(QDir::NoDotAndDotDot | QDir::Files);

    foreach (const QFileInfo &fileInfo, fileList) {
        totalSize += fileInfo.size(); // Size in bytes
    }

    return totalSize / (1024 * 1024);
}

QString PageFetcher::getChecksum(const QString &value) {
    QByteArray hash = QCryptographicHash::hash(value.toUtf8(), QCryptographicHash::Sha256);
    return hash.toHex();
}

Q_SLOT void PageFetcher::onPageDownloaded(QNetworkReply *reply) {
    if (reply->error() == QNetworkReply::NoError) {
        QFile newFile(lastPath);
        newFile.open(QIODevice::WriteOnly);
        newFile.write(reply->readAll());
        newFile.close();

        qDebug() << "Got file and saved it";
        emit pageFetched(lastPath);
    } else {
        qDebug() << "File request error";
        emit pageFetched("");
    }
    reply->deleteLater();
    lastPath = "";
}

