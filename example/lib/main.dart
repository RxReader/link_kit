import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:link_kit/link_kit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _link;
  StreamSubscription<String>? _linkClickSubs;

  @override
  void initState() {
    super.initState();
    _linkClickSubs = Link.instance.linkClickStream().listen((String event) {
      if (kDebugMode) {
        print('linkClick: $event');
      }
      setState(() {
        _link = event;
      });
    });
    // ⚠️⚠️⚠️
    // 因为 Android 层实现调用了 queryIntentActivities，会被（小米）误判【获取安装列表】
    // 所以 getInitialLink 必须在同意「隐私协议」后才能调用
    Link.instance.getInitialLink().then((String? value) {
      if (kDebugMode) {
        print('initialLink: $value');
      }
      setState(() {
        _link = value;
      });
    });
  }

  @override
  void dispose() {
    _linkClickSubs?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Link Kit'),
        ),
        body: Center(
          child: Text(_link ?? ''),
        ),
      ),
    );
  }
}
