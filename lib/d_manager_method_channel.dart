import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'd_manager_platform_interface.dart';

/// An implementation of [DManagerPlatform] that uses method channels.
class MethodChannelDManager extends DManagerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('d_manager');

  @override
  Future<dynamic> getList() async {
    return await methodChannel.invokeMethod('get_list');
  }

  @override
  Future<dynamic> start(Map<String, dynamic> data) async {
    return await methodChannel.invokeMethod('start', data);
  }

  @override
  Future<dynamic> pause(Map<String, dynamic> data) async {
    return await methodChannel.invokeMethod('pause', data);
  }

  @override
  Future<dynamic> resume(Map<String, dynamic> data) async {
    return await methodChannel.invokeMethod('resume', data);
  }

  @override
  Future<dynamic> cancel(Map<String, dynamic> data) async {
    return await methodChannel.invokeMethod('cancel', data);
  }

  @override
  Future<dynamic> delete(Map<String, dynamic> data) async {
    return await methodChannel.invokeMethod('delete', data);
  }

  @override
  Future<dynamic> retry(Map<String, dynamic> data) async {
    return await methodChannel.invokeMethod('retry', data);
  }

  @override
  Future<dynamic> deleteLocal(Map<String, dynamic> data) async {
    return await methodChannel.invokeMethod('delete_local', data);
  }

  @override
  Future<dynamic> openFile(Map<String, dynamic> data) async {
    return await methodChannel.invokeMethod('open_file', data);
  }
}
