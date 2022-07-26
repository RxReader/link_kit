import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:link_kit/src/link_kit_platform_interface.dart';

/// An implementation of [LinkKitPlatform] that uses method channels.
class MethodChannelLinkKit extends LinkKitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final MethodChannel methodChannel = const MethodChannel('v7lin.github.io/link_kit');
  @visibleForTesting
  final EventChannel linkClickEventChannel = const EventChannel('v7lin.github.io/link_kit#click_event');

  @override
  Future<String?> getInitialLink() {
    return methodChannel.invokeMethod<String>('getInitialLink');
  }

  Stream<String>? _onLinkClickStream;

  @override
  Stream<String> linkClickStream() {
    _onLinkClickStream ??= linkClickEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) {
      return event as String;
    });
    return _onLinkClickStream!;
  }
}
