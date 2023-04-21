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
    return  const CupertinoApp(
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text('聊天界面'),),
        child: ChatRoom(tokenGetUrl: '', appAccount: '1', toAccount: '2', appId: '',),
      ),
    );
  }
}
