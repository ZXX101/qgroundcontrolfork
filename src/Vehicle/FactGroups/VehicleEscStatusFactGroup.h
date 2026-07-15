/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#pragma once

#include "FactGroup.h"

class VehicleEscStatusFactGroup : public FactGroup
{
    Q_OBJECT
    Q_PROPERTY(Fact *index          READ index          CONSTANT)
    Q_PROPERTY(Fact *rpmFirst       READ rpmFirst       CONSTANT)
    Q_PROPERTY(Fact *rpmSecond      READ rpmSecond      CONSTANT)
    Q_PROPERTY(Fact *rpmThird       READ rpmThird       CONSTANT)
    Q_PROPERTY(Fact *rpmFourth      READ rpmFourth      CONSTANT)
    Q_PROPERTY(Fact *rpmFifth       READ rpmFifth       CONSTANT)
    Q_PROPERTY(Fact *rpmSixth       READ rpmSixth       CONSTANT)
    Q_PROPERTY(Fact *rpmSeventh     READ rpmSeventh     CONSTANT)
    Q_PROPERTY(Fact *rpmEighth      READ rpmEighth      CONSTANT)
    Q_PROPERTY(Fact *currentFirst   READ currentFirst   CONSTANT)
    Q_PROPERTY(Fact *currentSecond  READ currentSecond  CONSTANT)
    Q_PROPERTY(Fact *currentThird   READ currentThird   CONSTANT)
    Q_PROPERTY(Fact *currentFourth  READ currentFourth  CONSTANT)
    Q_PROPERTY(Fact *currentFifth   READ currentFifth   CONSTANT)
    Q_PROPERTY(Fact *currentSixth   READ currentSixth   CONSTANT)
    Q_PROPERTY(Fact *currentSeventh READ currentSeventh CONSTANT)
    Q_PROPERTY(Fact *currentEighth  READ currentEighth  CONSTANT)
    Q_PROPERTY(Fact *voltageFirst   READ voltageFirst   CONSTANT)
    Q_PROPERTY(Fact *voltageSecond  READ voltageSecond  CONSTANT)
    Q_PROPERTY(Fact *voltageThird   READ voltageThird   CONSTANT)
    Q_PROPERTY(Fact *voltageFourth  READ voltageFourth  CONSTANT)
    Q_PROPERTY(Fact *voltageFifth   READ voltageFifth   CONSTANT)
    Q_PROPERTY(Fact *voltageSixth   READ voltageSixth   CONSTANT)
    Q_PROPERTY(Fact *voltageSeventh READ voltageSeventh CONSTANT)
    Q_PROPERTY(Fact *voltageEighth  READ voltageEighth  CONSTANT)
    Q_PROPERTY(Fact *tempFirst      READ tempFirst      CONSTANT)
    Q_PROPERTY(Fact *tempSecond     READ tempSecond     CONSTANT)
    Q_PROPERTY(Fact *tempThird      READ tempThird      CONSTANT)
    Q_PROPERTY(Fact *tempFourth     READ tempFourth     CONSTANT)
    Q_PROPERTY(Fact *tempFifth      READ tempFifth      CONSTANT)
    Q_PROPERTY(Fact *tempSixth      READ tempSixth      CONSTANT)
    Q_PROPERTY(Fact *tempSeventh    READ tempSeventh    CONSTANT)
    Q_PROPERTY(Fact *tempEighth     READ tempEighth     CONSTANT)
    Q_PROPERTY(Fact *escCount       READ escCount       CONSTANT)

public:
    explicit VehicleEscStatusFactGroup(QObject *parent = nullptr);

    Fact *index() { return &_indexFact; }

    Fact *rpmFirst() { return _rpmFacts[0]; }
    Fact *rpmSecond() { return _rpmFacts[1]; }
    Fact *rpmThird() { return _rpmFacts[2]; }
    Fact *rpmFourth() { return _rpmFacts[3]; }
    Fact *rpmFifth() { return _rpmFacts[4]; }
    Fact *rpmSixth() { return _rpmFacts[5]; }
    Fact *rpmSeventh() { return _rpmFacts[6]; }
    Fact *rpmEighth() { return _rpmFacts[7]; }

    Fact *currentFirst() { return _currentFacts[0]; }
    Fact *currentSecond() { return _currentFacts[1]; }
    Fact *currentThird() { return _currentFacts[2]; }
    Fact *currentFourth() { return _currentFacts[3]; }
    Fact *currentFifth() { return _currentFacts[4]; }
    Fact *currentSixth() { return _currentFacts[5]; }
    Fact *currentSeventh() { return _currentFacts[6]; }
    Fact *currentEighth() { return _currentFacts[7]; }

    Fact *voltageFirst() { return _voltageFacts[0]; }
    Fact *voltageSecond() { return _voltageFacts[1]; }
    Fact *voltageThird() { return _voltageFacts[2]; }
    Fact *voltageFourth() { return _voltageFacts[3]; }
    Fact *voltageFifth() { return _voltageFacts[4]; }
    Fact *voltageSixth() { return _voltageFacts[5]; }
    Fact *voltageSeventh() { return _voltageFacts[6]; }
    Fact *voltageEighth() { return _voltageFacts[7]; }

