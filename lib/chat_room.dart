import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:service_chat_xiaomi/chat_item.dart';
import 'package:service_chat_xiaomi/chat_message.dart';
import 'package:service_chat_xiaomi/service_chat_xiaomi.dart';

import 'chat_text_field.dart';

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

class _ChatRoomState extends State<ChatRoom> with WidgetsBindingObserver implements ServiceChatXiaomiCallBack {
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
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          });
        });
    ServiceChatXiaomi.instance.addMessageListener(this);
    ServiceChatXiaomi.instance
        .login(appId: widget.appId, appAccount: widget.appAccount, getTokenUrl: widget.tokenGetUrl)
        .then((result) => print("登录：$result"));
    WidgetsBinding.instance.addObserver(this);
  }

  var _lastBottom = 0.0;

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    var bottom = MediaQueryData.fromWindow(window).viewInsets.bottom;
    if (bottom == 0 && _lastBottom > bottom) {
      _focusNode.unfocus();
    }
    _lastBottom = bottom;
  }

  @override
  void dispose() {
    super.dispose();
    ServiceChatXiaomi.instance.removeMessageListener(this);
    _focusNode.dispose();
    _scrollController.dispose();
    textController.dispose();
  }

  int lastTime = 0;

  int? maxLine = null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isOnline)
          Container(
            height: 30,
            color: Colors.red,
            child: Center(
              child: Text(
                "没有连接服务器，请检查网络",
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        Expanded(
            child: Container(
          color: Colors.grey.withAlpha(40),
          child: GestureDetector(
            onTap: () {
              _focusNode.unfocus();
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16),
              // reverse: true,
              // shrinkWrap: false,
              itemBuilder: (context, index) {
                var message = _messages[index];
                if (index > 0) {
                  lastTime = _messages[index - 1].timestamp;
                }
                return ChatItem(
                  message: message,
                  lastTime: lastTime,
                  isMyMessage: message.fromAccount == widget.appAccount,
                );
              },
              itemCount: _messages.length,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              controller: _scrollController,
            ),
          ),
        )),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.black.withAlpha(20), width: 0.5)), color: Colors.grey.withAlpha(30)),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 7,
                ),
                Expanded(
                    child: ChatTextField(
                  focusNode: _focusNode,
                  textController: textController,
                  onSubmit: _sendMessage,
                )),
                SizedBox(
                  width: 10,
                ),
                Container(
                  decoration: BoxDecoration(color: Colors.green.withAlpha(200), borderRadius: BorderRadius.circular(8)),
                  child: CupertinoButton(
                      minSize: 36,
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: Text(
                        '发送',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onPressed: _sendMessage),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  //发送消息
  void _sendMessage() async {
    var msg = textController.text.trim();
    if (msg.isEmpty) {
      return;
    }
    var data = jsonEncode({'text': msg});
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
      _messages.add(message);
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
  }

  @override
  void handleMessage(List<ChatMessage> messages) {
    if (_scrollController.offset == _scrollController.position.maxScrollExtent) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
      });
    }
    setState(() {
      // if (messages.length > 1) {
      //   messages.sort((a, b) => a.sequence.compareTo(b.sequence));
      // }
      _messages.addAll(messages);
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
