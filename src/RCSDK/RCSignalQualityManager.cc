/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "RCSignalQualityManager.h"
#include "QGCLoggingCategory.h"

#include <QtCore/QJsonDocument>
#include <QtCore/QJsonObject>
#include <QtCore/QThread>

QGC_LOGGING_CATEGORY(RCSignalQualityManagerLog, "qgc.rcsdk.rcsignalqualitymanager");

RCSignalQualityManager::RCSignalQualityManager(QObject *parent)
    : QObject(parent)
{
    qCDebug(RCSignalQualityManagerLog) << Q_FUNC_INFO;
}

RCSignalQualityManager *RCSignalQualityManager::instance()
{
    static RCSignalQualityManager *singleton = new RCSignalQualityManager();
    return singleton;
}

void RCSignalQualityManager::setSignalQuality(int quality)
{
    if (QThread::currentThread() != thread()) {
        QMetaObject::invokeMethod(this, [this, quality]() { setSignalQuality(quality); }, Qt::QueuedConnection);
        return;
    }

    if (_signalQuality == quality) {
        return;
    }

    _signalQuality = quality;
    emit signalQualityChanged(quality);
}

void RCSignalQualityManager::setRawSignalQuality(const QString &json)
{
    const QJsonDocument doc = QJsonDocument::fromJson(json.toUtf8());
    if (!doc.isObject()) {
        qCWarning(RCSignalQualityManagerLog) << "Invalid raw signal quality json:" << json;
        return;
    }

    const QJsonObject obj = doc.object();
    // JSON中数值为字符串形式("0"),兼容数字形式
    const auto toInt = [&obj](const QString &key) {
        const QJsonValue value = obj.value(key);
        if (value.isString()) {
            return value.toString().toInt();
        }
        return value.toInt(-1);
    };

    _groundSnr   = toInt(QStringLiteral("ap_snr"));
    _groundPower = toInt(QStringLiteral("ap_tx_power"));
    _skySnr      = toInt(QStringLiteral("dev_snr"));
    _skyPower    = toInt(QStringLiteral("dev_tx_power"));
    _skyMcs      = toInt(QStringLiteral("dev_tx_mcs"));

    emit rawSignalQualityChanged();
}
