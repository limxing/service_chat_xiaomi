
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:service_chat_xiaomi/chat_message.dart';

class ChatItem extends StatelessWidget {
  final ChatMessage message;
  final int lastTime;
  final bool isMyMessage;

  const ChatItem({Key? key, required this.message, required this.lastTime, required this.isMyMessage}) : super(key: key);

  ///根据给定的日期得到format后的日期
  String _date() {
    var date = DateTime.fromMillisecondsSinceEpoch(message.timestamp);
    var dateOriginal = DateFormat("yyyy-MM-dd HH:mm").format(date);
    //现在的日期
    var today = DateTime.now();
    //今天的23:59:59
    var standardDate = DateTime(today.year, today.month, today.day, 23, 59, 59);
    //传入的日期与今天的23:59:59秒进行比较
    Duration diff = standardDate.difference(date);
    if (diff < const Duration(days: 1)) {
      //今天
      // 09:20
      return dateOriginal.substring(11, 16);
    } else if (diff >= const Duration(days: 1) && diff < const Duration(days: 2)) {
      //昨天
      //昨天09:20
      return "昨天 ${dateOriginal.substring(11, 16)}";
    } else {
      //昨天之前
      // 2019-01-23 09:20
      return dateOriginal.substring(0, 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    var children = [
      SizedBox(width: 6,),
      ClipRRect(
        child: Image.network(
          'https://c-ssl.duitang.com/uploads/blog/202107/12/20210712182552_00096.png',
          width: 40,
          height: 40,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      // Expanded(child: Text('${message.timestamp}\n${message.data}')),
      ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6,minHeight: 40),
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(color:isMyMessage ? Colors.green : Colors.white,borderRadius: BorderRadius.circular(10)),
          child: message.getWidget(isMyMessage),
        ),
      ),
      if (!message.success)
        CupertinoButton(
            child: Image.asset(
              'images/retry.png',
              width: 20,
              height: 20,
              package: 'service_chat_xiaomi',
            ),
            onPressed: () {}),
    ];
    if (isMyMessage) {
      children = children.reversed.toList();
    }
    return Column(
      children: [
        if (message.timestamp - lastTime > 1000 * 60)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              _date(),
              style: const TextStyle(color: Colors.black45, fontSize: 12),
            ),
          ),
        Align(
          alignment: isMyMessage ? Alignment.topRight : Alignment.topLeft,
          child: Wrap(
            children: children,
            spacing: 8,
          ),
        ),
        const SizedBox(
          height: 12,
        ),
      ],
    );
  }
}
