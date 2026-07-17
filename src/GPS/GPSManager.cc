/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "GPSManager.h"
#include "GPSRtk.h"
#include "QGCLoggingCategory.h"
#include "RTKSettings.h"
#include "SettingsManager.h"
#include "Fact.h"

#include <QtCore/qapplicationstatic.h>

QGC_LOGGING_CATEGORY(GPSManagerLog, "qgc.gps.gpsmanager")

Q_APPLICATION_STATIC(GPSManager, _gpsManager);

GPSManager::GPSManager(QObject *parent)
    : QObject(parent)
    , _gpsRtk(new GPSRtk(this))
{
    RTKSettings* const rtkSettings = SettingsManager::instance()->rtkSettings();
    if (rtkSettings->ntripEnabled()->rawValue().toBool()) {
        _gpsRtk->connectNTRIP();
    }

    (void) connect(rtkSettings->ntripEnabled(), &Fact::rawValueChanged,
                   this, &GPSManager::_onNTRIPEnabledChanged);
}

GPSManager::~GPSManager()
{
}

GPSManager *GPSManager::instance()
{
    return _gpsManager();
}

void GPSManager::_onNTRIPEnabledChanged()
{
    RTKSettings* const rtkSettings = SettingsManager::instance()->rtkSettings();
    if (rtkSettings->ntripEnabled()->rawValue().toBool()) {
        _gpsRtk->connectNTRIP();
    } else {
        _gpsRtk->disconnectNTRIP();
    }
}
