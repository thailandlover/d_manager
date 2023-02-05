import 'package:flutter_test/flutter_test.dart';
import 'package:d_manager/d_manager.dart';
import 'package:d_manager/d_manager_platform_interface.dart';
import 'package:d_manager/d_manager_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDManagerPlatform
    with MockPlatformInterfaceMixin
    implements DManagerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final DManagerPlatform initialPlatform = DManagerPlatform.instance;

  test('$MethodChannelDManager is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDManager>());
  });

  test('getPlatformVersion', () async {
    DManager dManagerPlugin = DManager();
    MockDManagerPlatform fakePlatform = MockDManagerPlatform();
    DManagerPlatform.instance = fakePlatform;

    expect(await dManagerPlugin.getPlatformVersion(), '42');
  });
}
