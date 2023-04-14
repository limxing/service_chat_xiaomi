import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:service_chat_xiaomi/service_chat_xiaomi.dart';

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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
         child: Column(children: [
           ElevatedButton(onPressed: ()async{
             var result = await ServiceChatXiaomi.instance.login(appId: "2882303761520165520", appAccount: "1");
             print("登录结果：$result");
           }, child: Text('登录')),
           ElevatedButton(onPressed: ()async{
             var result = await ServiceChatXiaomi.instance.sendTextMessage("2", "hello word");
             print("消息结果：$result");
           }, child: Text('发消息给2')),
         ],),
        ),
      ),
    );
  }
}
