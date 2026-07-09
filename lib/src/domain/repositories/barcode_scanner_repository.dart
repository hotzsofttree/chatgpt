import 'package:barcode_scanner_platform_interface/barcode_scanner_platform_interface.dart';

abstract class BarcodeScannerRepository {
  Future<void> start();
  Future<void> stop();
  Stream<ScanResult> onScanned();
}
