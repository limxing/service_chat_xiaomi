import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:service_chat_xiaomi/service_chat_xiaomi.dart';

import 'service_chat_xiaomi_method_channel.dart';
import 'chat_message.dart';

abstract class ServiceChatXiaomiPlatform extends PlatformInterface {
  /// Constructs a ServiceChatXiaomiPlatform.
  ServiceChatXiaomiPlatform() : super(token: _token);

  static final Object _token = Object();

  static ServiceChatXiaomiPlatform _instance = MethodChannelServiceChatXiaomi();

  /// The default instance of [ServiceChatXiaomiPlatform] to use.
  ///
  /// Defaults to [MethodChannelServiceChatXiaomi].
  static ServiceChatXiaomiPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ServiceChatXiaomiPlatform] when
  /// they register themselves.
  static set instance(ServiceChatXiaomiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future invokeMethod(String methodName,[ dynamic arguments ]);

  List<ServiceChatXiaomiCallBack> chatXiaomiCallBacks = [];

  void addMessageListener(ServiceChatXiaomiCallBack callback){
    if(!chatXiaomiCallBacks.contains(callback)){
      chatXiaomiCallBacks.add(callback);
    }
  }

  void removeMessageListener(ServiceChatXiaomiCallBack callback){
    chatXiaomiCallBacks.remove(callback);
  }
  
  void addWelcomeMsg(ChatMessage msg) {
    for (var element in chatXiaomiCallBacks) {
      element.handleMessage([msg]);
    }
  }
}
