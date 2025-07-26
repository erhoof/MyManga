#ifndef PAGEFETCHER_H
#define PAGEFETCHER_H

#include <QNetworkAccessManager>
#include <QObject>

class PageFetcher : public QObject
{
    Q_OBJECT
public:
    PageFetcher(QObject *parent = nullptr);

    Q_INVOKABLE void requestPage(const QString &url);
    Q_INVOKABLE void purgeCache();
    Q_INVOKABLE double getCacheSize();

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
