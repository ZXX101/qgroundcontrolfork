package org.mavlink.qgroundcontrol;

import android.content.Context;
import android.util.Log;

import com.skydroid.rcsdk.KeyManager;
import com.skydroid.rcsdk.RCSDKManager;
import com.skydroid.rcsdk.SDKManagerCallBack;
import com.skydroid.rcsdk.common.callback.KeyListener;
import com.skydroid.rcsdk.common.error.SkyException;
import com.skydroid.rcsdk.key.AirLinkKey;

/**
 * 云卓遥控器SDK桥接。
 * 只监听链路信号质量(0-100%),不创建数传管道(Pipeline),
 * 避免SDK拉起自己的data_stream与系统rcservice的数传转发(UDP 14552-14554)冲突,
 * 从而不影响QGC自身的遥测链路。已在G12/G20上验证可共存。
 */
public class QGCRCSDKBridge {
    private static final String TAG = QGCRCSDKBridge.class.getSimpleName();

    private static boolean m_initialized = false;

    private static final KeyListener<Integer> m_signalQualityListener = new KeyListener<Integer>() {
        @Override
        public void onValueChange(Integer oldValue, Integer newValue) {
            if (newValue != null) {
                nativeSignalQualityChanged(newValue);
            }
        }
    };

    // 原始信号质量(JSON字符串,含两端SNR/发射功率/MCS等),G系列支持
    private static final KeyListener<String> m_rawSignalQualityListener = new KeyListener<String>() {
        @Override
        public void onValueChange(String oldValue, String newValue) {
            if (newValue != null) {
                nativeRawSignalQualityChanged(newValue);
            }
        }
    };

    private static native void nativeSignalQualityChanged(int quality);
    private static native void nativeRawSignalQualityChanged(String json);

    public static synchronized void initialize(final Context context) {
        if (m_initialized) {
            return;
        }
        m_initialized = true;
        try {
            RCSDKManager.INSTANCE.initSDK(context, new SDKManagerCallBack() {
                @Override
                public void onRcConnected() {
                    Log.i(TAG, "RC connected, start listening signal quality");
                    KeyManager.INSTANCE.cancelListen(m_signalQualityListener);
                    KeyManager.INSTANCE.listen(AirLinkKey.INSTANCE.getKeySignalQuality(), m_signalQualityListener);
                    KeyManager.INSTANCE.cancelListen(m_rawSignalQualityListener);
                    KeyManager.INSTANCE.listen(AirLinkKey.INSTANCE.getKeyRawSignalQuality(), m_rawSignalQualityListener);
                }

                @Override
                public void onRcConnectFail(SkyException e) {
                    Log.w(TAG, "RC connect fail: " + e);
                }

                @Override
                public void onRcDisconnect() {
                    Log.i(TAG, "RC disconnect");
                }
            });
            RCSDKManager.INSTANCE.connectToRC();
        } catch (Throwable t) {
            // 非云卓遥控器设备上SDK可能直接抛异常,不影响QGC其他功能
            Log.e(TAG, "RCSDK init failed", t);
        }
    }

    public static synchronized void cleanup() {
        if (!m_initialized) {
            return;
        }
        m_initialized = false;
        try {
            KeyManager.INSTANCE.cancelListen(m_signalQualityListener);
            KeyManager.INSTANCE.cancelListen(m_rawSignalQualityListener);
            // 不断开的话,程序还在运行时其他程序会出现端口占用
            RCSDKManager.INSTANCE.disconnectRC();
        } catch (Throwable t) {
            Log.e(TAG, "RCSDK cleanup failed", t);
        }
    }
}
