/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "NTRIPClient.h"
#include "QGCLoggingCategory.h"

#include <QtCore/QDateTime>
#include <QtCore/QUrl>
#include <QtCore/QUrlQuery>

QGC_LOGGING_CATEGORY(NTRIPClientLog, "qgc.gps.ntripclient")

NTRIPClient::NTRIPClient(QObject *parent)
    : QObject(parent)
    , _ggaTimer(new QTimer(this))
    , _connectTimer(new QTimer(this))
{
    _ggaTimer->setInterval(kGGAIntervalMs);
    (void) connect(_ggaTimer, &QTimer::timeout, this, &NTRIPClient::_onGGATimerTimeout);

    // Covers both the TCP connect and the NTRIP handshake (server accepted TCP but never answers the GET)
    _connectTimer->setSingleShot(true);
    _connectTimer->setInterval(kConnectTimeoutMs);
    (void) connect(_connectTimer, &QTimer::timeout, this, &NTRIPClient::_onConnectTimeout);
}

NTRIPClient::~NTRIPClient()
{
    disconnectFromCaster();
}

void NTRIPClient::connectToCaster(const QString &url, bool ntripV1)
{
    disconnectFromCaster();
    _userRequestedDisconnect = false;

    QString normalizedUrl = url;
    if (normalizedUrl.startsWith(QStringLiteral("ntrip://"), Qt::CaseInsensitive)) {
        normalizedUrl.replace(0, 8, QStringLiteral("http://"));
    }

    const QUrl parsedUrl(normalizedUrl);
    if (!parsedUrl.isValid()) {
        emit errorOccurred(tr("Invalid NTRIP URL"));
        return;
    }

    _host = parsedUrl.host();
    _port = parsedUrl.port(kDefaultNTRIPPort);
    _mountpoint = parsedUrl.path();
    _username = parsedUrl.userName();
    _password = parsedUrl.password();
    _ntripV1 = ntripV1;
    _reconnectAttempts = 0;

    if (_mountpoint.isEmpty()) {
        emit errorOccurred(tr("No mountpoint specified in NTRIP URL"));
        return;
    }

    _doConnect();
}

void NTRIPClient::disconnectFromCaster()
{
    _userRequestedDisconnect = true;
    _ggaTimer->stop();
    _connectTimer->stop();
    _reconnectAttempts = kMaxReconnectAttempts;

    if (_tcpSocket) {
        // Ignore further signals from this socket so _handleFailure() is not re-entered
        (void) _tcpSocket->disconnect(this);
        _tcpSocket->disconnectFromHost();
        if (_tcpSocket->state() != QAbstractSocket::UnconnectedState) {
            (void) _tcpSocket->waitForDisconnected(1000);
        }
        _tcpSocket->deleteLater();
        _tcpSocket = nullptr;
    }

    _expectingHeader = true;
    _headerBuffer.clear();
}

bool NTRIPClient::isConnected() const
{
    return _tcpSocket && _tcpSocket->state() == QAbstractSocket::ConnectedState && !_expectingHeader;
}

void NTRIPClient::setGCSPosition(double lat, double lng, double alt)
{
    _gcsLat = lat;
    _gcsLng = lng;
    _gcsAlt = alt;
}

void NTRIPClient::setSendGGA(bool send)
{
    _sendGGA = send;
}

void NTRIPClient::_doConnect()
{
    if (_tcpSocket) {
        _tcpSocket->deleteLater();
        _tcpSocket = nullptr;
    }

    _expectingHeader = true;
    _headerBuffer.clear();

    _tcpSocket = new QTcpSocket(this);
    (void) connect(_tcpSocket, &QTcpSocket::readyRead, this, &NTRIPClient::_onReadyRead);
    (void) connect(_tcpSocket, &QTcpSocket::connected, this, &NTRIPClient::_onConnected);
    (void) connect(_tcpSocket, &QTcpSocket::disconnected, this, &NTRIPClient::_onDisconnected);
    (void) connect(_tcpSocket, &QAbstractSocket::errorOccurred, this, &NTRIPClient::_onSocketError);

    qCDebug(NTRIPClientLog) << "Connecting to" << _host << "port" << _port;
    _connectTimer->start();
    _tcpSocket->connectToHost(_host, _port);
}

