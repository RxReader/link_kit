# link_kit

Flutter plugin for Deep Link/App Link/Universal Links.

## Android

#### 文档

* [创建指向应用内容的深层链接](https://developer.android.com/training/app-links/deep-linking)
* [添加 Android 应用链接](https://developer.android.com/studio/write/app-link-indexing.html)
* [simonmarquis/Android App Linking](https://simonmarquis.github.io/Android-App-Linking/)
* [Statement List Generator and Tester](https://developers.google.com/digital-asset-links/tools/generator)

#### 配置

```xml
<activity
    android:name=".MainActivity">
    <!-- Deep Link -->
    <intent-filter>
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
    <!-- App Link，可不配置 -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <!-- 固定标志 -->
        <category android:name="${applicationId}.link_kit.category.FLK"/>
        <!-- scheme/host 为必选项；host 与 applinks 的 domain 保持一致；path/pathPattern/pathPrefix 为可选项，可设置以保持与 iOS 的 Universal Links 一致 -->
        <data android:scheme="https" android:host="help.link.kit"/>
    </intent-filter>
</activity>
```

#### 测试

```shell
# Deep Link
adb shell am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "flk://link.kit/power"
```

```shell
# Deep Link
adb shell am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "flks://link.kit/power"
```

```shell
# App Link
adb shell am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "https://help.link.kit/power"
```

## iOS

#### 文档

[Support Universal Links](https://developer.apple.com/library/archive/documentation/General/Conceptual/AppSearch/UniversalLinks.html)

#### 配置

```xml
<!-- Deep Link -->
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

```
post_install do |installer|
  installer.pods_project.targets.each do |target|
    ... # Here are some configurations automatically generated by flutter

    # Start of the link_kit configuration
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',

        # Universal Links 可不配置
        # FLK_UNIVERSAL_LINK 可自定义，含 host/path，host 与 applinks 的 domain 保持一致
        'FLK_UNIVERSAL_LINK=@\"help.link.kit/power/\"',
      ]
    end 
    # End of the link_kit configuration
  end
end
```

#### 测试

```shell
# Deep Link
xcrun simctl openurl booted flk://link.kit/power
```

```shell
# Deep Link
xcrun simctl openurl booted flks://link.kit/power
```

```shell
# Universal Links
xcrun simctl openurl booted https://help.link.kit/power/action?abc=xyz
```

## Flutter

```dart
    // ⚠️⚠️⚠️
    // 因为 Android 层实现调用了 queryIntentActivities，会被（小米）误判【获取安装列表】
    // 所以 linkClickStream 和 getInitialLink 必须在同意「隐私协议」后才能调用
    _linkClickSubs = LinkKitPlatform.instance.linkClickStream().listen((String event) {
      if (kDebugMode) {
        print('linkClick: $event');
      }
      setState(() {
        _link = event;
      });
    });
    LinkKitPlatform.instance.getInitialLink().then((String? value) {
      if (kDebugMode) {
        print('initialLink: $value');
      }
      setState(() {
        _link = value;
      });
    });
```
