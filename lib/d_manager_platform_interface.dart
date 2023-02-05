import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'd_manager_method_channel.dart';

abstract class DManagerPlatform extends PlatformInterface {
  /// Constructs a DManagerPlatform.
  DManagerPlatform() : super(token: _token);

  static final Object _token = Object();

  static DManagerPlatform _instance = MethodChannelDManager();

  /// The default instance of [DManagerPlatform] to use.
  ///
  /// Defaults to [MethodChannelDManager].
  static DManagerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DManagerPlatform] when
  /// they register themselves.
  static set instance(DManagerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
