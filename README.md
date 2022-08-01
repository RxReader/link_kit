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
        <!-- scheme 为必选项，可自定义 -->
        <data android:scheme="flk"/>
        <!-- 可定义多个 -->
        <data android:scheme="flks"/>
    </intent-filter>
</activity>
```

* 测试

```shell
adb shell am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "flk://link.kit/power"
```
```shell
adb shell am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "flks://link.kit/power"
```

## iOS

* 配置

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <!-- 固定标志 -->
        <string>flk</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- scheme 为必选项，可自定义 -->
            <string>flk</string>
            <!-- 可定义多个 -->
            <string>flks</string>
        </array>
    </dict>
</array>
```

* 测试

```shell
xcrun simctl openurl booted flk://link.kit/power
```
```shell
xcrun simctl openurl booted flks://link.kit/power
```

## Flutter

```dart
    _linkClickSubs = Link.instance.linkClickStream().listen((String event) {
      if (kDebugMode) {
        print('linkClick: $event');
      }
    });
    Link.instance.getInitialLink().then((String? value) {
      if (kDebugMode) {
        print('initialLink: $value');
      }
    });
```
