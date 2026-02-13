# Flutter 多平台 Barcode Scanner SDK 整合範本

> 目標：同一套 Flutter 程式碼，依不同 Android 平台（SUNMI / IMIN / GoogleGSM）輸出獨立 APK，避免單一 APK 過大。

## 1) `pubspec.yaml` 依賴矩陣範本

以下用 **federated plugin** 架構（建議）：

```yaml
name: barcode_app
description: Multi-vendor barcode scanner app
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ">=3.3.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

  # State / DI / Storage / Network
  get: ^4.6.6
  get_storage: ^2.1.1
  drift: ^2.20.0
  sqlite3_flutter_libs: ^0.5.24

  # 只依賴抽象介面 + façade
  barcode_scanner: ^1.0.0
  barcode_scanner_platform_interface: ^1.0.0

  # 若你走「同一 app 專案多 flavor」而非拆 3 個 app，可先全部列出
  # 真正打包大小由 android flavor + implementation 控制
  barcode_scanner_sunmi: ^1.0.0
  barcode_scanner_imin: ^1.0.0
  barcode_scanner_googlegsm: ^1.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.2
```

### 建議依賴策略（Clean Architecture + DIP）
- `presentation` / `domain` 僅依賴 `barcode_scanner_platform_interface`。
- `data` 層透過 DI 注入 `sunmi/imin/googlegsm` 實作。
- 新增廠牌時只新增 plugin，不修改既有 use case（OCP）。

---

## 2) `android/app/build.gradle` flavor 完整範本

> 檔案：`android/app/build.gradle`（Groovy 版）

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
        multiDexEnabled true
    }

    signingConfigs {
        release {
            // TODO: 請改成你的簽章設定
            // storeFile file("keystore/release.jks")
            // storePassword "***"
            // keyAlias "***"
            // keyPassword "***"
        }
    }

    buildTypes {
        debug {
            minifyEnabled false
        }
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }

    flavorDimensions "device"
    productFlavors {
        sunmi {
            dimension "device"
            applicationIdSuffix ".sunmi"
            versionNameSuffix "-sunmi"
            manifestPlaceholders = [scannerVendor: "sunmi"]
            resValue "string", "app_name", "Barcode App SUNMI"
        }

        imin {
            dimension "device"
            applicationIdSuffix ".imin"
            versionNameSuffix "-imin"
            manifestPlaceholders = [scannerVendor: "imin"]
            resValue "string", "app_name", "Barcode App IMIN"
        }

        googlegsm {
            dimension "device"
            applicationIdSuffix ".googlegsm"
            versionNameSuffix "-googlegsm"
            manifestPlaceholders = [scannerVendor: "googlegsm"]
            resValue "string", "app_name", "Barcode App GoogleGSM"
        }
    }

    // 若各廠牌需要不同 JNI / AAR，可用 sourceSets 分流
    sourceSets {
        sunmi {
            java.srcDirs += 'src/sunmi/kotlin'
        }
        imin {
            java.srcDirs += 'src/imin/kotlin'
        }
        googlegsm {
            java.srcDirs += 'src/googlegsm/kotlin'
        }
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib:1.9.24"

    // 只在對應 flavor 載入對應 vendor SDK（核心：縮小 APK）
    sunmiImplementation "com.vendor.sunmi:scanner-sdk:3.2.1"
    iminImplementation "com.vendor.imin:scanner-sdk:2.8.0"
    googlegsmImplementation "com.vendor.googlegsm:scanner-sdk:1.4.3"
}
```

### `AndroidManifest.xml` 可搭配 placeholder

```xml
<application
    android:label="@string/app_name"
    ...>

    <meta-data
        android:name="scanner.vendor"
        android:value="${scannerVendor}" />
</application>
```

---

## 3) GetX Binding + Repository 注入範本

> 範例重點：
> - `domain` 只依賴抽象（DIP）
> - 依 flavor 注入不同 `Repository` 實作

### `lib/src/domain/entities/barcode_result.dart`

```dart
class BarcodeResult {
  final String rawValue;
  final DateTime scannedAt;

  const BarcodeResult({
    required this.rawValue,
    required this.scannedAt,
  });
}
```

### `lib/src/domain/repositories/barcode_scanner_repository.dart`

```dart
import '../entities/barcode_result.dart';

abstract class BarcodeScannerRepository {
  Future<void> start();
  Future<void> stop();
  Stream<BarcodeResult> onScanned();
}
```

### `lib/src/domain/usecases/start_scan.dart`

```dart
import '../repositories/barcode_scanner_repository.dart';

class StartScan {
  final BarcodeScannerRepository repository;

  StartScan(this.repository);

