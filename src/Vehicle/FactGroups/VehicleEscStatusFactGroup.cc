/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "VehicleEscStatusFactGroup.h"
#include "Vehicle.h"

VehicleEscStatusFactGroup::VehicleEscStatusFactGroup(QObject *parent)
    : FactGroup(1000, QStringLiteral(":/json/Vehicle/EscStatusFactGroup.json"), parent)
{
    _addFact(&_indexFact);

    _rpmFacts[0] = &_rpm1; _rpmFacts[1] = &_rpm2; _rpmFacts[2] = &_rpm3; _rpmFacts[3] = &_rpm4;
    _rpmFacts[4] = &_rpm5; _rpmFacts[5] = &_rpm6; _rpmFacts[6] = &_rpm7; _rpmFacts[7] = &_rpm8;

    _currentFacts[0] = &_current1; _currentFacts[1] = &_current2; _currentFacts[2] = &_current3; _currentFacts[3] = &_current4;
    _currentFacts[4] = &_current5; _currentFacts[5] = &_current6; _currentFacts[6] = &_current7; _currentFacts[7] = &_current8;

    _voltageFacts[0] = &_voltage1; _voltageFacts[1] = &_voltage2; _voltageFacts[2] = &_voltage3; _voltageFacts[3] = &_voltage4;
    _voltageFacts[4] = &_voltage5; _voltageFacts[5] = &_voltage6; _voltageFacts[6] = &_voltage7; _voltageFacts[7] = &_voltage8;

    _tempFacts[0] = &_temp1; _tempFacts[1] = &_temp2; _tempFacts[2] = &_temp3; _tempFacts[3] = &_temp4;
    _tempFacts[4] = &_temp5; _tempFacts[5] = &_temp6; _tempFacts[6] = &_temp7; _tempFacts[7] = &_temp8;

    for (int i = 0; i < _maxEscCount; i++) {
        _addFact(_rpmFacts[i]);
        _addFact(_currentFacts[i]);
        _addFact(_voltageFacts[i]);
        _addFact(_tempFacts[i]);
    }

    _addFact(&_escCountFact);
}

void VehicleEscStatusFactGroup::handleMessage(Vehicle *vehicle, const mavlink_message_t &message)
{
    Q_UNUSED(vehicle);

    switch (message.msgid) {
    case MAVLINK_MSG_ID_ESC_STATUS:
    {
        mavlink_esc_status_t content{};
        mavlink_msg_esc_status_decode(&message, &content);

        index()->setRawValue(content.index);

        int base = content.index;
        for (int i = 0; i < 4; i++) {
            int idx = base + i;
            if (idx < _maxEscCount) {
                _rpmFacts[idx]->setRawValue(content.rpm[i]);
                _currentFacts[idx]->setRawValue(content.current[i]);
                _voltageFacts[idx]->setRawValue(content.voltage[i]);
            }
        }

        _setTelemetryAvailable(true);
    }
    break;

    case MAVLINK_MSG_ID_ESC_INFO:
    {
        mavlink_esc_info_t content{};
        mavlink_msg_esc_info_decode(&message, &content);

        escCount()->setRawValue(content.count);

        int base = content.index;
        for (int i = 0; i < 4; i++) {
            int idx = base + i;
            if (idx < _maxEscCount) {
                if (content.temperature[i] == INT16_MAX) {
                    _tempFacts[idx]->setRawValue(qQNaN());
                } else {
                    _tempFacts[idx]->setRawValue(content.temperature[i] / 100.0);
                }
            }
        }

        if (base == 0 && content.count > 0) {
            _setTelemetryAvailable(true);
        }
    }
    break;

#ifdef MAVLINK_MSG_ID_ESC_TELEMETRY_1_TO_4
    case MAVLINK_MSG_ID_ESC_TELEMETRY_1_TO_4:
    {
        mavlink_esc_telemetry_1_to_4_t content{};
        mavlink_msg_esc_telemetry_1_to_4_decode(&message, &content);

        for (int i = 0; i < 4 && i < _maxEscCount; i++) {
            _tempFacts[i]->setRawValue(content.temperature[i]);
            _voltageFacts[i]->setRawValue(content.voltage[i] / 100.0);
            _currentFacts[i]->setRawValue(content.current[i] / 100.0);
            _rpmFacts[i]->setRawValue(content.rpm[i]);
        }

        _setTelemetryAvailable(true);
    }
    break;
#endif

#ifdef MAVLINK_MSG_ID_ESC_TELEMETRY_5_TO_8
    case MAVLINK_MSG_ID_ESC_TELEMETRY_5_TO_8:
    {
        mavlink_esc_telemetry_5_to_8_t content{};
        mavlink_msg_esc_telemetry_5_to_8_decode(&message, &content);

        for (int i = 0; i < 4; i++) {
            int idx = 4 + i;
            if (idx < _maxEscCount) {
                _tempFacts[idx]->setRawValue(content.temperature[i]);
                _voltageFacts[idx]->setRawValue(content.voltage[i] / 100.0);
                _currentFacts[idx]->setRawValue(content.current[i] / 100.0);
                _rpmFacts[idx]->setRawValue(content.rpm[i]);
            }
        }

        _setTelemetryAvailable(true);
    }
    break;
#endif

#ifdef MAVLINK_MSG_ID_ESC_TELEMETRY_9_TO_12
    case MAVLINK_MSG_ID_ESC_TELEMETRY_9_TO_12:
    {
        mavlink_esc_telemetry_9_to_12_t content{};
        mavlink_msg_esc_telemetry_9_to_12_decode(&message, &content);

        for (int i = 0; i < 4; i++) {
            int idx = 8 + i;
            if (idx < _maxEscCount) {
                _tempFacts[idx]->setRawValue(content.temperature[i]);
                _voltageFacts[idx]->setRawValue(content.voltage[i] / 100.0);
                _currentFacts[idx]->setRawValue(content.current[i] / 100.0);
                _rpmFacts[idx]->setRawValue(content.rpm[i]);
            }
        }

        _setTelemetryAvailable(true);
    }
    break;
#endif

    default:
        break;
    }
}
