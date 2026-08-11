import 'scan_result.dart';

abstract class BarcodeScannerPlatform {
  Future<void> start();
  Future<void> stop();
  Stream<ScanResult> onScanned();
}
