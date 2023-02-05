import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'd_manager_platform_interface.dart';

/// An implementation of [DManagerPlatform] that uses method channels.
class MethodChannelDManager extends DManagerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('d_manager');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
