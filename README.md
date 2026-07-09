# 最小可執行：Flutter 多平台 Camera Barcode Scanner

本專案提供「可直接跑」的最小骨架：
- SUNMI / IMIN / GoogleGSM 三平台注入
- GetX + Repository（DIP）
- flavor 打包切分，避免單一 APK 過大

## 1) 執行（Windows PowerShell）

```powershell
flutter clean
flutter pub get

# SUNMI
flutter run --flavor sunmi -t lib/main_sunmi.dart --dart-define=FLAVOR=sunmi

# IMIN
flutter run --flavor imin -t lib/main_imin.dart --dart-define=FLAVOR=imin

# GoogleGSM
flutter run --flavor googlegsm -t lib/main_googlegsm.dart --dart-define=FLAVOR=googlegsm
```

## 2) 發佈 APK（Windows PowerShell）

```powershell
flutter build apk --flavor sunmi -t lib/main_sunmi.dart --dart-define=FLAVOR=sunmi --release
flutter build apk --flavor imin -t lib/main_imin.dart --dart-define=FLAVOR=imin --release
flutter build apk --flavor googlegsm -t lib/main_googlegsm.dart --dart-define=FLAVOR=googlegsm --release
```

## 3) 架構重點

- `packages/barcode_scanner_platform_interface`：抽象介面（ISP / DIP）
- `packages/barcode_scanner_*`：各廠牌實作（SRP）
- `lib/src/di/scanner_binding.dart`：依 `FLAVOR` 注入實作（OCP）

## 4) IDE 建議

- Android Studio：建立 3 組 Run Configuration（sunmi/imin/googlegsm）。
- VS Code：在 `launch.json` 加 3 組 args（`--flavor` + `--dart-define`）。
- Delphi XE3 注意：若需外部工具串接 JSON，請使用 `DBXJSON`。
- C# 外部工具維持 7.3 語法。
