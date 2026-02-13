# camera_scanner_plugin

簡易範例：示範如何用 Android `productFlavors` 針對不同廠商（SUNMI / IMIN / GoogleGSM）編譯包含各自 SDK 的 APK。

重點檔案：
- [camera_scanner_plugin/lib/camera_scanner.dart](camera_scanner_plugin/lib/camera_scanner.dart)
- [camera_scanner_plugin/android/build.gradle](camera_scanner_plugin/android/build.gradle)
- flavor 實作：
  - [camera_scanner_plugin/android/src/sunmi/java/com/example/camerascanner/ScannerProviderImpl.java](camera_scanner_plugin/android/src/sunmi/java/com/example/camerascanner/ScannerProviderImpl.java)
  - [camera_scanner_plugin/android/src/imin/java/com/example/camerascanner/ScannerProviderImpl.java](camera_scanner_plugin/android/src/imin/java/com/example/camerascanner/ScannerProviderImpl.java)
  - [camera_scanner_plugin/android/src/googlegsm/java/com/example/camerascanner/ScannerProviderImpl.java](camera_scanner_plugin/android/src/googlegsm/java/com/example/camerascanner/ScannerProviderImpl.java)

本地建置範例（在 plugin 根目錄執行）：
```bash
# 建置 SUNMI 版本
flutter build apk --flavor sunmi -t example/lib/main.dart

# 建置 IMIN 版本
flutter build apk --flavor imin -t example/lib/main.dart

# 建置 GoogleGSM 版本
flutter build apk --flavor googlegsm -t example/lib/main.dart
```

注意：範例中 AAR 為 placeholder，實際使用時請把廠商 SDK 的 AAR 放到對應的 `android/src/<flavor>/libs/`。
