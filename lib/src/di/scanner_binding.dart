import 'package:get/get.dart';
import 'package:barcode_scanner_platform_interface/barcode_scanner_platform_interface.dart';
import 'package:barcode_scanner_sunmi/barcode_scanner_sunmi.dart';
import 'package:barcode_scanner_imin/barcode_scanner_imin.dart';
import 'package:barcode_scanner_googlegsm/barcode_scanner_googlegsm.dart';

import '../domain/repositories/barcode_scanner_repository.dart';
import '../data/repositories/barcode_scanner_repository_impl.dart';
import '../presentation/scanner_controller.dart';

class ScannerBinding extends Bindings {
  @override
  void dependencies() {
    final platform = _resolvePlatform();

    Get.lazyPut<BarcodeScannerRepository>(
      () => BarcodeScannerRepositoryImpl(platform),
      fenix: true,
    );

    Get.lazyPut(() => ScannerController(Get.find<BarcodeScannerRepository>()));
  }

  BarcodeScannerPlatform _resolvePlatform() {
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'sunmi');

    switch (flavor) {
      case 'sunmi':
        return SunmiBarcodeScannerPlatform();
      case 'imin':
        return IminBarcodeScannerPlatform();
      case 'googlegsm':
        return GoogleGsmBarcodeScannerPlatform();
      default:
        throw UnsupportedError('Unsupported FLAVOR: $flavor');
    }
  }
}