void NTRIPClient::_onConnected()
{
    qCDebug(NTRIPClientLog) << "TCP connected, sending HTTP GET request";

    QString request;
    if (_ntripV1) {
        request = QStringLiteral("GET %1 HTTP/1.0\r\n").arg(_mountpoint);
        request += QStringLiteral("User-Agent: NTRIP QGC/1.0\r\n");
    } else {
        request = QStringLiteral("GET %1 HTTP/1.1\r\n").arg(_mountpoint);
        request += QStringLiteral("Host: %1:%2\r\n").arg(_host).arg(_port);
        request += QStringLiteral("Ntrip-Version: Ntrip/2.0\r\n");
        request += QStringLiteral("User-Agent: NTRIP QGC/1.0\r\n");
    }

    if (!_username.isEmpty()) {
        const QByteArray credentials = QStringLiteral("%1:%2").arg(_username, _password).toUtf8().toBase64();
        request += QStringLiteral("Authorization: Basic %1\r\n").arg(QString::fromUtf8(credentials));
    }

    request += QStringLiteral("Connection: close\r\n");
    request += QStringLiteral("\r\n");

    (void) _tcpSocket->write(request.toUtf8());
}

void NTRIPClient::_onReadyRead()
{
    if (!_tcpSocket) {
        return;
    }

    const QByteArray data = _tcpSocket->readAll();

    if (_expectingHeader) {
        _headerBuffer.append(data);

        if (_headerBuffer.size() > kMaxHeaderSize) {
            qCWarning(NTRIPClientLog) << "NTRIP header exceeds maximum size, aborting";
            emit errorOccurred(tr("Invalid response from NTRIP server"));
            disconnectFromCaster();
            return;
        }

        int headerEnd = _headerBuffer.indexOf("\r\n\r\n");
        int headerTerminatorLength = 4;
        if ((headerEnd == -1) && _ntripV1 && _headerBuffer.startsWith("ICY")) {
            // NTRIP v1 servers may reply with a single "ICY 200 OK\r\n" line without a trailing blank line
            headerEnd = _headerBuffer.indexOf("\r\n");
            headerTerminatorLength = 2;
        }
        if (headerEnd == -1) {
            return;
        }

        const QString header = QString::fromUtf8(_headerBuffer.left(headerEnd));
        qCDebug(NTRIPClientLog) << "Received header:" << header;

        if (header.contains(QStringLiteral("SOURCETABLE"))) {
            emit errorOccurred(tr("Mountpoint not found (SOURCETABLE received)"));
            disconnectFromCaster();
            return;
        }

        if (!header.contains(QStringLiteral("200"))) {
            const int statusStart = header.indexOf(' ');
            const int statusEnd = header.indexOf('\r');
            QString status = (statusStart > 0 && statusEnd > statusStart)
                ? header.mid(statusStart + 1, statusEnd - statusStart - 1)
                : tr("Unknown error");
            emit errorOccurred(tr("NTRIP server error: %1").arg(status));
            disconnectFromCaster();
            return;
        }

        _expectingHeader = false;
        _reconnectAttempts = 0;
        _connectTimer->stop();

        qCDebug(NTRIPClientLog) << "NTRIP connection established";

        const QByteArray bodyData = _headerBuffer.mid(headerEnd + headerTerminatorLength);
        if (!bodyData.isEmpty()) {
            emit RTCMDataUpdate(bodyData);
        }

        if (_sendGGA) {
            _sendNMEAGGA();
            _ggaTimer->start();
        }

        emit connected();
    } else {
        if (!data.isEmpty()) {
            emit RTCMDataUpdate(data);
        }
    }
}

void NTRIPClient::_onDisconnected()
{
    qCDebug(NTRIPClientLog) << "Disconnected from NTRIP caster";
    _handleFailure(tr("Connection lost"));
}

void NTRIPClient::_onSocketError(QAbstractSocket::SocketError error)
{
    Q_UNUSED(error);

    const QString errorString = _tcpSocket ? _tcpSocket->errorString() : tr("Unknown socket error");
    qCWarning(NTRIPClientLog) << "Socket error:" << errorString;
    _handleFailure(tr("NTRIP connection error: %1").arg(errorString));
}

