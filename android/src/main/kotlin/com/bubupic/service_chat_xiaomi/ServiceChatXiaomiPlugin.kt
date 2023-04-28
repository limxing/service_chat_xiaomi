package com.bubupic.service_chat_xiaomi

import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import com.xiaomi.mimc.MIMCGroupMessage
import com.xiaomi.mimc.MIMCMessage
import com.xiaomi.mimc.MIMCMessageHandler
import com.xiaomi.mimc.MIMCOnlineMessageAck
import com.xiaomi.mimc.MIMCOnlineStatusListener
import com.xiaomi.mimc.MIMCServerAck
import com.xiaomi.mimc.MIMCTokenFetcher
import com.xiaomi.mimc.MIMCUser
import com.xiaomi.mimc.common.HttpUtils
import com.xiaomi.mimc.common.MIMCConstant

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File

/** ServiceChatXiaomiPlugin */
class ServiceChatXiaomiPlugin : FlutterPlugin, MethodCallHandler, MIMCTokenFetcher, MIMCOnlineStatusListener,
    MIMCMessageHandler {

    private lateinit var channel: MethodChannel

    private var chatCachePath = ""
    private var user: MIMCUser? = null

    private var getTokenUrl = ""

    private var handler = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "service_chat_xiaomi")
        channel.setMethodCallHandler(this)
        chatCachePath = File(flutterPluginBinding.applicationContext.cacheDir, "service_chat").absolutePath
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        println("onMethodCall:${call.method}")
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "login" -> {
                val appId = call.argument<String>("appId")
                val appAccount = call.argument<String>("appAccount")
                getTokenUrl = call.argument<String>("getTokenUrl")!!
                if (user != null && user!!.appAccount == appAccount && user!!.isOnline) {
                    result.success(true)
                    return
                }
                user?.destroy()
                user = MIMCUser.newInstance(
                    appId!!.toLong(),
                    appAccount,
                    "device_${appAccount}",
                    chatCachePath,
                    chatCachePath
                )
                user?.registerTokenFetcher(this)
                user?.registerOnlineStatusListener(this)
                user?.registerMessageHandler(this)
                user?.enableSSO(true)
                result.success(user?.login())
            }
            "logout" -> {
                result.success(user?.logout())
            }
            "sendTextMessage" -> {
                result.success(
                    user?.sendMessage(
                        call.argument("toAccount"),
                        call.argument<String>("data")!!.encodeToByteArray(),
                        "TEXT"
                    )
                )
            }
            "isOnline" -> {
                val appAccount = call.argument<String>("appAccount")
                result.success(user?.appAccount == appAccount && user?.isOnline == true)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    ///向服务器 获取token
    override fun fetchToken(): String {
        return HttpUtils.get(getTokenUrl, mapOf())
    }

    override fun statusChange(p0: MIMCConstant.OnlineStatus?, p1: String?, p2: String?, p3: String?) {
        println("statusChange:${p0}，$p1 $p2 $p3")
        handler.post {
            channel.invokeMethod(
                "statusChange",
                mapOf("onLine" to (p0 == MIMCConstant.OnlineStatus.ONLINE), "type" to (p1 ?: ""))
            )
        }
    }

    /**
     * @param[MIMCMessage]: 单聊消息
     *        MIMCMessage.packetId: 消息ID
     *        MIMCMessage.sequence: 服务器为消息分配的递增ID，可用于去重/排序
     *        MIMCMessage.timestamp: 发送时间戳
     *        MIMCMessage.fromAccount: 发送方账号
     *        MIMCMessage.fromResource: 发送方设备标识
     *        MIMCMessage.toAccount: 接收方账号
     *        MIMCMessage.toResource: 接收方设备标识
     *        MIMCMessage.payload: 消息体
     *        MIMCMessage.bizType: 消息类型
     *        MIMCMessage.convIndex: 会话索引，默认0值，说明没有启用会话消息，该字段由服务器填充，在一个会话中连续自增，从1开始
     * @return 返回true说明消息被成功递交给应用层，若返回false说明消息递交失败，会再次触发该回调，直到返回true为止
     */
    override fun handleMessage(p0: List<MIMCMessage>?): Boolean {
        println("handleMessage:${p0?.size}")
//        val messages = arrayListOf<Map<String, Any>>()
//        p0?.forEach {
//            messages.add(
//                mapOf(
//                    "fromAccount" to it.fromAccount,
//                    "toAccount" to it.toAccount,
//                    "data" to it.payload.decodeToString(),
//                    "msgType" to it.bizType,
//                    "packetId" to it.packetId,
//                    "sequence" to it.sequence,
//                    "timestamp" to it.timestamp
//                )
//            )
//        }
        val messages = p0?.map {
            mapOf(
                "fromAccount" to it.fromAccount,
                "toAccount" to it.toAccount,
                "data" to it.payload.decodeToString(),
                "msgType" to it.bizType,
                "packetId" to it.packetId,
                "sequence" to it.sequence,
                "timestamp" to it.timestamp
            )
        }
        handler.post {
            channel.invokeMethod("handleMessage", messages)
        }

        println("handleMessage messages:$messages")
        return true
    }

    override fun handleGroupMessage(p0: MutableList<MIMCGroupMessage>?): Boolean = true

    override fun handleUnlimitedGroupMessage(p0: MutableList<MIMCGroupMessage>?): Boolean = true

    override fun handleServerAck(p0: MIMCServerAck?) {
    }

    ///消息发送失败
    override fun handleSendMessageTimeout(p0: MIMCMessage?) {
        handler.post {
            channel.invokeMethod("handleSendMessageTimeout", p0?.packetId)
        }
    }

    override fun handleSendGroupMessageTimeout(p0: MIMCGroupMessage?) {
    }

    override fun handleSendUnlimitedGroupMessageTimeout(p0: MIMCGroupMessage?) {
    }

    override fun onPullNotification(p0: Long, p1: Long): Boolean {
        return true
    }

    override fun handleOnlineMessage(p0: MIMCMessage?) {
        println("handleOnlineMessage")
    }

    override fun handleOnlineMessageAck(p0: MIMCOnlineMessageAck?) {
    }
}
