
import 'd_manager_platform_interface.dart';

class DManager {
  Future<String?> getPlatformVersion() {
    return DManagerPlatform.instance.getPlatformVersion();
  }
}
