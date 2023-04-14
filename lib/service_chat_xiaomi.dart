import 'service_chat_xiaomi_platform_interface.dart';

typedef ServiceChatXiaomiCallBack = void Function(List<Map<String, String>>);

class ServiceChatXiaomi {
  static final ServiceChatXiaomi _instance = ServiceChatXiaomi();

  static ServiceChatXiaomi get instance => _instance;

  void setMessageCallback(ServiceChatXiaomiCallBack callback) {
    ServiceChatXiaomiPlatform.instance.chatXiaomiCallBack = callback;
  }

  ///登录
  Future login({required String appId, required String appAccount}) {
    return ServiceChatXiaomiPlatform.instance.invokeMethod('login',{
      'appId':appId,
      'appAccount':appAccount,
      'getTokenUrl':''
    });
  }

  ///退出
  Future logout(){
    return ServiceChatXiaomiPlatform.instance.invokeMethod('logout');
  }

  ///发消息
  Future sendTextMessage(String toAccount,String text){
    return ServiceChatXiaomiPlatform.instance.invokeMethod('sendTextMessage',{
      'toAccount':toAccount,
      'text':text
    });
  }

}
