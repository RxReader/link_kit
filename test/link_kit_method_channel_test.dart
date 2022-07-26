import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_kit/link_kit_method_channel.dart';

void main() {
  MethodChannelLinkKit platform = MethodChannelLinkKit();
  const MethodChannel channel = MethodChannel('link_kit');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
