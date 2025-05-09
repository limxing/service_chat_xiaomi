import 'package:flutter_test/flutter_test.dart';
import 'package:service_chat_xiaomi/chat_message.dart';
import 'package:service_chat_xiaomi/service_chat_xiaomi.dart';
import 'package:service_chat_xiaomi/service_chat_xiaomi_platform_interface.dart';
import 'package:service_chat_xiaomi/service_chat_xiaomi_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockServiceChatXiaomiPlatform
    with MockPlatformInterfaceMixin
    implements ServiceChatXiaomiPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  ServiceChatXiaomiCallBack? chatXiaomiCallBack;

  @override
  Future invokeMethod(String methodName, [arguments]) {
    throw UnimplementedError();
  }

  @override
  late List<ServiceChatXiaomiCallBack> chatXiaomiCallBacks;

  @override
  void addMessageListener(ServiceChatXiaomiCallBack callback) {
    // TODO: implement addMessageListener
  }

  @override
  void removeMessageListener(ServiceChatXiaomiCallBack callback) {
    // TODO: implement removeMessageListener
  }

  @override
  void addWelcomeMsg(ChatMessage msg) {
    // TODO: implement addWelcomeMsg
  }
}

void main() {
  final ServiceChatXiaomiPlatform initialPlatform = ServiceChatXiaomiPlatform.instance;

  test('$MethodChannelServiceChatXiaomi is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelServiceChatXiaomi>());
  });

  test('getPlatformVersion', () async {
    ServiceChatXiaomi serviceChatXiaomiPlugin = ServiceChatXiaomi();
    MockServiceChatXiaomiPlatform fakePlatform = MockServiceChatXiaomiPlatform();
    ServiceChatXiaomiPlatform.instance = fakePlatform;

    // expect(await serviceChatXiaomiPlugin.getPlatformVersion(), '42');
  });
}
