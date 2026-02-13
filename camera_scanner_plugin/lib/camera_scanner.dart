import 'dart:async';
import 'package:flutter/services.dart';

/// Flutter wrapper for native camera barcode scanner plugin.
///
/// Usage:
/// ```dart
/// await CameraScanner.init();
/// CameraScanner.onScan.listen((code) => print(code));
/// await CameraScanner.startScan(timeout: Duration(seconds: 10));
/// ```
class CameraScanner {
  static const MethodChannel _mc = MethodChannel('camera_scanner/methods');
  static const EventChannel _ec = EventChannel('camera_scanner/events');

  static bool _initialized = false;
  static Stream<String>? _scanStream;

  /// Initialize native resources (idempotent).
  static Future<void> init() async {
    try {
      await _mc.invokeMethod('init');
      _initialized = true;
    } on PlatformException catch (e) {
      _initialized = false;
      rethrow;
    }
  }

  /// Whether plugin init succeeded.
  static bool get isInitialized => _initialized;

  /// Start scanning. Results are emitted via [onScan].
  /// If [timeout] is provided and native start doesn't complete, a [TimeoutException] will be thrown.
  static Future<void> startScan({Duration? timeout}) async {
    if (!_initialized) {
      await init();
    }
    try {
      final call = _mc.invokeMethod('startScan');
      if (timeout != null) {
        await call.timeout(timeout);
      } else {
        await call;
      }
    } on PlatformException catch (e) {
      rethrow;
    }
  }

  /// Stop scanning.
  static Future<void> stopScan() async {
    try {
      await _mc.invokeMethod('stopScan');
    } on PlatformException catch (e) {
      rethrow;
    }
  }

  /// Stream of scanned barcode strings from native.
  static Stream<String> get onScan => _scanStream ??=
      _ec.receiveBroadcastStream().map((e) => e as String);
}

final scanner = CameraScanner();
