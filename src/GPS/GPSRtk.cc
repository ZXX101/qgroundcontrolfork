/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "GPSRtk.h"
#include "GPSProvider.h"
#include "GPSRTKFactGroup.h"
#include "MultiVehicleManager.h"
#include "NTRIPClient.h"
#include "QGCLoggingCategory.h"
#include "RTCMMavlink.h"
#include "RTKSettings.h"
#include "SettingsManager.h"
#include "PositionManager.h"
#include "Vehicle.h"

#include <QtCore/QUrl>

#include <cmath>

QGC_LOGGING_CATEGORY(GPSRtkLog, "qgc.gps.gpsrtk")

GPSRtk::GPSRtk(QObject *parent)
    : QObject(parent)
    , _gpsRtkFactGroup(new GPSRTKFactGroup(this))
    , _rtcmMavlink(new RTCMMavlink(this))
{
    (void) connect(MultiVehicleManager::instance(), &MultiVehicleManager::activeVehicleChanged,
                   this, &GPSRtk::_onActiveVehicleChanged);
}

GPSRtk::~GPSRtk()
{
    disconnectGPS();
    disconnectNTRIP();
}

void GPSRtk::registerQmlTypes()
{
    (void) qRegisterMetaType<satellite_info_s>("satellite_info_s");
    (void) qRegisterMetaType<sensor_gnss_relative_s>("sensor_gnss_relative_s");
    (void) qRegisterMetaType<sensor_gps_s>("sensor_gps_s");
}

void GPSRtk::_onGPSConnect()
{
    _gpsRtkFactGroup->connected()->setRawValue(true);
}

void GPSRtk::_onGPSDisconnect()
{
    _gpsRtkFactGroup->connected()->setRawValue(false);
}

void GPSRtk::_onGPSSurveyInStatus(float duration, float accuracyMM,  double latitude, double longitude, float altitude, bool valid, bool active)
{
    _gpsRtkFactGroup->currentDuration()->setRawValue(duration);
    _gpsRtkFactGroup->currentAccuracy()->setRawValue(static_cast<double>(accuracyMM) / 1000.0);
    _gpsRtkFactGroup->currentLatitude()->setRawValue(latitude);
    _gpsRtkFactGroup->currentLongitude()->setRawValue(longitude);
    _gpsRtkFactGroup->currentAltitude()->setRawValue(altitude);
    _gpsRtkFactGroup->valid()->setRawValue(valid);
    _gpsRtkFactGroup->active()->setRawValue(active);
}

void GPSRtk::connectGPS(const QString &device, QStringView gps_type)
{
    GPSProvider::GPSType type;
    if (gps_type.contains(QStringLiteral("trimble"), Qt::CaseInsensitive)) {
        type = GPSProvider::GPSType::trimble;
        qCDebug(GPSRtkLog) << "Connecting Trimble device";
    } else if (gps_type.contains(QStringLiteral("septentrio"), Qt::CaseInsensitive)) {
        type = GPSProvider::GPSType::septentrio;
        qCDebug(GPSRtkLog) << "Connecting Septentrio device";
    } else if (gps_type.contains(QStringLiteral("femtomes"), Qt::CaseInsensitive)) {
        type = GPSProvider::GPSType::femto;
        qCDebug(GPSRtkLog) << "Connecting Femtomes device";
    } else {
        type = GPSProvider::GPSType::u_blox;
        qCDebug(GPSRtkLog) << "Connecting U-blox device";
    }

    disconnectGPS();

    RTKSettings* const rtkSettings = SettingsManager::instance()->rtkSettings();
    _requestGpsStop = false;
    const GPSProvider::rtk_data_s rtkData = {
        rtkSettings->surveyInAccuracyLimit()->rawValue().toDouble(),
        rtkSettings->surveyInMinObservationDuration()->rawValue().toInt(),
        rtkSettings->useFixedBasePosition()->rawValue().toBool(),
        rtkSettings->fixedBasePositionLatitude()->rawValue().toDouble(),
        rtkSettings->fixedBasePositionLongitude()->rawValue().toDouble(),
        rtkSettings->fixedBasePositionAltitude()->rawValue().toFloat(),
        rtkSettings->fixedBasePositionAccuracy()->rawValue().toFloat()
    };
    _gpsProvider = new GPSProvider(
        device,
        type,
        rtkData,
        _requestGpsStop,
        this
    );
    (void) QMetaObject::invokeMethod(_gpsProvider, "start", Qt::AutoConnection);

    (void) connect(_gpsProvider, &GPSProvider::RTCMDataUpdate, _rtcmMavlink, &RTCMMavlink::RTCMDataUpdate);

    (void) connect(_gpsProvider, &GPSProvider::satelliteInfoUpdate, this, &GPSRtk::_satelliteInfoUpdate);
    (void) connect(_gpsProvider, &GPSProvider::sensorGpsUpdate, this, &GPSRtk::_sensorGpsUpdate);
    (void) connect(_gpsProvider, &GPSProvider::surveyInStatus, this, &GPSRtk::_onGPSSurveyInStatus);
    (void) connect(_gpsProvider, &GPSProvider::finished, this, &GPSRtk::_onGPSDisconnect);

    (void) QMetaObject::invokeMethod(this, "_onGPSConnect", Qt::AutoConnection);
}

