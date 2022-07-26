import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'link_kit_platform_interface.dart';

/// An implementation of [LinkKitPlatform] that uses method channels.
class MethodChannelLinkKit extends LinkKitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('link_kit');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
