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

Q_DECLARE_LOGGING_CATEGORY(RCSDKBridgeLog)

namespace RCSDKBridge
{
    /// 注册Java侧QGCRCSDKBridge的native回调(在JNI_OnLoad中调用)
    void setNativeMethods();

    constexpr const char *kJniRCSDKBridgeClassName = "org/mavlink/qgroundcontrol/QGCRCSDKBridge";
};
