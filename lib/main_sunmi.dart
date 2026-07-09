import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'src/di/scanner_binding.dart';
import 'src/presentation/scanner_page.dart';

void main() {
  runApp(
    GetMaterialApp(
      initialBinding: ScannerBinding(),
      home: const ScannerPage(),
    ),
  );
}
