import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_kit/src/link_kit_method_channel.dart';

void main() {
  final MethodChannelLinkKit platform = MethodChannelLinkKit();
  const MethodChannel channel = MethodChannel('v7lin.github.io/link_kit');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'getInitialLink':
          return null;
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getInitialLink', () async {
    expect(await platform.getInitialLink(), null);
  });
}
