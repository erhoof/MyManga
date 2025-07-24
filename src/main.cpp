#include <auroraapp.h>
#include <QtQuick>

#include "pagefetcher.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> application(Aurora::Application::application(argc, argv));
    application->setOrganizationName(QStringLiteral("ru.erhoof"));
    application->setApplicationName(QStringLiteral("MyManga"));

    qmlRegisterType<PageFetcher>("ru.erhoof.imagefetcher", 1, 0, "PageFetcher");

    QScopedPointer<QQuickView> view(Aurora::Application::createView());
    view->setSource(Aurora::Application::pathTo(QStringLiteral("qml/MyManga.qml")));
    view->show();

    return application->exec();
}
