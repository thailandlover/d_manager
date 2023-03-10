import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d_manager/d_manager_method_channel.dart';

void main() {
  MethodChannelDManager platform = MethodChannelDManager();
  const MethodChannel channel = MethodChannel('d_manager');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
