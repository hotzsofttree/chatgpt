# Flutter 多平台 Camera Barcode Scanner（SUNMI / IMIN / GoogleGSM）整合藍圖

> 目標：同一套 Flutter 程式碼，依 Android 平台輸出獨立 APK，避免把所有廠牌 SDK 打進同一包。

---

## 1. 架構設計（Clean Architecture + SOLID）

## 1.1 套件切分（SRP / OCP / DIP）

建議使用 **Federated Plugin**：

```text
packages/
  barcode_scanner_platform_interface/   # 抽象介面（domain 依賴它）
  barcode_scanner/                      # facade（對 app 暴露統一 API）
  barcode_scanner_sunmi/                # SUNMI 實作
  barcode_scanner_imin/                 # IMIN 實作
  barcode_scanner_googlegsm/            # GoogleGSM 實作
app/
  lib/
  android/
```

- `platform_interface`：只放抽象與資料模型（ISP/DIP）。
- 各 vendor plugin：只做該廠牌 SDK 橋接（SRP）。
- 新增廠牌只新增 package，不改既有 use case（OCP）。

---

## 2. `pubspec.yaml` 依賴矩陣範本（App）

> 重點：App 層維持抽象依賴；實作由 DI + flavor 決定。

```yaml
name: barcode_app
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ">=3.3.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

  # 狀態/DI/儲存
  get: ^4.6.6
  get_storage: ^2.1.1
  drift: ^2.20.0
  sqlite3_flutter_libs: ^0.5.24

  # 掃碼抽象 + facade
  barcode_scanner_platform_interface:
    path: ../packages/barcode_scanner_platform_interface
  barcode_scanner:
    path: ../packages/barcode_scanner

  # 三個 vendor 實作（由 flavor 控制是否打包進 APK）
  barcode_scanner_sunmi:
    path: ../packages/barcode_scanner_sunmi
  barcode_scanner_imin:
    path: ../packages/barcode_scanner_imin
  barcode_scanner_googlegsm:
    path: ../packages/barcode_scanner_googlegsm

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.2
```

---

## 3. `android/app/build.gradle` 完整 flavor 範本（Groovy）

```gradle
plugins {
    id "com.android.application"
    id "org.jetbrains.kotlin.android"
    id "dev.flutter.flutter-gradle-plugin"
}

android {
    namespace "com.example.barcode_app"
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.example.barcode_app"
        minSdkVersion 24
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        debug {
            minifyEnabled false
        }
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }

    flavorDimensions "vendor"
    productFlavors {
        sunmi {
            dimension "vendor"
            applicationIdSuffix ".sunmi"
            versionNameSuffix "-sunmi"
            manifestPlaceholders = [SCANNER_VENDOR: "sunmi"]
            resValue "string", "app_name", "Barcode SUNMI"
        }
        imin {
            dimension "vendor"
            applicationIdSuffix ".imin"
            versionNameSuffix "-imin"
            manifestPlaceholders = [SCANNER_VENDOR: "imin"]
            resValue "string", "app_name", "Barcode IMIN"
        }
        googlegsm {
            dimension "vendor"
            applicationIdSuffix ".googlegsm"
            versionNameSuffix "-googlegsm"
            manifestPlaceholders = [SCANNER_VENDOR: "googlegsm"]
            resValue "string", "app_name", "Barcode GoogleGSM"
        }
    }
}

dependencies {
    // vendor SDK 請替換成真實座標/本地 aar
    sunmiImplementation "com.vendor.sunmi:camera-barcode:1.0.0"
    iminImplementation "com.vendor.imin:camera-barcode:1.0.0"
    googlegsmImplementation "com.vendor.googlegsm:camera-barcode:1.0.0"
}
```

### AndroidManifest placeholder（app/src/main/AndroidManifest.xml）

```xml
<meta-data
    android:name="scanner.vendor"
    android:value="${SCANNER_VENDOR}" />
```

---

## 4. GetX Binding + Repository 注入範本

## 4.1 Domain 抽象

```dart
abstract class BarcodeScannerRepository {
  Future<void> start();
  Future<void> stop();
  Stream<String> onScan();
}
```

## 4.2 Data 實作

```dart
import 'package:barcode_scanner_platform_interface/barcode_scanner_platform_interface.dart';

class BarcodeScannerRepositoryImpl implements BarcodeScannerRepository {
  BarcodeScannerRepositoryImpl(this._platform);
  final BarcodeScannerPlatform _platform;

  @override
  Future<void> start() => _platform.start();

  @override
  Future<void> stop() => _platform.stop();

  @override
  Stream<String> onScan() => _platform.onScan();
}
```

## 4.3 Binding（依 flavor 注入）

```dart
import 'package:get/get.dart';
import 'package:barcode_scanner_platform_interface/barcode_scanner_platform_interface.dart';
import 'package:barcode_scanner_sunmi/barcode_scanner_sunmi.dart';
import 'package:barcode_scanner_imin/barcode_scanner_imin.dart';
import 'package:barcode_scanner_googlegsm/barcode_scanner_googlegsm.dart';

class ScannerBinding extends Bindings {
  @override
  void dependencies() {
    final platform = _resolvePlatform();

    Get.lazyPut<BarcodeScannerRepository>(
      () => BarcodeScannerRepositoryImpl(platform),
      fenix: true,
    );
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
```

---

## 5. Windows 發佈指令（PowerShell）

```powershell
flutter clean
flutter pub get

# SUNMI
flutter build apk --flavor sunmi -t lib/main_sunmi.dart --dart-define=FLAVOR=sunmi --release

# IMIN
flutter build apk --flavor imin -t lib/main_imin.dart --dart-define=FLAVOR=imin --release

# GoogleGSM
flutter build apk --flavor googlegsm -t lib/main_googlegsm.dart --dart-define=FLAVOR=googlegsm --release
```

AAB：

```powershell
flutter build appbundle --flavor sunmi -t lib/main_sunmi.dart --dart-define=FLAVOR=sunmi --release
```

---

## 6. IDE 建議（你目前技術棧）

- **Android Studio（Flutter + GetX + GetConnect + GetStorage + sqlite3 + drift）**
  - 建立 3 組 Run Configuration，分別帶 `--flavor` 與 `--dart-define`。
  - `drift`、`GetStorage` 保持在 app/data 層，不要放 vendor plugin。

- **VS Code**
  - 在 `.vscode/launch.json` 建立 sunmi/imin/googlegsm 三組啟動設定。

- **Delphi XE3 / C# 7.3**
  - 本方案主體為 Flutter/Android；若你要做後台工具串接，Delphi XE3 JSON 請用 `DBXJSON`，C# 維持 7.3 語法即可。

---

## 7. 實務檢查清單

- 每個 flavor 的 APK 大小是否明顯下降。
- 啟動時是否注入正確平台實作。
- 各廠牌掃碼流程（初始化、掃描、釋放）是否一致。
- 若新增新廠牌，只新增 plugin + flavor，不改 domain/usecase。

