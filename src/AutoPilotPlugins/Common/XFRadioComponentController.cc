/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "XFRadioComponentController.h"
#include "Fact.h"
#include "ParameterManager.h"
#include "QGCApplication.h"
#include "QGCLoggingCategory.h"
#include "Vehicle.h"

#include <QtCore/QSettings>

QGC_LOGGING_CATEGORY(XFRadioComponentControllerLog, "qgc.autopilotplugins.common.xfradiocomponentcontroller")

XFRadioComponentController::XFRadioComponentController(QObject *parent)
    : FactPanelController(parent)
{
    if (parameterExists(ParameterManager::defaultComponentId, QStringLiteral("RC1_REVERSED"))) {
        _revParamFormat = "RC%1_REVERSED";
        _revParamIsBool = true;
    } else {
        _revParamFormat = "RC%1_REV";
        _revParamIsBool = false;
    }

    (void) connect(_vehicle, &Vehicle::rcChannelsChanged, this, &XFRadioComponentController::_rcChannelsChanged);

    _loadSettings();

    for (int i = 0; i < _chanMax; i++) {
        _rgFunctionChannelMapping[i] = _chanMax;
        _rgChannelInfo[i].function = rcCalFunctionMax;
        _rgChannelInfo[i].reversed = false;
        _rgChannelInfo[i].rcMin = _rcCalPWMCenterPoint;
        _rgChannelInfo[i].rcMax = _rcCalPWMCenterPoint;
        _rgChannelInfo[i].rcTrim = _rcCalPWMCenterPoint;
    }

    for (int i = 0; i < _chanMax; i++) {
        _rcMin[i] = 3000;
        _rcMax[i] = 0;
        _rcTrim[i] = 1500;
    }
}

XFRadioComponentController::~XFRadioComponentController()
{
    _storeSettings();
}

void XFRadioComponentController::start()
{
    _setInternalCalibrationValuesFromParameters();
}

void XFRadioComponentController::_rcChannelsChanged(int channelCount, int pwmValues[QGCMAVLink::maxRcChannels])
{
    if (channelCount == 0) {
        for (int channel = 0; channel < 16; channel++) {
            if (pwmValues[channel] != INT16_MAX) channelCount++;
        }
    }

    for (int channel = 0; channel < channelCount; channel++) {
        const int channelValue = pwmValues[channel];
        if (channelValue == -1) continue;

        _rcRawValue[channel] = channelValue;

        if (_rgChannelInfo[channel].function != rcCalFunctionMax) {
            switch (_rgChannelInfo[channel].function) {
            case rcCalFunctionRoll:
                emit rollChannelRCValueChanged(channelValue);
                break;
            case rcCalFunctionPitch:
                emit pitchChannelRCValueChanged(channelValue);
                break;
            case rcCalFunctionYaw:
                emit yawChannelRCValueChanged(channelValue);
                break;
            case rcCalFunctionThrottle:
                emit throttleChannelRCValueChanged(channelValue);
                break;
            default:
                break;
            }
        }

        if (_calibrating && channelValue > 800 && channelValue < 2200) {
            if (channelValue < _rcMin[channel]) {
                _rcMin[channel] = channelValue;
                emit channelMinMaxChanged();
            }
            if (channelValue > _rcMax[channel]) {
                _rcMax[channel] = channelValue;
                emit channelMinMaxChanged();
            }

            int calibrated = 0;
            for (int i = 0; i < _chanMax; i++) {
                if (_rcMax[i] - _rcMin[i] > 100) {
                    calibrated++;
                }
            }
            if (calibrated != channelsCalibrated()) {
                emit channelsCalibratedChanged(calibrated);
            }
        }
    }

    if (!_calibrating) {
        if (_chanCount != channelCount) {
            _chanCount = channelCount;
            emit channelCountChanged(_chanCount);
        }
    }
}

void XFRadioComponentController::startCalibration()
{
    if (_chanCount < _chanMinimum) return;

    for (int i = 0; i < _chanMax; i++) {
        _rcMin[i] = 3000;
        _rcMax[i] = 0;
        _rcTrim[i] = 1500;
    }

    _calibrating = true;
    _calibrationDone = false;
    emit calibratingChanged(true);
    emit calibrationDoneChanged(false);
    emit channelMinMaxChanged();
    emit channelsCalibratedChanged(0);

    _vehicle->startCalibration(QGCMAVLink::CalibrationRadio);
}

