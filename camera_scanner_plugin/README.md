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

**CI 建置範例**

下面是已加入的 GitHub Actions workflow，會在 push / PR 到 `main` 時為三個 flavor 建置 APK 並上傳 artifact：

- Workflow: `.github/workflows/build-flavors.yml`

在 repository 的 `Actions` 頁面可以下載每個 flavor 的 APK artifacts（或在 CI logs 驗證建置）。

進階建議
- 若要最小化 APK/AAB 大小：啟用 R8/ProGuard、移除未使用資源、並採用 ABI splits。（在 app module 的 `build.gradle` 設定）

- ProGuard / R8：若你的 flavor AAR 包含 native code 或需保留類，請在 plugin 或 app 的 `proguard-rules.pro` 裡加入必要的 keep 規則，並在 `build.gradle` 啟用 `minifyEnabled true`（release）。

- Manifest 合併：若某些 SDK 需要特殊 `<activity>`、`<service>` 或權限，請把這些設定放在對應 flavor 的 `src/<flavor>/AndroidManifest.xml`，Gradle 會在 build 時合併。這樣其他 flavor 不會包含該設定。

- AAR / .so 檔放置：
  - 把廠商提供的 AAR 放到 `android/src/<flavor>/libs/`。
  - 若 AAR 含 `.so`，確保 AAR 中的 `jni/<abi>/` 只包含你要的 ABI，或在 `build.gradle` 透過 `splits.abi` 指定要包含哪些 ABI。

- 範例 ABI splits（在 app module）：
```gradle
splits {
  abi {
    enable true
    reset()
    include 'arm64-v8a', 'armeabi-v7a'
    universalApk false
  }
}
```

- 若要發布到 Google Play：建議產生 AAB（app bundle），Play 會依裝置分發最適合的 APK，並可進一步減少下載大小。本 repo 的 CI 預設會產生 AAB artifact。

