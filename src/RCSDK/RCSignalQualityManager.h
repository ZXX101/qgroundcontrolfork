/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#pragma once

#include <QtCore/QLoggingCategory>
#include <QtCore/QObject>

Q_DECLARE_LOGGING_CATEGORY(RCSignalQualityManagerLog)

/// 遥控器链路信号质量(云卓RCSDK),取值0-100,单位%
/// 在Android的云卓遥控器(G12/G20等)上由QGCRCSDKBridge(Java)经JNI推送;
/// 其他平台/设备上恒为-1,表示不可用,QML侧据此隐藏显示
class RCSignalQualityManager : public QObject
{
    Q_OBJECT

public:
    static RCSignalQualityManager *instance();

    Q_PROPERTY(int signalQuality READ signalQuality NOTIFY signalQualityChanged)
    // 原始信号质量(KeyRawSignalQuality),ap=地面端(遥控器),dev=天空端(接收机),-1表示不可用
    Q_PROPERTY(int groundSnr    READ groundSnr    NOTIFY rawSignalQualityChanged)
    Q_PROPERTY(int groundPower  READ groundPower  NOTIFY rawSignalQualityChanged)
    Q_PROPERTY(int skySnr       READ skySnr       NOTIFY rawSignalQualityChanged)
    Q_PROPERTY(int skyPower     READ skyPower     NOTIFY rawSignalQualityChanged)
    Q_PROPERTY(int skyMcs       READ skyMcs       NOTIFY rawSignalQualityChanged)

    int signalQuality() const { return _signalQuality; }
    int groundSnr()     const { return _groundSnr; }
    int groundPower()   const { return _groundPower; }
    int skySnr()        const { return _skySnr; }
    int skyPower()      const { return _skyPower; }
    int skyMcs()        const { return _skyMcs; }

    /// 任意线程可调用(JNI回调线程),内部切到对象所在线程更新
    void setSignalQuality(int quality);

    /// 设置原始信号质量JSON(UI线程调用,由RCSDKBridge切线程保证)
    void setRawSignalQuality(const QString &json);

signals:
    void signalQualityChanged(int quality);
    void rawSignalQualityChanged();

private:
    explicit RCSignalQualityManager(QObject *parent = nullptr);

    int _signalQuality = -1;
    int _groundSnr   = -1;
    int _groundPower = -1;
    int _skySnr      = -1;
    int _skyPower    = -1;
    int _skyMcs      = -1;
};
