/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#pragma once

#include <QtCore/QLoggingCategory>
#include <QtCore/QElapsedTimer>
#include <QtQuick/QQuickItem>

#include "FactPanelController.h"
#include "QGCMAVLink.h"

Q_DECLARE_LOGGING_CATEGORY(XFRadioComponentControllerLog)

class XFRadioComponentController : public FactPanelController
{
    Q_OBJECT

    Q_PROPERTY(int  channelCount      READ channelCount     NOTIFY channelCountChanged)
    Q_PROPERTY(int  minChannelCount   MEMBER _chanMinimum   CONSTANT)
    Q_PROPERTY(bool calibrating       READ calibrating      NOTIFY calibratingChanged)
    Q_PROPERTY(bool calibrationDone   READ calibrationDone  NOTIFY calibrationDoneChanged)
    Q_PROPERTY(int  channelsCalibrated READ channelsCalibrated NOTIFY channelsCalibratedChanged)

    Q_PROPERTY(bool rollChannelMapped     READ rollChannelMapped     NOTIFY rollChannelMappedChanged)
    Q_PROPERTY(bool pitchChannelMapped    READ pitchChannelMapped    NOTIFY pitchChannelMappedChanged)
    Q_PROPERTY(bool yawChannelMapped      READ yawChannelMapped      NOTIFY yawChannelMappedChanged)
    Q_PROPERTY(bool throttleChannelMapped READ throttleChannelMapped NOTIFY throttleChannelMappedChanged)

    Q_PROPERTY(int rollChannelRCValue     READ rollChannelRCValue     NOTIFY rollChannelRCValueChanged)
    Q_PROPERTY(int pitchChannelRCValue    READ pitchChannelRCValue    NOTIFY pitchChannelRCValueChanged)
    Q_PROPERTY(int yawChannelRCValue      READ yawChannelRCValue      NOTIFY yawChannelRCValueChanged)
    Q_PROPERTY(int throttleChannelRCValue READ throttleChannelRCValue NOTIFY throttleChannelRCValueChanged)

    Q_PROPERTY(bool rollChannelReversed     READ rollChannelReversed     NOTIFY rollChannelReversedChanged)
    Q_PROPERTY(bool pitchChannelReversed    READ pitchChannelReversed    NOTIFY pitchChannelReversedChanged)
    Q_PROPERTY(bool yawChannelReversed      READ yawChannelReversed      NOTIFY yawChannelReversedChanged)
    Q_PROPERTY(bool throttleChannelReversed READ throttleChannelReversed NOTIFY throttleChannelReversedChanged)

    Q_PROPERTY(int  transmitterMode READ transmitterMode WRITE setTransmitterMode NOTIFY transmitterModeChanged)
    Q_PROPERTY(QString imageHelp    MEMBER _imageHelp    NOTIFY imageHelpChanged)

    Q_PROPERTY(QVariantList channelMinMax READ channelMinMax NOTIFY channelMinMaxChanged)

public:
    XFRadioComponentController(QObject *parent = nullptr);
    ~XFRadioComponentController();

    enum BindModes {
        DSM2,
        DSMX7,
        DSMX8
    };
    Q_ENUM(BindModes)

    Q_INVOKABLE void start();
    Q_INVOKABLE void startCalibration();
    Q_INVOKABLE void stopCalibration();
    Q_INVOKABLE void confirmCalibration();
    Q_INVOKABLE void cancelButtonClicked();
    Q_INVOKABLE void spektrumBindMode(int mode);
    Q_INVOKABLE void crsfBindMode();
    Q_INVOKABLE void copyTrims();

    int  channelCount()      const { return _chanCount; }
    bool calibrating()       const { return _calibrating; }
    bool calibrationDone()   const { return _calibrationDone; }
    int  channelsCalibrated() const;

    int  rollChannelRCValue();
    int  pitchChannelRCValue();
    int  yawChannelRCValue();
    int  throttleChannelRCValue();

