package yu.legend.esp_blufi

import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class EspBlufiPlugin : FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler {

    private var channel: MethodChannel? = null
    private var stateChannel: EventChannel? = null

    private var espBlufiManager: EspBlufiManager? = null
    private var messageSender: MessageSender? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        messageSender = MessageSender()

        MethodChannel(binding.binaryMessenger, BlufiConstants.METHOD_CHANNEL_NAME).apply {
            setMethodCallHandler(this@EspBlufiPlugin)
        }.also {
            channel = it
        }
        EventChannel(binding.binaryMessenger, BlufiConstants.EVENT_CHANNEL_NAME).apply {
            setStreamHandler(messageSender)
        }.also {
            stateChannel = it
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        messageSender?.release()
        messageSender = null
        channel?.setMethodCallHandler(null)
        channel = null
        stateChannel?.setStreamHandler(null)
        stateChannel = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        espBlufiManager = EspBlufiManager(
            activityPluginBinding = binding,
            postMessage = { message ->
                messageSender?.postMessage(message)
            }
        )
    }

    override fun onDetachedFromActivity() {
        espBlufiManager = null
    }

    override fun onDetachedFromActivityForConfigChanges() = Unit

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) = Unit

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        espBlufiManager?.let { manager ->
            when (call.method) {
                "getPlatformVersion" -> {
                    manager.getPlatformVersion(result)
                }

                "getAllPairedDevice" -> {
                    manager.getAllPairedDevice(result)
                }

                "startScan" -> {
                    val filter = call.argument<String>("filter")
                    manager.startScan(filter, result)
                }

                "stopScan" -> {
                    manager.stopScan(result)
                }

                "connect" -> {
                    val deviceAddress = call.argument<String>("deviceAddress")
                    manager.connect(deviceAddress, result)
                }

                "requestCloseConnection" -> {
                    manager.requestCloseConnection(result)
                }

                "requestDeviceVersion" -> {
                    manager.requestDeviceVersion(result)
                }

                "requestDeviceStatus" -> {
                    manager.requestDeviceStatus(result)
                }

                "requestDeviceWifiScan" -> {
                    manager.requestDeviceWifiScan(result)
                }

                "configProvision" -> {
                    val userName = call.argument<String>("username")
                    val password = call.argument<String>("password")
                    manager.configProvision(userName, password, result)
                }

                "sendCustomData" -> {
                    val data = call.argument<String>("data")
                    manager.sendCustomData(data, result)
                }

                "negotiateSecurity" -> {
                    manager.negotiateSecurity(result)
                }

                else -> result.notImplemented()
            }
        }
    }

    private class MessageSender : EventChannel.StreamHandler {

        private val handler by lazy {
            Handler(Looper.getMainLooper())
        }

        private var sink: EventChannel.EventSink? = null

        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            sink = events
        }

        override fun onCancel(arguments: Any?) {
            sink = null
        }

        fun postMessage(message: EspBlufiData) {
            sink?.let {
                handler.post {
                    it.success(message.toString())
                }
            }
        }

        fun release() {
            sink = null
        }
    }
}