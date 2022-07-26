import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'link_kit_method_channel.dart';

abstract class LinkKitPlatform extends PlatformInterface {
  /// Constructs a LinkKitPlatform.
  LinkKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static LinkKitPlatform _instance = MethodChannelLinkKit();

  /// The default instance of [LinkKitPlatform] to use.
  ///
  /// Defaults to [MethodChannelLinkKit].
  static LinkKitPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LinkKitPlatform] when
  /// they register themselves.
  static set instance(LinkKitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
