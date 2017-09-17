#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "touchsettings.h"
#include <QtGui/QGuiApplication>
#include <QtGui/QOpenGLContext>
#include <QtQuick/QQuickView>
#include <QtQuick/QQuickItem>
#include <QtQml/QQmlContext>


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    
    //QQmlApplicationEngine engine;
    //engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    QSurfaceFormat format;
    if (QOpenGLContext::openGLModuleType() == QOpenGLContext::LibGL) {
        format.setVersion(3, 2);
        format.setProfile(QSurfaceFormat::CoreProfile);
    }
    format.setDepthBufferSize(24);
    format.setStencilBufferSize(8);

    QQuickView view;
    view.setFormat(format);
    view.create();

    TouchSettings touchSettings;
    view.rootContext()->setContextProperty("touchSettings", &touchSettings);

    view.setSource(QUrl("qrc:/main.qml"));

    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.setMaximumSize(QSize(1820, 1080));
    view.setMinimumSize(QSize(300, 150));
    view.show();
    return app.exec();
}
