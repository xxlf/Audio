#ifndef TOUCHSETTINGS_H
#define TOUCHSETTINGS_H

#include <QObject>

class touchsettings : public QObject
{
    Q_OBJECT
public:
    explicit touchsettings(QObject *parent = 0);
    
signals:
    
public slots:
};

#endif // TOUCHSETTINGS_H