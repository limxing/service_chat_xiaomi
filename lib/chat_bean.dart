class ChatStatus {
  final bool onLine;
  final ChatStatusType type;

  ChatStatus({required this.onLine, required this.type});
}

enum ChatStatusType {
  NONE(""),
  NET_ERROR("连接服务器失败，请检查网络"),
  LOGOUT("该账号已在其他设备登录");

  final String tips;

  const ChatStatusType(this.tips);
}

class ChatParams {
  final String tokenGetUrl;
  final String appAccount;
  final String toAccount;
  final String appId;
  final String appAccountHeadUrl;
  final String toAccountHeadUrl;
  final Map<String, String>? imgHttpHeaders;
  final String? sendMsg;

  ChatParams({
    required this.appAccountHeadUrl,
    required this.toAccountHeadUrl,
    required this.tokenGetUrl,
    required this.appAccount,
    required this.toAccount,
    required this.appId,
    this.imgHttpHeaders,
    this.sendMsg,
  });
}
