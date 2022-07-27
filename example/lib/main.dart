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