void NTRIPClient::_onConnectTimeout()
{
    qCWarning(NTRIPClientLog) << "Connection/handshake timed out";
    _handleFailure(tr("NTRIP server did not respond (timeout)"));
}

void NTRIPClient::_handleFailure(const QString &reason)
{
    // A user-requested disconnect or an already-handled failure must not trigger reconnects or errors
    if (_userRequestedDisconnect || !_tcpSocket) {
        return;
    }

    const bool wasConnected = !_expectingHeader;

    // Detach the socket so any further error/disconnected signals from it are ignored
    (void) _tcpSocket->disconnect(this);
    _tcpSocket->deleteLater();
    _tcpSocket = nullptr;

    _ggaTimer->stop();
    _connectTimer->stop();
    _expectingHeader = true;
    _headerBuffer.clear();

    if (wasConnected) {
        emit disconnected();
    }

    if (_reconnectAttempts < kMaxReconnectAttempts) {
        _reconnectAttempts++;
        qCDebug(NTRIPClientLog) << "Attempting reconnect" << _reconnectAttempts << "of" << kMaxReconnectAttempts;
        (void) QTimer::singleShot(kReconnectDelayMs, this, [this]() {
            if (!_userRequestedDisconnect) {
                _doConnect();
            }
        });
    } else {
        emit errorOccurred(reason);
    }
}

void NTRIPClient::_onGGATimerTimeout()
{
    _sendNMEAGGA();
}

void NTRIPClient::_sendNMEAGGA()
{
    if (!_tcpSocket || !_tcpSocket->isOpen() || _expectingHeader) {
        return;
    }

    if (!_sendGGA || (_gcsLat == 0 && _gcsLng == 0)) {
        qCDebug(NTRIPClientLog) << "Skipping GGA: invalid position";
        return;
    }

    const QString gga = _generateGGA(_gcsLat, _gcsLng, _gcsAlt);
    qCDebug(NTRIPClientLog) << "Sending GGA:" << gga;
    (void) _tcpSocket->write(gga.toUtf8() + "\r\n");
}

QString NTRIPClient::_generateGGA(double lat, double lng, double alt)
{
    const QDateTime now = QDateTime::currentDateTimeUtc();
    const QTime time = now.time();
    const QString timeStr = time.toString(QStringLiteral("HHmmss.zz"));

    const double absLat = qAbs(lat);
    const int latDeg = static_cast<int>(absLat);
    const double latMin = (absLat - latDeg) * 60.0;
    const QString latDir = (lat >= 0) ? QStringLiteral("N") : QStringLiteral("S");

    const double absLng = qAbs(lng);
    const int lngDeg = static_cast<int>(absLng);
    const double lngMin = (absLng - lngDeg) * 60.0;
    const QString lngDir = (lng >= 0) ? QStringLiteral("E") : QStringLiteral("W");

    const QString latStr = QStringLiteral("%1%2").arg(latDeg, 2, 10, QChar('0')).arg(latMin, 7, 'f', 4, QChar('0'));
    const QString lngStr = QStringLiteral("%1%2").arg(lngDeg, 3, 10, QChar('0')).arg(lngMin, 7, 'f', 4, QChar('0'));

    const QString sentence = QStringLiteral("GPGGA,%1,%2,%3,%4,%5,1,10,1,%6,M,0.0,M,0.0,M")
        .arg(timeStr, latStr, latDir, lngStr, lngDir)
        .arg(alt, 0, 'f', 2);

    const quint8 checksum = _nmeaChecksum(sentence);
    return QStringLiteral("$%1*%2").arg(sentence).arg(checksum, 2, 16, QChar('0')).toUpper();
}

quint8 NTRIPClient::_nmeaChecksum(const QString &sentence)
{
    quint8 cs = 0;
    const qsizetype len = sentence.size();
    for (qsizetype i = 0; i < len; ++i) {
        cs ^= static_cast<quint8>(sentence[i].toLatin1());
    }
    return cs;
}