void GPSRtk::disconnectGPS()
{
    if (_gpsProvider) {
        _requestGpsStop = true;
        if (!_gpsProvider->wait(kGPSThreadDisconnectTimeout)) {
            qCWarning(GPSRtkLog) << "Failed to wait for GPS thread exit. Consider increasing the timeout";
        }

        _gpsProvider->deleteLater();
        _gpsProvider = nullptr;
    }
}

bool GPSRtk::connected() const
{
    return (_gpsProvider ? _gpsProvider->isRunning() : false);
}

FactGroup *GPSRtk::gpsRtkFactGroup()
{
    return _gpsRtkFactGroup;
}

void GPSRtk::_satelliteInfoUpdate(const satellite_info_s &msg)
{
    qCDebug(GPSRtkLog) << Q_FUNC_INFO << QStringLiteral("%1 satellites").arg(msg.count);
    _gpsRtkFactGroup->numSatellites()->setRawValue(msg.count);
}

void GPSRtk::_sensorGnssRelativeUpdate(const sensor_gnss_relative_s &msg)
{
    qCDebug(GPSRtkLog) << Q_FUNC_INFO;
}

void GPSRtk::_sensorGpsUpdate(const sensor_gps_s &msg)
{
    qCDebug(GPSRtkLog) << Q_FUNC_INFO << QStringLiteral("alt=%1, long=%2, lat=%3").arg(msg.altitude_msl_m).arg(msg.longitude_deg).arg(msg.latitude_deg);
}

void GPSRtk::connectNTRIP()
{
    disconnectNTRIP();

    RTKSettings* const rtkSettings = SettingsManager::instance()->rtkSettings();
    const QString url = rtkSettings->ntripURL()->rawValue().toString();
    const bool ntripV1 = rtkSettings->ntripV1()->rawValue().toBool();
    const bool sendGGA = rtkSettings->ntripSendGGA()->rawValue().toBool();

    if (url.isEmpty()) {
        qCWarning(GPSRtkLog) << "NTRIP URL is empty";
        _gpsRtkFactGroup->ntripStatus()->setRawValue(tr("NTRIP URL is empty"));
        return;
    }

    _ntripFirstDataLogged = false;
    _gpsRtkFactGroup->ntripBytesReceived()->setRawValue(0);
    _gpsRtkFactGroup->ntripStatus()->setRawValue(tr("Connecting..."));

    QString logSafeUrl = url;
    const QString password = QUrl(url).password();
    if (!password.isEmpty()) {
        (void) logSafeUrl.replace(password, QStringLiteral("***"));
    }
    qCInfo(GPSRtkLog) << "Starting NTRIP:" << logSafeUrl << "ntripV1" << ntripV1 << "sendGGA" << sendGGA;

    _ntripClient = new NTRIPClient(this);
    _ntripClient->setSendGGA(sendGGA);

    (void) connect(_ntripClient, &NTRIPClient::RTCMDataUpdate,
                   _rtcmMavlink, &RTCMMavlink::RTCMDataUpdate);
    (void) connect(_ntripClient, &NTRIPClient::RTCMDataUpdate,
                   this, &GPSRtk::_onNTRIPData);
    (void) connect(_ntripClient, &NTRIPClient::connected,
                   this, &GPSRtk::_onNTRIPConnected);
    (void) connect(_ntripClient, &NTRIPClient::disconnected,
                   this, &GPSRtk::_onNTRIPDisconnected);
    (void) connect(_ntripClient, &NTRIPClient::errorOccurred,
                   this, &GPSRtk::_onNTRIPError);

    // Keep the VRS GGA position up to date while the client is alive
    (void) connect(QGCPositionManager::instance(), &QGCPositionManager::gcsPositionChanged,
                   _ntripClient, [this]() { _updateNTRIPGCSPosition(); });

    _ntripClient->connectToCaster(url, ntripV1);
}

