import 'package:flutter/material.dart';
import 'package:camera_scanner_plugin/camera_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Camera Scanner Example')),
        body: Center(child: ScanWidget()),
      ),
    );
  }
}

class ScanWidget extends StatefulWidget {
  @override
  State<ScanWidget> createState() => _ScanWidgetState();
}

class _ScanWidgetState extends State<ScanWidget> {
  String _last = 'idle';
  StreamSubscription<String>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = CameraScanner.onScan.listen((code) {
      setState(() { _last = code; });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    await CameraScanner.startScan();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(onPressed: _start, child: const Text('Start Scan')),
        const SizedBox(height: 12),
        Text('Result: $_last'),
      ],
    );
  }
}
