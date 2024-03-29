package io.github.v7lin.link_kit;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import java.util.Arrays;
import java.util.concurrent.atomic.AtomicBoolean;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

/**
 * LinkKitPlugin
 */
public class LinkKitPlugin implements FlutterPlugin, ActivityAware, PluginRegistry.NewIntentListener, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private EventChannel linkClickEventChannel;
    private LinkClickEventHandler linkClickEventHandler;
    private Context applicationContext;
    private ActivityPluginBinding activityPluginBinding;
    private final AtomicBoolean handleInitialFlag = new AtomicBoolean(false);

    // --- FlutterPlugin

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "v7lin.github.io/link_kit");
        channel.setMethodCallHandler(this);
        linkClickEventChannel = new EventChannel(binding.getBinaryMessenger(), "v7lin.github.io/link_kit#click_event");
        linkClickEventHandler = new LinkClickEventHandler();
        linkClickEventChannel.setStreamHandler(linkClickEventHandler);
        applicationContext = binding.getApplicationContext();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        channel = null;
        linkClickEventChannel.setStreamHandler(null);
        linkClickEventChannel = null;
        linkClickEventHandler = null;
        applicationContext = null;
    }

    private static class LinkClickEventHandler implements EventChannel.StreamHandler {
        private EventChannel.EventSink events;

        @Override
        public void onListen(Object arguments, EventChannel.EventSink events) {
            if (this.events != null) {
                return;
            }
            this.events = events;
        }

        @Override
        public void onCancel(Object arguments) {
            if (this.events == null) {
                return;
            }
            this.events = null;
        }

        public boolean isActive() {
            return this.events != null;
        }

        public void addEvent(String event) {
            if (events != null) {
                events.success(event);
            }
        }
    }

    // --- ActivityAware

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activityPluginBinding = binding;
        activityPluginBinding.addOnNewIntentListener(this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        activityPluginBinding.removeOnNewIntentListener(this);
        activityPluginBinding = null;
    }

    // --- NewIntentListener

    @Override
    public boolean onNewIntent(@NonNull Intent intent) {
        final Intent extra = LinkCallbackActivity.extraCallback(intent);
        if (extra != null) {
            if (isFLKIntent(extra)) {
                final String link = extra.getDataString();
                if (linkClickEventHandler != null) {
                    linkClickEventHandler.addEvent(link);
                }
            }
            return true;
        }
        return false;
    }

    // --- MethodCallHandler

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if ("getInitialLink".equals(call.method)) {
            if (handleInitialFlag.compareAndSet(false, true)) {
                String initialLink = null;
                final Activity activity = activityPluginBinding != null ? activityPluginBinding.getActivity() : null;
                if (activity != null) {
                    final Intent extra = LinkCallbackActivity.extraCallback(activity.getIntent());
                    if (extra != null) {
                        if (isFLKIntent(extra)){
                            initialLink = extra.getDataString();
                        }
                    }
                }
                result.success(initialLink);
            } else {
                result.error("FAILED", null, null);
            }
        } else {
            result.notImplemented();
        }
    }

    private boolean isFLKIntent(@NonNull Intent intent) {
        final Uri data = intent.getData();
        if (data != null) {
            if (Arrays.asList(BuildConfig.LINK_KIT_DEEP_LINK_SCHEME).contains(data.getScheme())) {
                // deep link
                return true;
            } else if (!TextUtils.isEmpty(BuildConfig.LINK_KIT_APP_LINK) && data.toString().startsWith(BuildConfig.LINK_KIT_APP_LINK)) {
                // app link
                return true;
            }
        }
        return false;
    }
}
