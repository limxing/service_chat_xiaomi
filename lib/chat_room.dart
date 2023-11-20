import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:service_chat_xiaomi/chat_bean.dart';
import 'package:service_chat_xiaomi/chat_item.dart';
import 'package:service_chat_xiaomi/chat_message.dart';
import 'package:service_chat_xiaomi/service_chat_xiaomi.dart';

import 'chat_text_field.dart';

export 'chat_bean.dart';

///聊天界面，只拉取离线消息
class ChatRoom extends StatefulWidget {
  final ChatParams chatParams;
  final ValueChanged<ChatStatus> chatStatusCallback;

  const ChatRoom({Key? key, required this.chatStatusCallback, required this.chatParams}) : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> with WidgetsBindingObserver implements ServiceChatXiaomiCallBack {
  final textController = TextEditingController();

  var _messages = <ChatMessage>[];

  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  double viewBottom = 0.0;

  var messageLessThanTen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var messages = await ServiceChatXiaomi.instance.selectMessage(toAccount: widget.chatParams.toAccount) ?? [];
      messageLessThanTen = messages.length < 15;

      ///初始化数据
      setState(() {
        _messages = messageLessThanTen ? messages : messages.reversed.toList();
      });
      if (messageLessThanTen) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        });
        WidgetsBinding.instance.addObserver(this);
      }
      ServiceChatXiaomi.instance.addMessageListener(this);
      
      if(widget.chatParams.sendMsg?.isNotEmpty == true){
        textController.text = widget.chatParams.sendMsg ?? '';
        _sendMessage();
      }
    });

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && !messageLessThanTen) {
        _scrollController.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
      }
    });

    ServiceChatXiaomi.instance
        .login(appId: widget.chatParams.appId, appAccount: widget.chatParams.appAccount, getTokenUrl: widget.chatParams.tokenGetUrl)
        .then((result) => print("登录：$result"));

    // viewBottom = MediaQuery.of(context).padding.bottom;
    // print(' viewBottom $viewBottom');
  }

  var _lastBottom = 0.0;

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!_scrollController.hasClients) return;
    if (Platform.isIOS && _scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
    var bottom = MediaQueryData.fromWindow(window).viewInsets.bottom;
    if (Platform.isAndroid) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }
    if (bottom == 0 && _lastBottom > bottom) {
      _focusNode.unfocus();
    }
    _lastBottom = bottom;
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    ServiceChatXiaomi.instance.removeMessageListener(this);
    _focusNode.dispose();
    _scrollController.dispose();
    textController.dispose();
  }

  int lastTime = 0;

  int? maxLine;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: Container(
          color: Colors.grey.withAlpha(40),
          child: GestureDetector(
            onTap: () {
              _focusNode.unfocus();
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16),
              reverse: !messageLessThanTen,
              // shrinkWrap: false,
              itemBuilder: (context, index) {
                var message = _messages[index];
                if (index > 0) {
                  lastTime = _messages[index - 1].timestamp;
                }
                return ChatItem(
                  message: message,
                  lastTime: lastTime,
                  chatParams: widget.chatParams,
                );
              },
              itemCount: _messages.length,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              controller: _scrollController,
            ),
          ),
        )),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.black.withAlpha(20), width: 0.5)), color: Colors.grey.withAlpha(30)),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(
                  width: 7,
                ),
                Expanded(
                    child: ChatTextField(
                  focusNode: _focusNode,
                  textController: textController,
                  onSubmit: _sendMessage,
                )),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  decoration: BoxDecoration(color: Colors.green.withAlpha(200), borderRadius: BorderRadius.circular(8)),
                  child: CupertinoButton(
                      minSize: 36,
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      onPressed: _sendMessage,
                      child: const Text(
                        '发送',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )),
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
        toAccount: widget.chatParams.toAccount,
        msgType: 'TEXT',
        sequence: now * 100000 + 1,
        data: data,
        packetId: '',
        fromAccount: widget.chatParams.appAccount,
        success: true,
        read: true);
    setState(() {
      textController.clear();
      if (messageLessThanTen) {
        _messages.add(message);
      } else {
        _messages.insert(0, message);
      }
      checkMessageLength();
    });
    if (messageLessThanTen) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }

    //添加到数据库
    ServiceChatXiaomi.instance.insertMessage(message);

    ///发送
    var result = await ServiceChatXiaomi.instance.sendTextMessage(widget.chatParams.toAccount, data);
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
  }

  @override
  void handleMessage(List<ChatMessage> messages) {
    if (messageLessThanTen) {
      _messages.addAll(messages);
    } else {
      _messages.insertAll(0, messages);
    }

    setState(checkMessageLength);
    if (_scrollController.offset == _scrollController.position.maxScrollExtent) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (messageLessThanTen) {
          _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
        } else {
          _scrollController.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
        }
      });
    }
  }

  ///检查数量，大于10 翻转
  void checkMessageLength(){
    if (messageLessThanTen && _messages.length >= 15) {
      WidgetsBinding.instance.removeObserver(this);
      _messages = _messages.reversed.toList();
    }
    messageLessThanTen = _messages.length < 15;
  }

  @override
  void handleSendMessageTimeout(String packageId) {
    setState(() {
      _messages.firstWhere((element) => element.packetId == packageId, orElse: () => ChatMessage.NONE()).success = false;
    });
  }

  @override
  void statusChange(ChatStatus status) {
    widget.chatStatusCallback(status);
  }
  
}
