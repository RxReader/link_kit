package io.github.v7lin.link_kit;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;

import androidx.annotation.NonNull;

import java.util.List;

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
            this.events = events;
        }

        @Override
        public void onCancel(Object arguments) {
            this.events = null;
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
        if (linkClickEventHandler != null) {
            if (isFLKIntent(intent)) {
                final String link = intent.getDataString();
                linkClickEventHandler.addEvent(link);
            }
        }
        return false;
    }

    // --- MethodCallHandler

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if ("getInitialLink".equals(call.method)) {
            String initialLink = null;
            final Activity activity = activityPluginBinding.getActivity();
            if (activity != null) {
                final Intent intent = activity.getIntent();
                if (isFLKIntent(intent)) {
                    initialLink = intent.getDataString();
                }
            }
            result.success(initialLink);
        } else {
            result.notImplemented();
        }
    }

    private boolean isFLKIntent(Intent intent) {
        final Intent copy = new Intent(intent);
        copy.setComponent(null);// 必须设置为空，不然无法获取 ResolveInfo 的 IntentFilter
        final List<ResolveInfo> infos = applicationContext.getPackageManager().queryIntentActivities(copy, PackageManager.GET_RESOLVED_FILTER);
        if (infos.size() == 1) {
            final ResolveInfo info = infos.get(0);
            final IntentFilter filter = info.filter;
            return filter != null && filter.hasCategory(applicationContext.getPackageName() + ".link_kit.category.FLK");
        }
        return false;
    }
}
