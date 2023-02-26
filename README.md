# link_kit

Flutter plugin for Deep Link/App Link/Universal Links.

## Android

#### 文档

* [创建指向应用内容的深层链接](https://developer.android.com/training/app-links/deep-linking)
* [添加 Android 应用链接](https://developer.android.com/studio/write/app-link-indexing.html)
* [simonmarquis/Android App Linking](https://simonmarquis.github.io/Android-App-Linking/)
* [Statement List Generator and Tester](https://developers.google.com/digital-asset-links/tools/generator)

#### 测试

```shell
# Deep Link
adb shell am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "flk:///power"
```

```shell
# App Link
adb shell am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "https://www.yourdomain.com/universal_link/example_app/link_kit/power"
```

## iOS

#### 文档

[Support Universal Links](https://developer.apple.com/library/archive/documentation/General/Conceptual/AppSearch/UniversalLinks.html)

#### 测试

```shell
# Deep Link
xcrun simctl openurl booted flk://link.kit/power
```

```shell
# Universal Links
xcrun simctl openurl booted https://www.yourdomain.com/universal_link/example_app/link_kit/power
```

## Flutter

#### 配置

```yaml
dependencies:
  link_kit: ^${latestTag}
#  link_kit:
#    git:
#      url: https://github.com/RxReader/link_kit.git

link_kit:
  deep_link: ${your deep link scheme}:///
  android:
    app_link: https://${your applinks domain}/universal_link/${example_app}/link_kit/ # 可选配置
  ios:
    universal_link: https://${your applinks domain}/universal_link/${example_app}/link_kit/ # 可选配置
```

#### 安装（仅iOS）

```shell
# step.1 安装必要依赖
sudo gem install plist
# step.2 切换工作目录，插件里为 example/ios/，普通项目为 ios/
cd example/ios/
# step.3 执行脚本
pod install
```

#### 编码

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
