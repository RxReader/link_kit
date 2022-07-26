
import 'link_kit_platform_interface.dart';

class LinkKit {
  Future<String?> getPlatformVersion() {
    return LinkKitPlatform.instance.getPlatformVersion();
  }
}
