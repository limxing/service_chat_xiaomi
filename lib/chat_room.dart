import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:service_chat_xiaomi/chat_message.dart';
import 'package:service_chat_xiaomi/service_chat_xiaomi.dart';

///聊天界面，只拉取离线消息
class ChatRoom extends StatefulWidget {
  final String tokenGetUrl;
  final String appAccount;
  final String toAccount;
  final String appId;

  const ChatRoom({Key? key, required this.tokenGetUrl, required this.appAccount, required this.toAccount, required this.appId}) : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> implements ServiceChatXiaomiCallBack {
  final textController = TextEditingController();

  var isOnline = true;

  var _messages = <ChatMessage>[];

  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ServiceChatXiaomi.instance.selectMessage(
        toAccount: widget.toAccount,
        callBack: (messages) {
          ///初始化数据
          setState(() {
            _messages = messages;
          });
        });
    ServiceChatXiaomi.instance.addMessageListener(this);
    ServiceChatXiaomi.instance
        .login(appId: widget.appId, appAccount: widget.appAccount, getTokenUrl: widget.tokenGetUrl)
        .then((result) => print("登录：$result"));
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _scrollController.offset > 0) {
        _scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    ServiceChatXiaomi.instance.removeMessageListener(this);
    _focusNode.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isOnline)
          Container(
            height: 40,
            color: Colors.yellow,
            child: Center(
              child: Text("没有连接服务器，请检查网络",style: TextStyle(color: Colors.white),),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            reverse: true,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              var message = _messages[index];

              return SizedBox(
                width: 300,
                child: Align(
                  alignment: message.fromAccount == widget.toAccount ? Alignment.topLeft : Alignment.topRight,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (!message.success)
                      CupertinoButton(
                          child: Image.asset(
                            'images/retry.png',
                            width: 20,
                            height: 20,
                            package: 'service_chat_xiaomi',
                          ),
                          onPressed: () {}),
                    Text('${message.timestamp}\n${message.data}')
                  ]),
                ),
              );
            },
            itemCount: _messages.length,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            controller: _scrollController,
          ),
        ),
        SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                  child: CupertinoTextField(
                focusNode: _focusNode,
                maxLines: 1,
                controller: textController,
              )),
              CupertinoButton(
                  child: Text('发送'),
                  onPressed: () async {
                    var msg = textController.text.trim();
                    if (msg.isEmpty) {
                      return;
                    }
                    var data = {'text': msg}.toString();
                    var now = DateTime.now().millisecondsSinceEpoch;
                    //默认发送成功
                    var message = ChatMessage(
                        timestamp: now,
                        toAccount: widget.toAccount,
                        msgType: 'TEXT',
                        sequence: now * 100000 + 1,
                        data: data,
                        packetId: '',
                        fromAccount: widget.appAccount,
                        success: true);
                    setState(() {
                      textController.clear();
                      _messages.insert(0, message);
                    });
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      _scrollController.jumpTo(0);
                    });

                    //添加到数据库
                    ServiceChatXiaomi.instance.insertMessage(message);

                    ///发送
                    var result = await ServiceChatXiaomi.instance.sendTextMessage(widget.toAccount, data);
                    //发送失败
                    if (result == null) {
                      setState(() {
                        //更新数据库
                        message.success = false;
                        ServiceChatXiaomi.instance.updateSendMessage(message);
                      });
                    } else {
                      //更新数据库
                      message.packetId = result;
                      ServiceChatXiaomi.instance.updateSendMessage(message);
                    }
                    print(result);
                  })
            ],
          ),
        )
      ],
    );
  }

  @override
  void handleMessage(List<ChatMessage> messages) {
    setState(() {
      if (messages.length > 1) {
        messages.sort((a, b) => a.sequence.compareTo(b.sequence));
      }
      _messages.insertAll(0, messages);
    });
  }

  @override
  void handleSendMessageTimeout(String packageId) {
    setState(() {
      _messages.firstWhere((element) => element.packetId == packageId, orElse: () => ChatMessage.NONE()).success = false;
    });
  }

  @override
  void statusChange(bool isOnline) {
    setState(() {
      this.isOnline = isOnline;
    });
  }
}
