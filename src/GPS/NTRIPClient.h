/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#pragma once

#include <QtCore/QByteArray>
#include <QtCore/QLoggingCategory>
#include <QtCore/QObject>
#include <QtCore/QTimer>
#include <QtNetwork/QTcpSocket>

Q_DECLARE_LOGGING_CATEGORY(NTRIPClientLog)

class NTRIPClient : public QObject
{
    Q_OBJECT

public:
    explicit NTRIPClient(QObject *parent = nullptr);
    ~NTRIPClient();

    void connectToCaster(const QString &url, bool ntripV1 = false);
    void disconnectFromCaster();
    bool isConnected() const;

    void setGCSPosition(double lat, double lng, double alt);
    void setSendGGA(bool send);

signals:
    void RTCMDataUpdate(QByteArray data);
    void connected();
    void disconnected();
    void errorOccurred(QString errorString);

private slots:
    void _onReadyRead();
    void _onConnected();
    void _onDisconnected();
    void _onSocketError(QAbstractSocket::SocketError error);
    void _onGGATimerTimeout();

private:
    void _doConnect();
    void _sendNMEAGGA();
    static QString _generateGGA(double lat, double lng, double alt);
    static quint8 _nmeaChecksum(const QString &sentence);

    QTcpSocket *_tcpSocket = nullptr;
    QTimer *_ggaTimer = nullptr;

    QString _host;
    int _port = 2101;
    QString _mountpoint;
    QString _username;
    QString _password;
    bool _ntripV1 = false;
    bool _sendGGA = true;
    bool _expectingHeader = true;
    QByteArray _headerBuffer;

    double _gcsLat = 0;
    double _gcsLng = 0;
    double _gcsAlt = 0;

    int _reconnectAttempts = 0;
    static constexpr int kMaxReconnectAttempts = 3;
    static constexpr int kDefaultNTRIPPort = 2101;
    static constexpr int kGGAIntervalMs = 30000;
    static constexpr int kReconnectDelayMs = 3000;
};
