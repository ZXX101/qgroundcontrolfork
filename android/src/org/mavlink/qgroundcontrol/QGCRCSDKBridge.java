package org.mavlink.qgroundcontrol;

import android.content.Context;
import android.util.Log;

import com.skydroid.rcsdk.KeyManager;
import com.skydroid.rcsdk.PayloadManager;
import com.skydroid.rcsdk.RCSDKManager;
import com.skydroid.rcsdk.SDKManagerCallBack;
import com.skydroid.rcsdk.common.GimbalMoveMode;
import com.skydroid.rcsdk.common.button.ButtonAction;
import com.skydroid.rcsdk.common.button.ButtonConfig;
import com.skydroid.rcsdk.common.button.ButtonHelper;
import com.skydroid.rcsdk.common.button.HandleButtonMode;
import com.skydroid.rcsdk.common.callback.CompletionCallbackWith;
import com.skydroid.rcsdk.common.callback.KeyListener;
import com.skydroid.rcsdk.common.error.SkyException;
import com.skydroid.rcsdk.common.payload.CommonPayload;
import com.skydroid.rcsdk.common.payload.PayloadType;
import com.skydroid.rcsdk.key.AirLinkKey;
import com.skydroid.rcsdk.key.RemoteControllerKey;

import java.util.ArrayList;
import java.util.List;

/**
 * 云卓遥控器SDK桥接。
 * 只监听链路信号质量(0-100%)及原始数据,并轮询摇杆通道值用于云台控制。
 * 不创建数传管道(Pipeline),避免SDK拉起自己的data_stream与系统rcservice的
 * 数传转发(UDP 14552-14554)冲突,从而不影响QGC自身的遥测链路。已在G12/G20上验证可共存。
 *
 * 云台控制:12通道(数组下标11)滚轮控制C01Pro俯仰。
 * 链路为:轮询KeyChannels -> ButtonHelper -> CommonPayload.controlPitch(UDP 192.168.144.108:5000),
 * 与QGC遥测链路完全隔离。
 */
public class QGCRCSDKBridge {
    private static final String TAG = QGCRCSDKBridge.class.getSimpleName();

    // 云台俯仰控制通道:12通道,数组下标11
    private static final int GIMBAL_PITCH_CHANNEL_INDEX = 11;
    // 摇杆通道值轮询间隔,厂家建议至少100ms
    private static final long CHANNEL_POLL_INTERVAL_MS = 100;
    // C01Pro网口相机云台控制端点
    private static final String GIMBAL_HOST = "192.168.144.108";
    private static final int GIMBAL_PORT = 5000;

    private static boolean m_initialized = false;

    private static CommonPayload m_commonPayload = null;
    private static ButtonHelper m_buttonHelper = null;
    private static ChannelPollThread m_channelPollThread = null;

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

    // 摇杆通道值轮询回调,喂给ButtonHelper驱动云台
    private static final CompletionCallbackWith<int[]> m_channelsCallback = new CompletionCallbackWith<int[]>() {
        @Override
        public void onSuccess(int[] ints) {
            ButtonHelper helper = m_buttonHelper;
            if (ints != null && helper != null) {
                helper.receiveButtonData(ints);
            }
        }

        @Override
        public void onFailure(SkyException e) {
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
                    startChannelPolling();
                }

                @Override
                public void onRcConnectFail(SkyException e) {
                    Log.w(TAG, "RC connect fail: " + e);
                }

                @Override
                public void onRcDisconnect() {
                    Log.i(TAG, "RC disconnect");
                    stopChannelPolling();
                }
            });
            RCSDKManager.INSTANCE.connectToRC();
            setupGimbalControl();
        } catch (Throwable t) {
            // 非云卓遥控器设备上SDK可能直接抛异常,不影响QGC其他功能
            Log.e(TAG, "RCSDK init failed", t);
        }
    }

    // 配置云台控制:C01Pro用通用payload(UDP直连,与数传链路无关),
    // ButtonHelper内部完成通道值->云台速度模式控制的转换
    private static void setupGimbalControl() {
        try {
            m_commonPayload = (CommonPayload) PayloadManager.INSTANCE.getUDPPayload(
                    PayloadType.COMMON, GIMBAL_PORT, GIMBAL_HOST, GIMBAL_PORT);
            // 内部已实现断线重连,只需连接一次
            PayloadManager.INSTANCE.connectPayload(m_commonPayload);

            // 云台速度控制:默认为匀速模式(UNIFORM_SPEED,固定10°/s,与拨动幅度无关),
            // 改为变速模式(ACCELERATE_SPEED),速度随拨轮幅度在min~max之间线性变化
            // controlPitch支持-63.5~+63.5°/s,直接拉满
            m_commonPayload.setRCButtonControlSpeedMode(GimbalMoveMode.ACCELERATE_SPEED);
            m_commonPayload.setRCButtonControlMinSpeed(5f);
            m_commonPayload.setRCButtonControlMaxSpeed(63.5f);

            List<ButtonConfig> configs = new ArrayList<>();
            // ALWAYS:持续调用,适用于滚轮/摇杆控制云台
            configs.add(new ButtonConfig(GIMBAL_PITCH_CHANNEL_INDEX, ButtonAction.GIMBAL_PITCH, HandleButtonMode.ALWAYS));

            m_buttonHelper = new ButtonHelper();
            m_buttonHelper.setConfig(configs, m_commonPayload);
            m_buttonHelper.start();
            Log.i(TAG, "Gimbal control ready, channel " + (GIMBAL_PITCH_CHANNEL_INDEX + 1) + " -> pitch");
        } catch (Throwable t) {
            Log.e(TAG, "Gimbal control setup failed", t);
        }
    }

    private static synchronized void startChannelPolling() {
        if (m_channelPollThread != null) {
            return;
        }
        m_channelPollThread = new ChannelPollThread();
        m_channelPollThread.start();
    }

    private static synchronized void stopChannelPolling() {
        ChannelPollThread thread = m_channelPollThread;
        m_channelPollThread = null;
        if (thread != null) {
            thread.shutdown();
        }
    }

    public static synchronized void cleanup() {
        if (!m_initialized) {
            return;
        }
        m_initialized = false;
        try {
            stopChannelPolling();
            if (m_buttonHelper != null) {
                m_buttonHelper.stop();
                m_buttonHelper = null;
            }
            if (m_commonPayload != null) {
                PayloadManager.INSTANCE.disconnectPayload(m_commonPayload);
                m_commonPayload = null;
            }
            KeyManager.INSTANCE.cancelListen(m_signalQualityListener);
            KeyManager.INSTANCE.cancelListen(m_rawSignalQualityListener);
            // 不断开的话,程序还在运行时其他程序会出现端口占用
            RCSDKManager.INSTANCE.disconnectRC();
        } catch (Throwable t) {
            Log.e(TAG, "RCSDK cleanup failed", t);
        }
    }

    // 摇杆通道值轮询线程(G12/G20为GET方式,请求一次获取一次;H16才是LISTEN方式,本项目不涉及)
    private static class ChannelPollThread extends Thread {
        private volatile boolean m_running = true;

        @Override
        public void run() {
            while (m_running) {
                try {
                    KeyManager.INSTANCE.get(RemoteControllerKey.INSTANCE.getKeyChannels(), m_channelsCallback);
                    Thread.sleep(CHANNEL_POLL_INTERVAL_MS);
                } catch (InterruptedException e) {
                    break;
                } catch (Throwable t) {
                    Log.w(TAG, "Channel poll error", t);
                }
            }
        }

        void shutdown() {
            m_running = false;
            interrupt();
        }
    }
}