void XFRadioComponentController::stopCalibration()
{
    _calibrating = false;
    _calibrationDone = true;
    emit calibratingChanged(false);
    emit calibrationDoneChanged(true);

    _vehicle->stopCalibration(false);

    for (int i = 0; i < _chanMax; i++) {
        _rcTrim[i] = qMin(qMax(static_cast<float>(_rcRawValue[i]), _rcMin[i]), _rcMax[i]);
    }

    emit channelMinMaxChanged();
}

void XFRadioComponentController::confirmCalibration()
{
    if (!_calibrationDone) return;

    _writeCalibration();

    _calibrationDone = false;
    emit calibrationDoneChanged(false);
}

void XFRadioComponentController::cancelButtonClicked()
{
    _calibrating = false;
    _calibrationDone = false;
    emit calibratingChanged(false);
    emit calibrationDoneChanged(false);

    if (_vehicle) {
        _vehicle->stopCalibration(false);
    }

    _setInternalCalibrationValuesFromParameters();
}

void XFRadioComponentController::_validateCalibration()
{
    for (int chan = 0; chan < _chanMax; chan++) {
        ChannelInfo *info = &_rgChannelInfo[chan];

        if (chan < _chanCount) {
            if (info->rcMin > _rcCalPWMValidMinValue || info->rcMax < _rcCalPWMValidMaxValue) {
                info->rcMin = _rcCalPWMDefaultMinValue;
                info->rcMax = _rcCalPWMDefaultMaxValue;
                info->rcTrim = info->rcMin + ((info->rcMax - info->rcMin) / 2);
            } else {
                switch (_rgChannelInfo[chan].function) {
                case rcCalFunctionThrottle:
                case rcCalFunctionYaw:
                case rcCalFunctionRoll:
                case rcCalFunctionPitch:
                    if (info->rcTrim < info->rcMin) {
                        info->rcTrim = info->rcMin;
                    } else if (info->rcTrim > info->rcMax) {
                        info->rcTrim = info->rcMax;
                    }
                    break;
                default:
                    info->rcTrim = info->rcMin + ((info->rcMax - info->rcMin) / 2);
                    break;
                }
            }
        } else {
            info->rcMin = _rcCalPWMDefaultMinValue;
            info->rcMax = _rcCalPWMDefaultMaxValue;
            info->rcTrim = info->rcMin + ((info->rcMax - info->rcMin) / 2);
            info->reversed = false;
        }
    }
}

