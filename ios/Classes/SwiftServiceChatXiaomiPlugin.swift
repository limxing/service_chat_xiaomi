import Flutter
import UIKit
import MMCSDK
import Alamofire

public class SwiftServiceChatXiaomiPlugin: NSObject, FlutterPlugin, parseTokenDelegate, onlineStatusDelegate, handleMessageDelegate {
//    public func onLaunched(_ fromAccount: String!, fromResource: String!, callId: Int64, appContent: Data!) -> MIMCLaunchedResponse! {
//
//    }
    var channel:FlutterMethodChannel
    
    var getTokenUrl:String = ""
    
    init(channel:FlutterMethodChannel) {
        self.channel = channel
    }
    
    public func onAnswered(_ callId: Int64, accepted: Bool, desc: String!) {
        
    }
    
    public func onClosed(_ callId: Int64, desc: String!) {
        
    }
    
    public func onData(_ callId: Int64, fromAccount: String!, resource: String!, data: Data!, dataType: RtsDataType, channelType: RtsChannelType) {
        
    }
    
    public func onSendDataSuccess(_ callId: Int64, dataId: Int32, context: Any!) {
        
    }
    
    public func onSendDataFailure(_ callId: Int64, dataId: Int32, context: Any!) {
        
    }
    
    public func handleMessage(_ packets: [MIMCMessage]!, user: MCUser!) -> Bool {
//        channel.invokeMethod("handleMessage", p0?.map {
//                    mapOf(
//                        "fromAccount" to it.fromAccount,
//                        "msg" to it.payload.decodeToString(),
//                        "msgType" to it.bizType,
//                        "packetId" to it.packetId,
//                        "sequence" to it.sequence,
//                        "timestamp" to it.timestamp
//                    )
//                })
        var messages = [Dictionary<String, Any?>]()
        packets.forEach { message in
            messages.append(["fromAccount":message.getFromAccount(),"msg":String(data: message.getPayload(), encoding: .utf8),"msgType":message.getBizType(),"packetId":message.getPacketId(),"sequence":message.getSequence(),"timestamp":message.getTimestamp()])
        }
        channel.invokeMethod("handleMessage", arguments: messages)
        return true
    }
    
    public func handleGroupMessage(_ packets: [MIMCGroupMessage]!) -> Bool {
        return true
    }
    
    public func handle(_ serverAck: MIMCServerAck!) {
        
    }
    
    public func handleUnlimitedGroupMessage(_ packets: [MIMCGroupMessage]!) -> Bool {
        return true
    }
    
    public func handleOnlineMessage(_ onlineMessage: MIMCMessage!) {
        
    }
    
    public func handle(_ onlineMessageAck: MCOnlineMessageAck!) {
        
    }
    
    public func onPullNotification(_ minSequence: Int64, maxSequence: Int64) -> Bool {
        return true
    }
    
    public func handleSendMessageTimeout(_ message: MIMCMessage!) {
        
    }
    
    public func handleSendGroupMessageTimeout(_ groupMessage: MIMCGroupMessage!) {
        
    }
    
    public func handleSendUnlimitedGroupMessageTimeout(_ groupMessage: MIMCGroupMessage!) {
        
    }
    
    public func statusChange(_ user: MCUser!, status: Int32, type: String!, reason: String!, desc: String!) {
        NSLog("status:\(status),desc:\(String(describing: desc))")
    }
    
    public func parseProxyServiceToken(_ callback: ((Data?) -> Void)!) {
        
        AF.request(getTokenUrl).response { response in
            let data = response.data
            callback(data)
        }
    }
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "service_chat_xiaomi", binaryMessenger: registrar.messenger())
      let instance = SwiftServiceChatXiaomiPlugin(channel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
    
    var _user:MCUser?

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      
      switch call.method {
      case "login":
          let dic = call.arguments as! NSDictionary
          let appId = dic.string(key: "appId")
          let appAccount = dic.string(key: "appAccount")
          getTokenUrl = dic.string(key: "getTokenUrl")
          _user?.destroy()
          _user = MCUser.init(appId: Int64(appId)!, andAppAccount: appAccount)
          _user?.parseTokenDelegate = self
          _user?.onlineStatusDelegate = self
          _user?.handleMessageDelegate = self
//          _user?.handleRtsCallDelegate = self
          result(_user?.login())
          break
      case "logout":
          _user?.logout()
          _user?.destroy()
          result(true)
          break
      case "sendTextMessage":
          let dic = call.arguments as! NSDictionary
          let toAccount = dic.string(key: "appAccount")
          result(_user?.sendMessage(toAccount, payload: dic.string(key: "text").data(using: .utf8), bizType: "TEXT"))
          break
      default:
          result("iOS " + UIDevice.current.systemVersion)
      }
    
  }
}
extension NSDictionary{
    
    func string(key:String) -> String{
        return self[key] as? String ?? ""
    }
    
    func int(key:String) -> Int? {
        return self[key] as? Int
    }
}
