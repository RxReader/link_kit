# link_kit

Flutter plugin for App/Deep Link.

## Android

* 配置

```xml
<activity
    android:name=".MainActivity">
    <intent-filter android:autoVerify="false">
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <!-- 固定标志 -->
        <category android:name="${applicationId}.link_kit.category.FLK"/>
        <!-- scheme 为必选项，host 为可选项，scheme/host 可自定义 -->
        <data android:scheme="flk" android:host="link.kit"/>
    </intent-filter>
</activity>
```

* 测试

```shell
adb shell am start -a android.intent.action.VIEW \
    -c android.intent.category.BROWSABLE \
    -d "flk://link.kit/power"
```

## iOS

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

