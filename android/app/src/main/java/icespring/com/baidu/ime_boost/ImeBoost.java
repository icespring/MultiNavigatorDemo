package icespring.com.baidu.ime_boost;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;

import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleObserver;
import androidx.lifecycle.OnLifecycleEvent;

import java.util.List;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.platform.PlatformPlugin;

/**
 * 输入法Engine的管理类
 */
public class ImeBoost implements LifecycleObserver {

    private static final String TAG = "ImeFlutter";


    private static ImeBoost sInstance = null;

    private String initialRoute;

    private Lifecycle lifecycle;

    private Activity attachedActivity;

    // 当前使用的Flutter engine
    private static FlutterEngine flutterEngine;

    private FlutterView flutterView;

    // 用于注册平台相关的plugin，这样可以接管系统的一些事件，比如back键
    private PlatformPlugin platformPlugin;

    private BoostMethodCallHandler boostMethodCallHandler;

    List<ImeCustomMethodCallHandler> methodHandlers;

    public void init(Context context,
             List<ImeCustomMethodCallHandler> handlers) {
        this.methodHandlers = handlers;
        setupEngine(context);
        registerHandlers(context, handlers);
        initialRoute = "/";
    }

    public static ImeBoost instance() {
        if (sInstance == null) {
            sInstance = new ImeBoost();
        }
        return sInstance;
    }

    // 绑定某个Activity，需要在启动这个Activity oncreate的时候进行绑定
    public void bindActivity(Activity activity, Lifecycle lifecycle) {
        this.attachedActivity = activity;
        this.lifecycle = lifecycle;
        lifecycle.addObserver(this);
    }


    /**
     * 注册Method Channel相关
     * @param context
     * @param handlers
     */
    private void registerHandlers(Context context, List<ImeCustomMethodCallHandler> handlers) {
        if (handlers != null && handlers.size() > 0) {
            for (ImeCustomMethodCallHandler handler : handlers) {
                if (handler instanceof BoostMethodCallHandler) {
                    boostMethodCallHandler = ((BoostMethodCallHandler) handler);
                }
                handler.registerMethodChannel(context, flutterEngine.getDartExecutor());
            }

        }
    }

    /**
     * 设置Flutter引擎
     * @param context
     */
    private void setupEngine(Context context) {
        if (flutterEngine == null) {
            flutterEngine = new FlutterEngine(context.getApplicationContext());
        }
    }

    public BoostMethodCallHandler getBoostChannel() {
        return boostMethodCallHandler;
    }

    public FlutterEngine getFlutterEngine() {
        return flutterEngine;
    }

    public PlatformPlugin getPlatFormChannel() {
        return platformPlugin;
    }


    private void attachToEngine() {
        // 这里使用post是参考FlutterActivity的做法
        // attach有一些耗时操作，这样可以先让Activity启动，再执行attach操作
        new Handler().post(() -> {
            if (flutterEngine.getDartExecutor().isExecutingDart()) {
                return;
            }
            flutterEngine.getNavigationChannel().setInitialRoute(initialRoute);
            flutterEngine.getDartExecutor()
                    .executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault());
        });
    }

    private void destroyEngine() {
        if (platformPlugin != null) {
            platformPlugin.destroy();
        }
        if (methodHandlers != null && methodHandlers.size() > 0) {
            for (ImeCustomMethodCallHandler methodHandler : methodHandlers) {
                methodHandler.destroy();
            }
        }

        flutterEngine.getActivityControlSurface().detachFromActivity();
        flutterEngine.getLifecycleChannel().appIsDetached();
        flutterEngine.destroy();
        flutterEngine = null;
    }

    private void cleanUp() {
        attachedActivity = null;
        flutterView = null;
        platformPlugin = null;
        methodHandlers = null;
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_CREATE)
    public void onCreate() {
        Log.d(TAG, "flutter onCreate");
        // note: 这里由于flutter embendding 没有
        flutterEngine.getActivityControlSurface().attachToActivity(attachedActivity, lifecycle);
    }


    @OnLifecycleEvent(Lifecycle.Event.ON_START)
    public void onStart() {
        Log.d(TAG, "flutter onStart");

        attachToEngine();
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_PAUSE)
    public void onPause() {
        Log.d(TAG, "flutter onPause");
        flutterEngine.getLifecycleChannel().appIsInactive();
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
    public void onResume() {
        Log.d(TAG, "flutter onResume");

        flutterEngine.getLifecycleChannel().appIsResumed();
        if (platformPlugin != null) {
            platformPlugin.updateSystemUiOverlays();
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_STOP)
    public void onStop() {
        Log.d(TAG, "flutter onStop");

        flutterEngine.getLifecycleChannel().appIsPaused();
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    public void onDestroy() {
        Log.d(TAG, "flutter onDestroy");
//        destroyEngine();
//        cleanUp();
    }


}