void XFRadioComponentController::_writeCalibration()
{
    if (!_vehicle) return;

    const QString minTpl("RC%1_MIN");
    const QString maxTpl("RC%1_MAX");
    const QString trimTpl("RC%1_TRIM");

    for (int chan = 0; chan < _chanMax; chan++) {
        const int oneBasedChannel = chan + 1;

        if (!parameterExists(ParameterManager::defaultComponentId, minTpl.arg(oneBasedChannel))) continue;

        if (chan < _chanCount && _rcMin[chan] < _rcMax[chan] && _rcMin[chan] != 0 && _rcMax[chan] != 0 &&
            _rcTrim[chan] <= _rcMax[chan] && _rcTrim[chan] >= _rcMin[chan] && _rcMin[chan] != _rcMax[chan]) {

            _rgChannelInfo[chan].rcMin = static_cast<int>(_rcMin[chan]);
            _rgChannelInfo[chan].rcMax = static_cast<int>(_rcMax[chan]);
            _rgChannelInfo[chan].rcTrim = static_cast<int>(_rcTrim[chan]);

            if (_rgChannelInfo[chan].function == rcCalFunctionMax) {
                _rgChannelInfo[chan].rcTrim = _rgChannelInfo[chan].rcMin + ((_rgChannelInfo[chan].rcMax - _rgChannelInfo[chan].rcMin) / 2);
            }
        } else {
            continue;
        }
    }

    _validateCalibration();

    if (!_px4Vehicle() && _vehicle->multiRotor() && _rgChannelInfo[_rgFunctionChannelMapping[rcCalFunctionThrottle]].reversed) {
        emit throttleReversedCalFailure();
        return;
    }

    for (int chan = 0; chan < _chanMax; chan++) {
        ChannelInfo *const info = &_rgChannelInfo[chan];
        const int oneBasedChannel = chan + 1;

        if (!parameterExists(ParameterManager::defaultComponentId, minTpl.arg(oneBasedChannel))) continue;

        Fact *paramFact = getParameterFact(ParameterManager::defaultComponentId, trimTpl.arg(oneBasedChannel));
        if (paramFact) {
            paramFact->setRawValue(static_cast<float>(info->rcTrim));
        }
        paramFact = getParameterFact(ParameterManager::defaultComponentId, minTpl.arg(oneBasedChannel));
        if (paramFact) {
            paramFact->setRawValue(static_cast<float>(info->rcMin));
        }
        paramFact = getParameterFact(ParameterManager::defaultComponentId, maxTpl.arg(oneBasedChannel));
        if (paramFact) {
            paramFact->setRawValue(static_cast<float>(info->rcMax));
        }

        if (_vehicle->px4Firmware() || _vehicle->multiRotor()) {
            bool reversed;
            if (_px4Vehicle() || info->function != rcCalFunctionPitch) {
                reversed = info->reversed;
            } else {
                reversed = !info->reversed;
            }
            _setChannelReversedParamValue(chan, reversed);
        }
    }

    bool mappingChanged = false;
    for (size_t i = 0; i < rcCalFunctionMax; i++) {
        int32_t paramChannel;
        if (_rgFunctionChannelMapping[i] == _chanMax) {
            paramChannel = 0;
        } else {
            paramChannel = _rgFunctionChannelMapping[i] + 1;
        }

        const char *const paramName = _functionInfo()[i].parameterName;
        if (paramName) {
            Fact *paramFact = getParameterFact(ParameterManager::defaultComponentId, paramName);
            if (paramFact && paramFact->rawValue().toInt() != paramChannel) {
                paramFact->setRawValue(paramChannel);
                mappingChanged = true;
            }
        }
    }

    if (mappingChanged && !_px4Vehicle()) {
        emit functionMappingChangedAPMReboot();
    }

    if (_px4Vehicle()) {
        if (parameterExists(ParameterManager::defaultComponentId, QStringLiteral("RC_CHAN_CNT"))) {
            getParameterFact(ParameterManager::defaultComponentId, QStringLiteral("RC_CHAN_CNT"))->setRawValue(_chanCount);
        }
    }

    _setInternalCalibrationValuesFromParameters();
}

void XFRadioComponentController::_setInternalCalibrationValuesFromParameters()
{
    for (int i = 0; i < _chanMax; i++) {
        ChannelInfo *const info = &_rgChannelInfo[i];
        info->function = rcCalFunctionMax;
    }

    for (size_t i = 0; i < rcCalFunctionMax; i++) {
        _rgFunctionChannelMapping[i] = _chanMax;
    }

    const QString minTpl("RC%1_MIN");
    const QString maxTpl("RC%1_MAX");
    const QString trimTpl("RC%1_TRIM");

    for (int i = 0; i < _chanMax; ++i) {
        ChannelInfo *const info = &_rgChannelInfo[i];

        if (!parameterExists(ParameterManager::defaultComponentId, minTpl.arg(i+1))) {
            info->rcTrim = 1500;
            info->rcMin = 1100;
            info->rcMax = 1900;
            info->reversed = false;
            continue;
        }

        Fact *paramFact = getParameterFact(ParameterManager::defaultComponentId, trimTpl.arg(i+1));
        if (paramFact) {
            info->rcTrim = paramFact->rawValue().toInt();
        }

        paramFact = getParameterFact(ParameterManager::defaultComponentId, minTpl.arg(i+1));
        if (paramFact) {
            info->rcMin = paramFact->rawValue().toInt();
        }

        paramFact = getParameterFact(ParameterManager::defaultComponentId, maxTpl.arg(i+1));
        if (paramFact) {
            info->rcMax = paramFact->rawValue().toInt();
        }

        info->reversed = _channelReversedParamValue(i);
    }

    for (int i = 0; i < rcCalFunctionMax; i++) {
        const char *const paramName = _functionInfo()[i].parameterName;
        if (paramName) {
            Fact *const paramFact = getParameterFact(ParameterManager::defaultComponentId, paramName);
            if (paramFact) {
                int32_t paramChannel = paramFact->rawValue().toInt();
                if (paramChannel > 0 && paramChannel <= _chanMax) {
                    _rgFunctionChannelMapping[i] = paramChannel - 1;
                    _rgChannelInfo[paramChannel - 1].function = static_cast<rcCalFunctions>(i);
                }
            }
        }
    }

    _signalAllAttitudeValueChanges();
}

