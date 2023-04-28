import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:service_chat_xiaomi/service_chat_xiaomi.dart';
import 'package:service_chat_xiaomi/chat_room.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text('聊天界面'),
            backgroundColor: Colors.white,
          ),
          child: ChatRoom(
            chatStatusCallback: (ChatStatus value) {},
            chatParams: ChatParams(
                appAccountHeadUrl: "https://c-ssl.dtstatic.com/uploads/blog/202010/29/20201029183028_7459b.thumb.1000_0.jpg",
                toAccountHeadUrl: "http://p2.itc.cn/q_70/images03/20200926/8a1ee939fb2442489e0f0139a52a4212.jpeg",
                tokenGetUrl: 'https://bubupic.com/user/callback/xiaomiChatToken?beeId=3',
                appAccount: "3",
                toAccount: "1",
                appId: '2882303761520165520'),
          )
      ),
    );
  }
}
