import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'chat_message.dart';
import 'service_chat_xiaomi_platform_interface.dart';

/// An implementation of [ServiceChatXiaomiPlatform] that uses method channels.
class MethodChannelServiceChatXiaomi extends ServiceChatXiaomiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('service_chat_xiaomi');

  MethodChannelServiceChatXiaomi() {
    methodChannel.setMethodCallHandler((call) {
      switch(call.method){
        case "handleMessage":
          print("接收消息：${call.arguments} chatXiaomiCallBacks:${chatXiaomiCallBacks.length}" );
          var messages = (call.arguments as List<dynamic>).map((e) => ChatMessage.fromJson(e)).toList();
          for (var element in chatXiaomiCallBacks) {
            element.handleMessage(messages);
          }
          break;
        case "handleSendMessageTimeout":
          for (var element in chatXiaomiCallBacks) {
            element.handleSendMessageTimeout(call.arguments);
          }
          print("handleSendMessageTimeout：${call.arguments}" );
          break;
        case 'statusChange':

          print("statusChange：${call.arguments}" );
          for (var element in chatXiaomiCallBacks) {
            element.statusChange(call.arguments);
          }
          break;
      }
      return Future.value(null);
    });
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future invokeMethod(String methodName, [dynamic arguments]) {
    return methodChannel.invokeMethod(methodName, arguments);
  }
}
