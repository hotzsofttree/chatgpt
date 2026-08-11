import 'dart:async';
import 'package:get/get.dart';
import 'package:barcode_scanner_platform_interface/barcode_scanner_platform_interface.dart';
import '../domain/repositories/barcode_scanner_repository.dart';

class ScannerController extends GetxController {
  ScannerController(this._repository);

  final BarcodeScannerRepository _repository;
  final Rxn<ScanResult> latest = Rxn<ScanResult>();
  StreamSubscription<ScanResult>? _sub;

  Future<void> start() async {
    await _repository.start();
    _sub ??= _repository.onScanned().listen((result) {
      latest.value = result;
    });
  }

  Future<void> stop() async {
    await _repository.stop();
    await _sub?.cancel();
    _sub = null;
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
