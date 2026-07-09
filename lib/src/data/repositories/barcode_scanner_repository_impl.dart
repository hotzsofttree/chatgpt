import 'package:barcode_scanner_platform_interface/barcode_scanner_platform_interface.dart';
import '../../domain/repositories/barcode_scanner_repository.dart';

class BarcodeScannerRepositoryImpl implements BarcodeScannerRepository {
  BarcodeScannerRepositoryImpl(this._platform);

  final BarcodeScannerPlatform _platform;

  @override
  Future<void> start() => _platform.start();

  @override
  Future<void> stop() => _platform.stop();

  @override
  Stream<ScanResult> onScanned() => _platform.onScanned();
}
