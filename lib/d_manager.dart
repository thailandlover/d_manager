
import 'd_manager_platform_interface.dart';

class DManager {
  Future<dynamic> getList() {
    return DManagerPlatform.instance.getList();
  }

  Future<dynamic> start(Map<String, dynamic> data) {
    return DManagerPlatform.instance.start(data);
  }

  Future<dynamic> pause(Map<String, dynamic> data) {
    return DManagerPlatform.instance.pause(data);
  }

  Future<dynamic> resume(Map<String, dynamic> data) {
    return DManagerPlatform.instance.resume(data);
  }

  Future<dynamic> cancel(Map<String, dynamic> data) {
    return DManagerPlatform.instance.cancel(data);
  }

  Future<dynamic> delete(Map<String, dynamic> data) {
    return DManagerPlatform.instance.delete(data);
  }

  Future<dynamic> retry(Map<String, dynamic> data) {
    return DManagerPlatform.instance.retry(data);
  }

  Future<dynamic> deleteLocal(Map<String, dynamic> data) {
    return DManagerPlatform.instance.deleteLocal(data);
  }

  Future<dynamic> openFile(Map<String, dynamic> data) {
    return DManagerPlatform.instance.openFile(data);
  }
}
