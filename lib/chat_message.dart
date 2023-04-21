import 'package:sqlite3/src/result_set.dart';

class ChatMessage {
  final String fromAccount;
  final int timestamp;
  final String toAccount;
  final String msgType;
  final int sequence;
  final String data;
  String packetId;
  bool success;

  ChatMessage({required this.timestamp,
    required this.toAccount,
    required this.msgType,
    required this.sequence,
    required this.data,
    required this.packetId,
    required this.fromAccount,
    this.success = false});

  factory ChatMessage.fromJson(Map<dynamic, dynamic> json) =>
      ChatMessage(
          fromAccount: json["fromAccount"],
          timestamp: json['timestamp'],
          toAccount: json['toAccount'],
          msgType: json['msgType'],
          sequence: json['sequence'],
          data: json['data'],
          packetId: json['packetId'],
          success: json['success'] != 0);

  factory ChatMessage.NONE() =>
      ChatMessage(timestamp: 0,
          toAccount: "toAccount",
          msgType: "msgType",
          sequence: 0,
          data: "data",
          packetId: "packetId",
          fromAccount: "fromAccount");

  Map<String, dynamic> toJson() =>
      {
        'fromAccount': fromAccount,
        'timestamp': timestamp,
        'toAccount': toAccount,
        'msgType': msgType,
        'sequence': sequence,
        'data': data,
        'packetId': packetId,
        'success': success
      };

  factory ChatMessage.fromRow(Row json) =>
      ChatMessage(
          fromAccount: json["fromAccount"],
          timestamp: json['timestamp'],
          toAccount: json['toAccount'],
          msgType: json['msgType'],
          sequence: json['sequence'],
          data: json['data'],
          packetId: json['packetId'],
          success: json['success'] != 0);
}