    Fact *tempFirst() { return _tempFacts[0]; }
    Fact *tempSecond() { return _tempFacts[1]; }
    Fact *tempThird() { return _tempFacts[2]; }
    Fact *tempFourth() { return _tempFacts[3]; }
    Fact *tempFifth() { return _tempFacts[4]; }
    Fact *tempSixth() { return _tempFacts[5]; }
    Fact *tempSeventh() { return _tempFacts[6]; }
    Fact *tempEighth() { return _tempFacts[7]; }

    Fact *escCount() { return &_escCountFact; }

    // Overrides from FactGroup
    void handleMessage(Vehicle *vehicle, const mavlink_message_t &message) final;

private:
    static constexpr int _maxEscCount = 8;

    Fact _indexFact = Fact(0, QStringLiteral("index"), FactMetaData::valueTypeUint8);

    Fact _rpm1 = Fact(0, QStringLiteral("rpm1"), FactMetaData::valueTypeFloat);
    Fact _rpm2 = Fact(0, QStringLiteral("rpm2"), FactMetaData::valueTypeFloat);
    Fact _rpm3 = Fact(0, QStringLiteral("rpm3"), FactMetaData::valueTypeFloat);
    Fact _rpm4 = Fact(0, QStringLiteral("rpm4"), FactMetaData::valueTypeFloat);
    Fact _rpm5 = Fact(0, QStringLiteral("rpm5"), FactMetaData::valueTypeFloat);
    Fact _rpm6 = Fact(0, QStringLiteral("rpm6"), FactMetaData::valueTypeFloat);
    Fact _rpm7 = Fact(0, QStringLiteral("rpm7"), FactMetaData::valueTypeFloat);
    Fact _rpm8 = Fact(0, QStringLiteral("rpm8"), FactMetaData::valueTypeFloat);
    Fact* _rpmFacts[_maxEscCount];

    Fact _current1 = Fact(0, QStringLiteral("current1"), FactMetaData::valueTypeFloat);
    Fact _current2 = Fact(0, QStringLiteral("current2"), FactMetaData::valueTypeFloat);
    Fact _current3 = Fact(0, QStringLiteral("current3"), FactMetaData::valueTypeFloat);
    Fact _current4 = Fact(0, QStringLiteral("current4"), FactMetaData::valueTypeFloat);
    Fact _current5 = Fact(0, QStringLiteral("current5"), FactMetaData::valueTypeFloat);
    Fact _current6 = Fact(0, QStringLiteral("current6"), FactMetaData::valueTypeFloat);
    Fact _current7 = Fact(0, QStringLiteral("current7"), FactMetaData::valueTypeFloat);
    Fact _current8 = Fact(0, QStringLiteral("current8"), FactMetaData::valueTypeFloat);
    Fact* _currentFacts[_maxEscCount];

    Fact _voltage1 = Fact(0, QStringLiteral("voltage1"), FactMetaData::valueTypeFloat);
    Fact _voltage2 = Fact(0, QStringLiteral("voltage2"), FactMetaData::valueTypeFloat);
    Fact _voltage3 = Fact(0, QStringLiteral("voltage3"), FactMetaData::valueTypeFloat);
    Fact _voltage4 = Fact(0, QStringLiteral("voltage4"), FactMetaData::valueTypeFloat);
    Fact _voltage5 = Fact(0, QStringLiteral("voltage5"), FactMetaData::valueTypeFloat);
    Fact _voltage6 = Fact(0, QStringLiteral("voltage6"), FactMetaData::valueTypeFloat);
    Fact _voltage7 = Fact(0, QStringLiteral("voltage7"), FactMetaData::valueTypeFloat);
    Fact _voltage8 = Fact(0, QStringLiteral("voltage8"), FactMetaData::valueTypeFloat);
    Fact* _voltageFacts[_maxEscCount];

    Fact _temp1 = Fact(0, QStringLiteral("temp1"), FactMetaData::valueTypeFloat);
    Fact _temp2 = Fact(0, QStringLiteral("temp2"), FactMetaData::valueTypeFloat);
    Fact _temp3 = Fact(0, QStringLiteral("temp3"), FactMetaData::valueTypeFloat);
    Fact _temp4 = Fact(0, QStringLiteral("temp4"), FactMetaData::valueTypeFloat);
    Fact _temp5 = Fact(0, QStringLiteral("temp5"), FactMetaData::valueTypeFloat);
    Fact _temp6 = Fact(0, QStringLiteral("temp6"), FactMetaData::valueTypeFloat);
    Fact _temp7 = Fact(0, QStringLiteral("temp7"), FactMetaData::valueTypeFloat);
    Fact _temp8 = Fact(0, QStringLiteral("temp8"), FactMetaData::valueTypeFloat);
    Fact* _tempFacts[_maxEscCount];

    Fact _escCountFact = Fact(0, QStringLiteral("escCount"), FactMetaData::valueTypeUint8);
};
