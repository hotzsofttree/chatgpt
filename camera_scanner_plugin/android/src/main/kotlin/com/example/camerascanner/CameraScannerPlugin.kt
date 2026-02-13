package com.example.camerascanner

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class CameraScannerPlugin: FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private lateinit var channel: MethodChannel
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null
    private lateinit var appContext: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        appContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "camera_scanner/methods")
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "camera_scanner/events")
        eventChannel?.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "init" -> result.success(null)
            "startScan" -> {
                try {
                    val provider = ScannerProvider.getInstance(appContext)
                    provider.startScan(object : ScanCallback {
                        override fun onScanned(code: String) {
                            eventSink?.success(code)
                        }
                    })
                    result.success(null)
                } catch (e: Exception) {
                    result.error("NO_IMPL", e.message, null)
                }
            }
            "stopScan" -> {
                try {
                    val provider = ScannerProvider.getInstance(appContext)
                    provider.stopScan()
                    result.success(null)
                } catch (e: Exception) {
                    result.error("NO_IMPL", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
    }

    // EventChannel.StreamHandler
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}
