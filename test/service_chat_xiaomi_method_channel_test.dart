import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:service_chat_xiaomi/service_chat_xiaomi_method_channel.dart';

void main() {
  MethodChannelServiceChatXiaomi platform = MethodChannelServiceChatXiaomi();
  const MethodChannel channel = MethodChannel('service_chat_xiaomi');

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
