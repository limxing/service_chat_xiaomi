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
