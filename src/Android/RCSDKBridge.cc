/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "RCSDKBridge.h"
#include "RCSignalQualityManager.h"
#include "QGCLoggingCategory.h"

#include <QtCore/QCoreApplication>
#include <QtCore/QJniEnvironment>

#include <jni.h>

QGC_LOGGING_CATEGORY(RCSDKBridgeLog, "qgc.android.rcsdkbridge");

namespace
{

/// Java侧信号质量回调(QGCRCSDKBridge.nativeSignalQualityChanged),运行在SDK回调线程
/// 注意:必须切到UI线程再访问RCSignalQualityManager,保证单例在UI线程创建、属性通知在UI线程发出
void jniSignalQualityChanged(JNIEnv *env, jobject thiz, jint quality)
{
    Q_UNUSED(env);
    Q_UNUSED(thiz);

    QMetaObject::invokeMethod(QCoreApplication::instance(), [quality]() {
        RCSignalQualityManager::instance()->setSignalQuality(static_cast<int>(quality));
    }, Qt::QueuedConnection);
}

/// Java侧原始信号质量回调(QGCRCSDKBridge.nativeRawSignalQualityChanged),JSON字符串,运行在SDK回调线程
void jniRawSignalQualityChanged(JNIEnv *env, jobject thiz, jstring json)
{
    Q_UNUSED(thiz);

    const char * const chars = env->GetStringUTFChars(json, nullptr);
    const QString jsonStr = QString::fromUtf8(chars);
    env->ReleaseStringUTFChars(json, chars);
    (void) QJniEnvironment::checkAndClearExceptions(env);

    QMetaObject::invokeMethod(QCoreApplication::instance(), [jsonStr]() {
        RCSignalQualityManager::instance()->setRawSignalQuality(jsonStr);
    }, Qt::QueuedConnection);
}

} // namespace

void RCSDKBridge::setNativeMethods()
{
    qCDebug(RCSDKBridgeLog) << "Registering RCSDK Native Functions";

    const JNINativeMethod javaMethods[] {
        {"nativeSignalQualityChanged", "(I)V", reinterpret_cast<void *>(jniSignalQualityChanged)},
        {"nativeRawSignalQualityChanged", "(Ljava/lang/String;)V", reinterpret_cast<void *>(jniRawSignalQualityChanged)}
    };

    QJniEnvironment jniEnv;
    (void) jniEnv.checkAndClearExceptions();

    const jclass objectClass = jniEnv->FindClass(kJniRCSDKBridgeClassName);
    if (!objectClass) {
        qCWarning(RCSDKBridgeLog) << "Couldn't find class:" << kJniRCSDKBridgeClassName;
        (void) jniEnv.checkAndClearExceptions();
        return;
    }

    const jint val = jniEnv->RegisterNatives(objectClass, javaMethods, std::size(javaMethods));
    if (val < 0) {
        qCWarning(RCSDKBridgeLog) << "Error registering methods:" << val;
    } else {
        qCDebug(RCSDKBridgeLog) << "RCSDK Native Functions Registered";
    }

    (void) jniEnv.checkAndClearExceptions();
}
