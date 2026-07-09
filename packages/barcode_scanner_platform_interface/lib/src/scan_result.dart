class ScanResult {
  const ScanResult({
    required this.value,
    required this.vendor,
    required this.scannedAt,
  });

  final String value;
  final String vendor;
  final DateTime scannedAt;
}
