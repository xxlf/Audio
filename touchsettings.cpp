#include "touchsettings.h"
#include <QtGui/QTouchDevice>
#include <QDebug>

TouchSettings::TouchSettings(QObject *parent) : QObject(parent)
{
    
}

//  判断是否为触摸设备或者手机  都不是  则返回true
bool TouchSettings::isHoverEnabled() const
{
#if defined(Q_OS_IOS) || defined(Q_OS_ANDROID) || defined(Q_OS_QNX) || defined(Q_OS_WINRT)
    return false;
#else
    bool isTouch = false;
    //  QTouchDevice:触摸器类
    //  
    foreach (const QTouchDevice *dev, QTouchDevice::devices())
        if (dev->type() == QTouchDevice::TouchScreen) {
            isTouch = true;
            break;
        }
    bool isMobile = false;
    if (qEnvironmentVariableIsSet("QT_QUICK_CONTROLS_MOBILE")) {
        isMobile = true;
    }
    return !isTouch && !isMobile;
#endif
}
