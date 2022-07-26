import 'package:flutter_test/flutter_test.dart';
import 'package:link_kit/link_kit.dart';
import 'package:link_kit/link_kit_platform_interface.dart';
import 'package:link_kit/link_kit_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLinkKitPlatform 
    with MockPlatformInterfaceMixin
    implements LinkKitPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final LinkKitPlatform initialPlatform = LinkKitPlatform.instance;

  test('$MethodChannelLinkKit is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelLinkKit>());
  });

  test('getPlatformVersion', () async {
    LinkKit linkKitPlugin = LinkKit();
    MockLinkKitPlatform fakePlatform = MockLinkKitPlatform();
    LinkKitPlatform.instance = fakePlatform;
  
    expect(await linkKitPlugin.getPlatformVersion(), '42');
  });
}
