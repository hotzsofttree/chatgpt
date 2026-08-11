import 'dart:async';
import 'package:barcode_scanner_platform_interface/barcode_scanner_platform_interface.dart';

class SunmiBarcodeScannerPlatform implements BarcodeScannerPlatform {
  final StreamController<ScanResult> _controller = StreamController.broadcast();
  Timer? _timer;

  @override
  Future<void> start() async {
    _timer ??= Timer.periodic(const Duration(seconds: 2), (t) {
      _controller.add(
        ScanResult(
          value: 'SUNMI-${t.tick}',
          vendor: 'sunmi',
          scannedAt: DateTime.now(),
        ),
      );
    });
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Stream<ScanResult> onScanned() => _controller.stream;
}