    bool rollChannelMapped();
    bool pitchChannelMapped();
    bool yawChannelMapped();
    bool throttleChannelMapped();

    bool rollChannelReversed();
    bool pitchChannelReversed();
    bool yawChannelReversed();
    bool throttleChannelReversed();

    int  transmitterMode() const { return _transmitterMode; }
    void setTransmitterMode(int mode);

    QVariantList channelMinMax();

signals:
    void channelCountChanged(int channelCount);
    void calibratingChanged(bool calibrating);
    void calibrationDoneChanged(bool calibrationDone);
    void channelsCalibratedChanged(int count);

    void rollChannelMappedChanged(bool mapped);
    void pitchChannelMappedChanged(bool mapped);
    void yawChannelMappedChanged(bool mapped);
    void throttleChannelMappedChanged(bool mapped);

    void rollChannelRCValueChanged(int rcValue);
    void pitchChannelRCValueChanged(int rcValue);
    void yawChannelRCValueChanged(int rcValue);
    void throttleChannelRCValueChanged(int rcValue);

    void rollChannelReversedChanged(bool reversed);
    void pitchChannelReversedChanged(bool reversed);
    void yawChannelReversedChanged(bool reversed);
    void throttleChannelReversedChanged(bool reversed);

    void imageHelpChanged(QString source);
    void transmitterModeChanged(int mode);
    void channelMinMaxChanged();
    void functionMappingChangedAPMReboot();
    void throttleReversedCalFailure();

private slots:
    void _rcChannelsChanged(int channelCount, int pwmValues[QGCMAVLink::maxRcChannels]);

private:
    enum rcCalFunctions {
        rcCalFunctionRoll,
        rcCalFunctionPitch,
        rcCalFunctionYaw,
        rcCalFunctionThrottle,
        rcCalFunctionMax,
    };

    struct FunctionInfo {
        const char *parameterName;
    };
    const FunctionInfo *_functionInfo() const;

    bool _px4Vehicle() const;

    void _setInternalCalibrationValuesFromParameters();
    void _validateCalibration();
    void _writeCalibration();
    void _signalAllAttitudeValueChanges();

    bool _channelReversedParamValue(int channel);
    void _setChannelReversedParamValue(int channel, bool reversed);

    void _loadSettings();
    void _storeSettings();
    void _setHelpImage(const char *imageFile);

    static constexpr int _chanMax = 18;
    static constexpr int _chanMinimum = 5;

    struct ChannelInfo {
        enum rcCalFunctions function;
        bool reversed;
        int rcMin;
        int rcMax;
        int rcTrim;
    };

    int _chanCount = 0;
    int _rgFunctionChannelMapping[rcCalFunctionMax];
    ChannelInfo _rgChannelInfo[_chanMax];

    int _rcRawValue[_chanMax]{};

    bool _calibrating = false;
    bool _calibrationDone = false;

    float _rcMin[_chanMax]{};
    float _rcMax[_chanMax]{};
    float _rcTrim[_chanMax]{};

    int _transmitterMode = 2;
    QString _revParamFormat;
    bool _revParamIsBool = false;
    QString _imageHelp;

    static constexpr int _rcCalPWMValidMinValue = 1300;
    static constexpr int _rcCalPWMValidMaxValue = 1700;
    static constexpr int _rcCalPWMCenterPoint = ((_rcCalPWMValidMaxValue - _rcCalPWMValidMinValue) / 2.0f) + _rcCalPWMValidMinValue;
    static constexpr int _rcCalPWMDefaultMinValue = 1000;
    static constexpr int _rcCalPWMDefaultMaxValue = 2000;
    static constexpr int _rcCalRoughCenterDelta = 50;

    static constexpr const char *_settingsGroup = "RadioCalibration";
    static constexpr const char *_settingsKeyTransmitterMode = "TransmitterMode";
    static constexpr const char *_imageCenter = "radioCenter.png";
};
