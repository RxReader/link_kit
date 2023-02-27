# link_kit

Flutter plugin for Deep Link/App Link/Universal Links.

## ⚠️⚠️⚠️

* link_kit 1.0.0 配置并不与 0.0.x 兼容，请手动删除 0.0.x 配置
* 因为 Android 的 manifestPlaceholders 能力有限，又懒得写需要兼容各版本的 Gradle 插件，所以默认只支持配置一个 DeepLink/AppLink/UniversalLink

## Android

#### 文档

* [创建指向应用内容的深层链接](https://developer.android.com/training/app-links/deep-linking)
* [添加 Android 应用链接](https://developer.android.com/studio/write/app-link-indexing.html)
* [simonmarquis/Android App Linking](https://simonmarquis.github.io/Android-App-Linking/)
* [Statement List Generator and Tester](https://developers.google.com/digital-asset-links/tools/generator)

#### 配置

```
# 不需要做任何额外接入工作
# 配置已集成到脚本里
```

* App Links

assetlinks.json - 通过 https://${your applinks domain}/.well-known/assetlinks.json 链接可访问

示例:

https://${your applinks domain}/universal_link/${example_app}/link_kit/

```json
[
  {
    "relation": [
      "delegate_permission/common.handle_all_urls"
    ],
    "target": {
      "namespace": "android_app",
      "package_name": "your_app_package_name",
      "sha256_cert_fingerprints": [
        "your_app_package_fingerprint_sha256"
      ]
    }
  }
]
```

> [获取 Android 签名信息](https://github.com/RxReader/wechat_kit#android)

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

#### 配置

```
# 不需要做任何额外接入工作
# 配置已集成到脚本里
```

* Universal Links

apple-app-site-association - 通过 https://${your applinks domain}/.well-known/apple-app-site-association 链接可访问

示例:

https://${your applinks domain}/universal_link/${example_app}/link_kit/

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "${your team id}.${your app bundle id}",
        "paths": [
          "/universal_link/${example_app}/link_kit/*"
        ]
      }
    ]
  }
}
```

> ⚠️ 很多 SDK 都会用到 universal_link，可为不同 SDK 分配不同的 path 以作区分

#### 测试

```shell
# Deep Link
xcrun simctl openurl booted flk:///power
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
