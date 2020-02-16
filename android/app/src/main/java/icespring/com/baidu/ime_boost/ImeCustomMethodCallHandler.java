package icespring.com.baidu.ime_boost;

import android.content.Context;

import io.flutter.plugin.common.BinaryMessenger;


public interface ImeCustomMethodCallHandler {

    /**
     * 自定义注册Method Call
     * @param context 所绑定的Activity的实例
     * @param messenger FlutterEngine
     */
    void registerMethodChannel(Context context, BinaryMessenger messenger);

    void destroy();
}
