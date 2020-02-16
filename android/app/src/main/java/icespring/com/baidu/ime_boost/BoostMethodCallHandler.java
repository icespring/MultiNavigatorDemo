package icespring.com.baidu.ime_boost;

import android.content.Context;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * DIY页面使用到的MethodChannel
 */
public class BoostMethodCallHandler implements MethodChannel.MethodCallHandler, ImeCustomMethodCallHandler {


    private Context context;
    private MethodChannel channel;

    @Override
    public void registerMethodChannel(Context context, BinaryMessenger messenger) {
        this.context = context;
        channel = new MethodChannel(messenger, "ime_boost");
        channel.setMethodCallHandler(this);
    }


    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        if (methodCall == null || methodCall.method == null) {
            return;
        }

        switch (methodCall.method) {
            case "openPage":
                break;
            default:
                result.notImplemented();
                break;

        }
    }

    public void invokeMethod(String method, Map arguments) {
        if (channel != null) {
            channel.invokeMethod(method, arguments);
        }
    }

    @Override
    public void destroy() {
        channel = null;
    }


}
