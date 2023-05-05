import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:service_chat_xiaomi/service_chat_xiaomi.dart';
import 'package:sqlite3/sqlite3.dart';

import 'chat_bean.dart';
import 'chat_message.dart';
import 'service_chat_xiaomi_platform_interface.dart';

// typedef ServiceChatXiaomiCallBack = void Function(List<ChatMessage>);

abstract class ServiceChatXiaomiCallBack{
  void handleMessage(List<ChatMessage> messages);
  void handleSendMessageTimeout(String packageId);

  void statusChange(ChatStatus arguments);
}

typedef DatabaseCallBack = void Function(Database db);

class ServiceChatXiaomi implements ServiceChatXiaomiCallBack {
  static final ServiceChatXiaomi _instance = ServiceChatXiaomi();

  static ServiceChatXiaomi get instance => _instance;

  var _appAccount = "";

  void addMessageListener(ServiceChatXiaomiCallBack callback) {
    ServiceChatXiaomiPlatform.instance.addMessageListener(callback);
  }

  void removeMessageListener(ServiceChatXiaomiCallBack callback) {
    ServiceChatXiaomiPlatform.instance.removeMessageListener(callback);
  }

  Future runSql({required DatabaseCallBack dbCallback}) async {
    var documentPath = await getApplicationDocumentsDirectory();
    var db = sqlite3.open(path.join(documentPath.path, "chat_$_appAccount.db"));
    dbCallback(db);
    db.dispose();
  }

  ///数据库查询消息
  void selectMessage({int page = 1, pageSize = 30, required String toAccount, required ValueSetter<List<ChatMessage>> callBack}) {
    runSql(dbCallback: (db) {
      var resultSet = db.select('SELECT * FROM single where fromAccount=? or toAccount=? ORDER BY sequence  limit 50', [toAccount, toAccount]);
      var messages = resultSet.map((e) => ChatMessage.fromRow(e)).toList();
      callBack(messages);
    });
  }

  /// 查询没有阅读的消息
  void selectUnReadMessageCount({required String appAccount, required ValueSetter<int> callBack}){
    runSql(dbCallback: (db) {
      var resultSet = db.select('SELECT count(*) as count FROM single where fromAccount=? and read=0', [appAccount]);
      callBack(resultSet.single['count']);
    });
  }
  /// 将消息全部变成已读
  void updateAllMessageHasRead({required String appAccount,required String toAccount,required VoidCallback callBack}){
    runSql(dbCallback: (db) {
      db.select('UPDATE single set read=1 where fromAccount=? and read=0 and toAccount=?', [appAccount,toAccount]);
      callBack();
    });
  }

  ///添加数据
  void insertMessage(ChatMessage message) {
    runSql(dbCallback: (db) {
      db.singleInset.execute([
        message.fromAccount,
        message.toAccount,
        message.data,
        message.packetId,
        message.sequence,
        message.timestamp,
        message.msgType,
        message.success,
        message.read
      ]);
      // rowIdCallback(db.lastInsertRowId);
    });
  }

  ///发送消息成功或者失败的更新
  void updateSendMessage(ChatMessage message) {
    runSql(dbCallback: (db) {
      db.execute('update single set packetId=?,success=? where sequence=?', [message.packetId, message.success, message.sequence]);
    });
  }
  ///登录
  Future login({required String appId, required String appAccount, required String getTokenUrl}) async {
    _appAccount = appAccount;
    runSql(
      dbCallback: (db) {
        db.execute('''
        CREATE TABLE IF NOT EXISTS single(
          id INTEGER NOT NULL PRIMARY KEY, 
          fromAccount TEXT NOT NULL,
          toAccount TEXT NOT NULL,
          data TEXT NOT NULL,
          packetId TEXT NOT NULL, 
          sequence INTEGER NOT NULL, 
          timestamp INTEGER NOT NULL,
          msgType TEXT NOT NULL,
          success INTEGER NOT NULL DEFAULT 1,
          read INTEGER NOT NULL DEFAULT 0
        );
    ''');
      },
    );

    addMessageListener(this);
    return ServiceChatXiaomiPlatform.instance.invokeMethod('login', {'appId': appId, 'appAccount': appAccount, 'getTokenUrl': getTokenUrl});
  }

  ///退出
  Future logout() {
    return ServiceChatXiaomiPlatform.instance.invokeMethod('logout');
  }

  ///发消息
  Future sendTextMessage(String toAccount, String text) {
    return ServiceChatXiaomiPlatform.instance.invokeMethod('sendTextMessage', {'toAccount': toAccount, 'data': text});
  }

  Future isOnline(String appAccount) {
    return ServiceChatXiaomiPlatform.instance.invokeMethod('isOnline', {'appAccount': appAccount});
  }

  @override
  void handleMessage(List<ChatMessage> messages) {
    runSql(dbCallback: (Database db) {
      var stmt = db.singleInset;
      for (var element in messages) {
        stmt.execute([
          element.fromAccount,
          element.toAccount,
          element.data,
          element.packetId,
          element.sequence,
          element.timestamp,
          element.msgType,
          element.success,
          element.read
        ]);
      }
    });
    print("收到消息:${messages}");

  }

  @override
  void handleSendMessageTimeout(String packageId) {
    runSql(dbCallback: (db) {
      db.execute('update single set success=0 where packageId=?', [packageId]);
    });
  }

  @override
  void statusChange(ChatStatus arguments) {

  }
}

extension DatabaseExtension on Database {
  PreparedStatement get singleInset =>
      prepare('INSERT INTO single (fromAccount,toAccount,data,packetId,sequence,timestamp,msgType,success,read) VALUES (?,?,?,?,?,?,?,?,?)');
}
