import 'dart:async';
import 'package:flutter/services.dart';

class CameraScanner {
  static const MethodChannel _mc = MethodChannel('camera_scanner/methods');
  static const EventChannel _ec = EventChannel('camera_scanner/events');

  static Future<void> init() async {
    await _mc.invokeMethod('init');
  }

  /// Triggers native startScan; results arrive via [onScan] stream.
  static Future<void> startScan() async {
    await _mc.invokeMethod('startScan');
  }

  static Future<void> stopScan() async {
    await _mc.invokeMethod('stopScan');
  }

  static Stream<String> get onScan => _ec.receiveBroadcastStream().map((e) => e as String);
}

final scanner = CameraScanner();
