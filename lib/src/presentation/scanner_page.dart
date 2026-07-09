import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'scanner_controller.dart';

class ScannerPage extends GetView<ScannerController> {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Barcode Scanner')),
      body: Center(
        child: Obx(() {
          final item = controller.latest.value;
          if (item == null) {
            return const Text('尚未掃描');
          }
          return Text(
            'Vendor: ${item.vendor}\nCode: ${item.value}\nTime: ${item.scannedAt}',
            textAlign: TextAlign.center,
          );
        }),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'start',
            onPressed: controller.start,
            child: const Icon(Icons.play_arrow),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'stop',
            onPressed: controller.stop,
            child: const Icon(Icons.stop),
          ),
        ],
      ),
    );
  }
}