const struct XFRadioComponentController::FunctionInfo *XFRadioComponentController::_functionInfo(void) const
{
    static constexpr const struct FunctionInfo rgFunctionInfoPX4[rcCalFunctionMax] = {
        { "RC_MAP_ROLL" },
        { "RC_MAP_PITCH" },
        { "RC_MAP_YAW" },
        { "RC_MAP_THROTTLE" }
    };

    static constexpr const struct FunctionInfo rgFunctionInfoAPM[rcCalFunctionMax] = {
        { "RCMAP_ROLL" },
        { "RCMAP_PITCH" },
        { "RCMAP_YAW" },
        { "RCMAP_THROTTLE" }
    };

    return (_px4Vehicle() ? rgFunctionInfoPX4 : rgFunctionInfoAPM);
}

bool XFRadioComponentController::_px4Vehicle() const
{
    return (_vehicle->firmwareType() == MAV_AUTOPILOT_PX4);
}

int XFRadioComponentController::rollChannelRCValue()
{
    if (_rgFunctionChannelMapping[rcCalFunctionRoll] != _chanMax) {
        return _rcRawValue[_rgFunctionChannelMapping[rcCalFunctionRoll]];
    }
    return 1500;
}

int XFRadioComponentController::pitchChannelRCValue()
{
    if (_rgFunctionChannelMapping[rcCalFunctionPitch] != _chanMax) {
        return _rcRawValue[_rgFunctionChannelMapping[rcCalFunctionPitch]];
    }
    return 1500;
}

int XFRadioComponentController::yawChannelRCValue()
{
    if (_rgFunctionChannelMapping[rcCalFunctionYaw] != _chanMax) {
        return _rcRawValue[_rgFunctionChannelMapping[rcCalFunctionYaw]];
    }
    return 1500;
}

int XFRadioComponentController::throttleChannelRCValue()
{
    if (_rgFunctionChannelMapping[rcCalFunctionThrottle] != _chanMax) {
        return _rcRawValue[_rgFunctionChannelMapping[rcCalFunctionThrottle]];
    }
    return 1500;
}

bool XFRadioComponentController::rollChannelMapped()
{
    return (_rgFunctionChannelMapping[rcCalFunctionRoll] != _chanMax);
}

bool XFRadioComponentController::pitchChannelMapped()
{
    return (_rgFunctionChannelMapping[rcCalFunctionPitch] != _chanMax);
}

bool XFRadioComponentController::yawChannelMapped()
{
    return (_rgFunctionChannelMapping[rcCalFunctionYaw] != _chanMax);
}

bool XFRadioComponentController::throttleChannelMapped()
{
    return (_rgFunctionChannelMapping[rcCalFunctionThrottle] != _chanMax);
}

bool XFRadioComponentController::rollChannelReversed()
{
    if (_rgFunctionChannelMapping[rcCalFunctionRoll] != _chanMax) {
        return _rgChannelInfo[_rgFunctionChannelMapping[rcCalFunctionRoll]].reversed;
    }
    return false;
}

bool XFRadioComponentController::pitchChannelReversed()
{
    if (_rgFunctionChannelMapping[rcCalFunctionPitch] != _chanMax) {
        return _rgChannelInfo[_rgFunctionChannelMapping[rcCalFunctionPitch]].reversed;
    }
    return false;
}

bool XFRadioComponentController::yawChannelReversed()
{
    if (_rgFunctionChannelMapping[rcCalFunctionYaw] != _chanMax) {
        return _rgChannelInfo[_rgFunctionChannelMapping[rcCalFunctionYaw]].reversed;
    }
    return false;
}

bool XFRadioComponentController::throttleChannelReversed()
{
    if (_rgFunctionChannelMapping[rcCalFunctionThrottle] != _chanMax) {
        return _rgChannelInfo[_rgFunctionChannelMapping[rcCalFunctionThrottle]].reversed;
    }
    return false;
}

