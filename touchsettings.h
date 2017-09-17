#ifndef TOUCHSETTINGS_H
#define TOUCHSETTINGS_H

#include <QObject>

class TouchSettings : public QObject
{
    Q_OBJECT
public:
    explicit TouchSettings(QObject *parent = 0);
    Q_INVOKABLE bool isHoverEnabled() const;
signals:
    
public slots:
};

#endif // TOUCHSETTINGS_H
