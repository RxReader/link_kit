import 'package:flutter_test/flutter_test.dart';
import 'package:link_kit/src/link.dart';
import 'package:link_kit/src/link_kit_method_channel.dart';
import 'package:link_kit/src/link_kit_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLinkKitPlatform
    with MockPlatformInterfaceMixin
    implements LinkKitPlatform {
  @override
  Future<String?> getInitialLink() async {
    return null;
  }

  @override
  Stream<String> linkClickStream() {
    throw UnimplementedError();
  }
}

void main() {
  final LinkKitPlatform initialPlatform = LinkKitPlatform.instance;

  test('$MethodChannelLinkKit is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelLinkKit>());
  });

  test('getInitialLink', () async {
    final MockLinkKitPlatform fakePlatform = MockLinkKitPlatform();
    LinkKitPlatform.instance = fakePlatform;
  
    expect(await Link.instance.getInitialLink(), null);
  });
}