int XFRadioComponentController::channelsCalibrated() const
{
    int count = 0;
    for (int i = 0; i < _chanMax; i++) {
        if (_rcMax[i] - _rcMin[i] > 100) {
            count++;
        }
    }
    return count;
}

QVariantList XFRadioComponentController::channelMinMax()
{
    QVariantList list;
    for (int i = 0; i < _chanMax; i++) {
        QVariantMap map;
        map["channel"] = i + 1;
        map["min"] = static_cast<int>(_rcMin[i]);
        map["max"] = static_cast<int>(_rcMax[i]);
        map["range"] = static_cast<int>(_rcMax[i] - _rcMin[i]);
        map["hasData"] = (_rcMax[i] - _rcMin[i] > 100);
        list.append(map);
    }
    return list;
}

void XFRadioComponentController::setTransmitterMode(int mode)
{
    if (mode == 1 || mode == 2) {
        _transmitterMode = mode;
        emit transmitterModeChanged(mode);
    }
}

void XFRadioComponentController::spektrumBindMode(int mode)
{
    _vehicle->pairRX(RC_TYPE_SPEKTRUM, mode);
}

void XFRadioComponentController::crsfBindMode()
{
    _vehicle->pairRX(RC_TYPE_CRSF, 0);
}

void XFRadioComponentController::copyTrims()
{
    _vehicle->startCalibration(QGCMAVLink::CalibrationCopyTrims);
}

bool XFRadioComponentController::_channelReversedParamValue(int channel)
{
    Fact *const paramFact = getParameterFact(ParameterManager::defaultComponentId, _revParamFormat.arg(channel+1));
    if (paramFact) {
        if (_revParamIsBool) {
            return paramFact->rawValue().toBool();
        } else {
            bool convertOk;
            float floatReversed = paramFact->rawValue().toFloat(&convertOk);
            if (!convertOk) {
                floatReversed = 1.0f;
            }
            return floatReversed == -1.0f;
        }
    }
    return false;
}

void XFRadioComponentController::_setChannelReversedParamValue(int channel, bool reversed)
{
    Fact *const paramFact = getParameterFact(ParameterManager::defaultComponentId, _revParamFormat.arg(channel+1));
    if (paramFact) {
        if (_revParamIsBool) {
            paramFact->setRawValue(reversed);
        } else {
            paramFact->setRawValue(reversed ? -1.0f : 1.0f);
        }
    }
}

void XFRadioComponentController::_signalAllAttitudeValueChanges()
{
    emit rollChannelMappedChanged(rollChannelMapped());
    emit pitchChannelMappedChanged(pitchChannelMapped());
    emit yawChannelMappedChanged(yawChannelMapped());
    emit throttleChannelMappedChanged(throttleChannelMapped());

    emit rollChannelReversedChanged(rollChannelReversed());
    emit pitchChannelReversedChanged(pitchChannelReversed());
    emit yawChannelReversedChanged(yawChannelReversed());
    emit throttleChannelReversedChanged(throttleChannelReversed());
}

void XFRadioComponentController::_loadSettings()
{
    QSettings settings;
    settings.beginGroup(_settingsGroup);
    _transmitterMode = settings.value(_settingsKeyTransmitterMode, 2).toInt();
    settings.endGroup();

    if (!(_transmitterMode == 1 || _transmitterMode == 2)) {
        _transmitterMode = 2;
    }
}

void XFRadioComponentController::_storeSettings()
{
    QSettings settings;
    settings.beginGroup(_settingsGroup);
    settings.setValue(_settingsKeyTransmitterMode, _transmitterMode);
    settings.endGroup();
}

void XFRadioComponentController::_setHelpImage(const char *imageFile)
{
    static constexpr const char *imageFilePrefix = "calibration/";
    static constexpr const char *imageFileMode1Dir = "mode1/";
    static constexpr const char *imageFileMode2Dir = "mode2/";

    QString file = imageFilePrefix;

    if (_transmitterMode == 1) {
        file += imageFileMode1Dir;
    } else if (_transmitterMode == 2) {
        file += imageFileMode2Dir;
    } else {
        return;
    }
    file += imageFile;

    _imageHelp = file;
    emit imageHelpChanged(file);
}