  Future<void> call() => repository.start();
}
```

### `lib/src/data/repositories/barcode_scanner_repository_impl.dart`

```dart
import 'package:barcode_scanner_platform_interface/barcode_scanner_platform_interface.dart'
    as platform;
import '../../domain/entities/barcode_result.dart';
import '../../domain/repositories/barcode_scanner_repository.dart';

class BarcodeScannerRepositoryImpl implements BarcodeScannerRepository {
  final platform.BarcodeScannerPlatform scanner;

  BarcodeScannerRepositoryImpl(this.scanner);

  @override
  Future<void> start() => scanner.start();

  @override
  Future<void> stop() => scanner.stop();

  @override
  Stream<BarcodeResult> onScanned() {
    return scanner.onScanned().map(
          (e) => BarcodeResult(rawValue: e.rawValue, scannedAt: e.scannedAt),
        );
  }
}
```

### `lib/src/presentation/scanner/scanner_controller.dart`

```dart
import 'dart:async';
import 'package:get/get.dart';
import '../../domain/entities/barcode_result.dart';
import '../../domain/usecases/start_scan.dart';
import '../../domain/usecases/stop_scan.dart';
import '../../domain/repositories/barcode_scanner_repository.dart';

class ScannerController extends GetxController {
  final StartScan startScan;
  final StopScan stopScan;
  final BarcodeScannerRepository repository;

  ScannerController({
    required this.startScan,
    required this.stopScan,
    required this.repository,
  });

  final Rxn<BarcodeResult> latest = Rxn<BarcodeResult>();
  StreamSubscription<BarcodeResult>? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = repository.onScanned().listen((event) {
      latest.value = event;
    });
  }

  Future<void> start() => startScan();

  Future<void> stop() => stopScan();

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
```

### `lib/src/di/scanner_binding.dart`

```dart
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

import '../data/repositories/barcode_scanner_repository_impl.dart';
import '../domain/repositories/barcode_scanner_repository.dart';
import '../domain/usecases/start_scan.dart';
import '../domain/usecases/stop_scan.dart';
import '../presentation/scanner/scanner_controller.dart';

import 'package:barcode_scanner_sunmi/barcode_scanner_sunmi.dart';
import 'package:barcode_scanner_imin/barcode_scanner_imin.dart';
import 'package:barcode_scanner_googlegsm/barcode_scanner_googlegsm.dart';
import 'package:barcode_scanner_platform_interface/barcode_scanner_platform_interface.dart';

class ScannerBinding extends Bindings {
  @override
  void dependencies() {
    final BarcodeScannerPlatform scanner = _resolveByFlavor();

    Get.lazyPut<BarcodeScannerRepository>(
      () => BarcodeScannerRepositoryImpl(scanner),
      fenix: true,
    );

    Get.lazyPut(() => StartScan(Get.find<BarcodeScannerRepository>()));
    Get.lazyPut(() => StopScan(Get.find<BarcodeScannerRepository>()));

    Get.lazyPut(
      () => ScannerController(
        startScan: Get.find<StartScan>(),
        stopScan: Get.find<StopScan>(),
        repository: Get.find<BarcodeScannerRepository>(),
      ),
    );
  }

  BarcodeScannerPlatform _resolveByFlavor() {
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

### `lib/main_sunmi.dart` / `main_imin.dart` / `main_googlegsm.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'src/di/scanner_binding.dart';

void main() {
  runApp(
    GetMaterialApp(
      initialBinding: ScannerBinding(),
      home: const Scaffold(body: Center(child: Text('Scanner App'))),
    ),
  );
}
```

> 編譯時傳 flavor 常數：
> `--dart-define=FLAVOR=sunmi` / `imin` / `googlegsm`

---

## 4) Windows 發佈指令（可直接用）

```powershell
flutter clean
flutter pub get

flutter build apk --flavor sunmi -t lib/main_sunmi.dart --dart-define=FLAVOR=sunmi --release
flutter build apk --flavor imin -t lib/main_imin.dart --dart-define=FLAVOR=imin --release
flutter build apk --flavor googlegsm -t lib/main_googlegsm.dart --dart-define=FLAVOR=googlegsm --release
```

若要 AAB：

```powershell
flutter build appbundle --flavor sunmi -t lib/main_sunmi.dart --dart-define=FLAVOR=sunmi --release
```

---

## 5) Android Studio / VS Code 實務建議
- Android Studio：建立 3 組 Run Configuration（sunmi/imin/googlegsm），分別設定 `--flavor` 與 `--dart-define`。
- VS Code：在 `.vscode/launch.json` 建立 3 組 Flutter 啟動參數，避免手動輸入。
- GetStorage / drift：保持在 app 層，不要放進 vendor plugin，維持 plugin 單一職責（SRP）。

