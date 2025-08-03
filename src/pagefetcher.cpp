#include <QNetworkReply>
#include <QNetworkRequest>
#include <QObject>
#include <QStandardPaths>
#include <QCryptographicHash>
#include <QFileInfo>
#include <QDir>
#include <QJsonDocument>
#include <QJsonObject>

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

bool PageFetcher::isFavorite(const QString &id) {
    auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    auto fullPath = path + "/favorites.json";

    QFile file(fullPath);
    if (!file.exists()) {
        return false;
    }

    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Could not open file for reading:" << file.errorString();
        return false;
    }

    QByteArray jsonData = file.readAll();
    file.close();

    QJsonDocument jsonDoc(QJsonDocument::fromJson(jsonData));
    if (jsonDoc.isNull() || !jsonDoc.isArray()) {
        qWarning() << "Failed to create JSON doc or not an array.";
        return false;
    }

    QJsonArray jsonArray = jsonDoc.array();
    for(const QJsonValue &value : jsonArray) {
        QJsonObject jsonObject = value.toObject();
        if(jsonObject["id"].toString() == id)
            return true;
    }

    return false;
}

void PageFetcher::setFavorite(const QString &id, bool value, QString cover) {
    bool alreadyFavorite = isFavorite(id);
    if(value && alreadyFavorite) {
        qDebug() << id << "is already favorite";
        return;
    } else if(!value && !alreadyFavorite) {
        qDebug() << id << "already not favorite";
        return;
    }

    auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    auto fullPath = path + "/favorites.json";

    QFile file(fullPath);
    QJsonDocument jsonDoc;
    if (file.open(QIODevice::ReadOnly)) {
        QByteArray jsonData = file.readAll();
        file.close();

        jsonDoc = QJsonDocument::fromJson(jsonData);
    }

    QJsonArray finalArray;
    if(!jsonDoc.isArray()) {
        if(!value) {
            return;
        }

        QJsonObject jsonObject;
        jsonObject["id"] = id;
        jsonObject["cover"] = cover;
        finalArray.append(jsonObject);
    } else {
        if(value) {
            finalArray = jsonDoc.array();

            QJsonObject jsonObject;
            jsonObject["id"] = id;
            jsonObject["cover"] = cover;
            finalArray.append(jsonObject);
        } else {
            foreach (const QJsonValue &value, jsonDoc.array()) {
                QJsonObject jsonObject = value.toObject();
                if(jsonObject["id"] == id) {
                    continue;
                }

                finalArray.append(jsonObject);
            }
        }
    }

    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "Could not open output file for writing:" << file.errorString();
        return;
    }

    QJsonDocument filteredDoc(finalArray);
    file.write(filteredDoc.toJson());
    file.close();

    qDebug() << "Updated favorites file";
}

QJsonArray PageFetcher::getFavorites() {
    auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    auto fullPath = path + "/favorites.json";

    QFile file(fullPath);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Could not open file for reading:" << file.errorString();
        return QJsonArray();
    }

    QByteArray jsonData = file.readAll();
    file.close();

    QJsonDocument jsonDoc(QJsonDocument::fromJson(jsonData));
    if (jsonDoc.isNull() || !jsonDoc.isArray()) {
        qWarning() << "Failed to create JSON doc or not an array.";
        return QJsonArray();
    }

    return jsonDoc.array();
}

QJsonObject PageFetcher::getReadStatus(const QString &id) {
    auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    auto fullPath = path + "/status-" + id + ".json";

    QFile file(fullPath);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Could not open file for reading:" << file.errorString();
        return QJsonObject();
    }

    QByteArray jsonData = file.readAll();
    file.close();

    QJsonDocument jsonDoc(QJsonDocument::fromJson(jsonData));
    return jsonDoc.object();
}

void PageFetcher::setReadStatus(const QString &id,
                                const QString &branchID,
                                const QString &tome,
                                const QString &chapter,
                                const QString &page,
                                int viewMode) {

    auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    auto fullPath = path + "/status-" + id + ".json";

    QFile file(fullPath);
    QJsonDocument jsonDoc;
    if (file.open(QIODevice::ReadOnly)) {
        QByteArray jsonData = file.readAll();
        file.close();

        jsonDoc = QJsonDocument::fromJson(jsonData);
    }

    QJsonObject jsonObject;
    jsonObject["id"] = id;
    jsonObject["branchID"] = branchID;
    jsonObject["tome"] = tome;
    jsonObject["chapter"] = chapter;
    jsonObject["page"] = page;
    jsonObject["viewMode"] = viewMode;

    QJsonObject rootObject = jsonDoc.object();
    rootObject["status"] = jsonObject;

    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "Could not open output file for writing:" << file.errorString();
        return;
    }

    file.write(QJsonDocument(rootObject).toJson());
    file.close();
}

QString PageFetcher::getSetting(const QString &id) {
    auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    auto fullPath = path + "/settings.json";

    QFile file(fullPath);
    QJsonDocument jsonDoc;
    if (file.open(QIODevice::ReadOnly)) {
        QByteArray jsonData = file.readAll();
        file.close();

        jsonDoc = QJsonDocument::fromJson(jsonData);
    }

    if(!jsonDoc.isObject() || !jsonDoc.object()[id].isString()) {
        return "";
    }

    return jsonDoc.object()[id].toString();
}

void PageFetcher::setSetting(const QString &id, const QString &value) {
    auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    auto fullPath = path + "/settings.json";

    QFile file(fullPath);
    QJsonDocument jsonDoc;
    if (file.open(QIODevice::ReadOnly)) {
        QByteArray jsonData = file.readAll();
        file.close();

        jsonDoc = QJsonDocument::fromJson(jsonData);
    }

    QJsonObject jsonObject = jsonDoc.object();
    jsonObject[id] = value;

    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "Could not open output file for writing:" << file.errorString();
        return;
    }

    file.write(QJsonDocument(jsonObject).toJson());
    file.close();
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

