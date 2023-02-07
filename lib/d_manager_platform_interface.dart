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

  Future<dynamic> getList() {
    throw UnimplementedError('getList() has not been implemented.');
  }

  Future<dynamic> start(Map<String, dynamic> data) {
    throw UnimplementedError('start() has not been implemented.');
  }

  Future<dynamic> pause(Map<String, dynamic> data) {
    throw UnimplementedError('pause() has not been implemented.');
  }

  Future<dynamic> resume(Map<String, dynamic> data) {
    throw UnimplementedError('resume() has not been implemented.');
  }

  Future<dynamic> cancel(Map<String, dynamic> data) {
    throw UnimplementedError('cancel() has not been implemented.');
  }

  Future<dynamic> delete(Map<String, dynamic> data) {
    throw UnimplementedError('delete() has not been implemented.');
  }

  Future<dynamic> retry(Map<String, dynamic> data) {
    throw UnimplementedError('retry() has not been implemented.');
  }

  Future<dynamic> deleteLocal(Map<String, dynamic> data) {
    throw UnimplementedError('deleteLocal() has not been implemented.');
  }

  Future<dynamic> openFile(Map<String, dynamic> data) {
    throw UnimplementedError('openFile() has not been implemented.');
  }
}