void GPSRtk::disconnectNTRIP()
{
    if (_ntripClient) {
        _ntripClient->disconnectFromCaster();
        _ntripClient->deleteLater();
        _ntripClient = nullptr;
        _gpsRtkFactGroup->ntripConnected()->setRawValue(false);
        _gpsRtkFactGroup->ntripStatus()->setRawValue(QString());
    }
}

bool GPSRtk::ntripConnected() const
{
    return _ntripClient ? _ntripClient->isConnected() : false;
}

void GPSRtk::_onNTRIPConnected()
{
    qCDebug(GPSRtkLog) << "NTRIP connected";
    _gpsRtkFactGroup->ntripConnected()->setRawValue(true);
    _gpsRtkFactGroup->ntripStatus()->setRawValue(QString());
    _updateNTRIPGCSPosition();
}

void GPSRtk::_onNTRIPDisconnected()
{
    qCDebug(GPSRtkLog) << "NTRIP disconnected";
    _gpsRtkFactGroup->ntripConnected()->setRawValue(false);
    // NTRIPClient retries automatically; a final failure follows with errorOccurred and overwrites this
    _gpsRtkFactGroup->ntripStatus()->setRawValue(tr("Reconnecting..."));
}

void GPSRtk::_onNTRIPError(QString errorString)
{
    qCWarning(GPSRtkLog) << "NTRIP error:" << errorString;
    _gpsRtkFactGroup->ntripConnected()->setRawValue(false);
    _gpsRtkFactGroup->ntripStatus()->setRawValue(errorString);
}

void GPSRtk::_onNTRIPData(QByteArray data)
{
    if (!_ntripFirstDataLogged) {
        _ntripFirstDataLogged = true;
        qCInfo(GPSRtkLog) << "RTCM data flowing from NTRIP client, first chunk" << data.size() << "bytes";
    }
    qCDebug(GPSRtkLog) << "NTRIP RTCM chunk:" << data.size() << "bytes";

    Fact* const fact = _gpsRtkFactGroup->ntripBytesReceived();
    fact->setRawValue(fact->rawValue().toUInt() + static_cast<quint32>(data.size()));
}

void GPSRtk::_onActiveVehicleChanged(Vehicle *vehicle)
{
    if (vehicle) {
        (void) connect(vehicle, &Vehicle::coordinateChanged,
                       this, &GPSRtk::_onVehicleCoordinateChanged, Qt::UniqueConnection);
    }
    _updateNTRIPGCSPosition();
}

void GPSRtk::_onVehicleCoordinateChanged()
{
    _updateNTRIPGCSPosition();
}

void GPSRtk::_updateNTRIPGCSPosition()
{
    if (!_ntripClient) {
        return;
    }

    // VRS position source: prefer the active vehicle position (the GCS usually has no
    // position source of its own), fall back to the GCS position
    QGeoCoordinate pos;
    QString source;
    Vehicle* const activeVehicle = MultiVehicleManager::instance()->activeVehicle();
    if (activeVehicle && activeVehicle->coordinate().isValid()) {
        pos = activeVehicle->coordinate();
        source = QStringLiteral("vehicle");
    } else {
        const QGeoCoordinate gcsPos = QGCPositionManager::instance()->gcsPosition();
        if (gcsPos.isValid()) {
            pos = gcsPos;
            source = QStringLiteral("gcs");
        }
    }

    if (!pos.isValid()) {
        // Without a position no GGA can be sent, and VRS casters will not stream corrections.
        // Log only once per invalid period, this is called at telemetry rate.
        if (!_ntripNoPositionWarned) {
            _ntripNoPositionWarned = true;
            qCInfo(GPSRtkLog) << "No vehicle or GCS position available, cannot provide VRS position to NTRIP caster";
        }
        return;
    }
    if (_ntripNoPositionWarned) {
        _ntripNoPositionWarned = false;
        qCInfo(GPSRtkLog) << "Position available again, resuming VRS position updates (source:" << source << ")";
    }

    const double alt = std::isfinite(pos.altitude()) ? pos.altitude() : 0.0;
    qCDebug(GPSRtkLog) << "Pushing position to NTRIP client (source:" << source << "): lat" << pos.latitude()
                       << "lng" << pos.longitude() << "alt" << alt;
    _ntripClient->setGCSPosition(pos.latitude(), pos.longitude(), alt);
}
