#include <QNetworkReply>
#include <QNetworkRequest>
#include <QObject>
#include <QStandardPaths>
#include <QCryptographicHash>
#include <QFileInfo>

#include "pagefetcher.h"

PageFetcher::PageFetcher(QObject *parent) : QObject(parent),
    manager(new QNetworkAccessManager(this))
{
    connect(manager, &QNetworkAccessManager::finished, this, &PageFetcher::onPageDownloaded);
}

void PageFetcher::requestPage(const QString &url)
{
    auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

    QUrl qUrl(url);
    auto nameChecksum = getChecksum(url);
    auto fileExtension = QFileInfo(qUrl.fileName()).suffix();

    auto fullPath = path + "/" + nameChecksum + fileExtension;
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

