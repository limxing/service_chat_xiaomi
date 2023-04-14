import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'service_chat_xiaomi_platform_interface.dart';

/// An implementation of [ServiceChatXiaomiPlatform] that uses method channels.
class MethodChannelServiceChatXiaomi extends ServiceChatXiaomiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('service_chat_xiaomi');

  MethodChannelServiceChatXiaomi(){
    methodChannel.setMethodCallHandler((call) {
      if(call.method == 'handleMessage'){
        print("接收消息：${call.arguments}");
        chatXiaomiCallBack?.call(call.arguments);
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
  Future invokeMethod(String methodName,[ dynamic arguments ]){
    return methodChannel.invokeMethod(methodName,arguments);
  }

}
