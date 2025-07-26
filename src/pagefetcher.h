#ifndef PAGEFETCHER_H
#define PAGEFETCHER_H

#include <QNetworkAccessManager>
#include <QObject>
#include <QJsonArray>
#include <QJsonObject>

class PageFetcher : public QObject
{
    Q_OBJECT
public:
    PageFetcher(QObject *parent = nullptr);

    Q_INVOKABLE void requestPage(const QString &url);
    Q_INVOKABLE void purgeCache();
    Q_INVOKABLE double getCacheSize();

    Q_INVOKABLE bool isFavorite(const QString &id);
    Q_INVOKABLE void setFavorite(const QString &id, bool value, QString cover = "");
    Q_INVOKABLE QJsonArray getFavorites();

    Q_INVOKABLE QJsonObject getReadStatus(const QString &id);
    Q_INVOKABLE void setReadStatus(const QString &id,
                                   const QString &branchID,
                                   const QString &tome,
                                   const QString &chapter,
                                   const QString &page);

signals:
    void pageFetched(QString path);

private:
    QString lastPath;
    QNetworkAccessManager *manager;

    static QString getChecksum(const QString &value);

private slots:
    void onPageDownloaded(QNetworkReply *reply);
};

#endif // PAGEFETCHER_H
