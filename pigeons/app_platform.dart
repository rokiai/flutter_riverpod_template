import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/core/platform/bridges/app_platform.g.dart',
    kotlinOut: 'android/app/src/main/kotlin/com/example/flutter_riverpod_template/AppPlatform.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.example.flutter_riverpod_template',
    ),
    swiftOut: 'ios/Runner/AppPlatform.g.swift',
    dartOptions: DartOptions(),
    swiftOptions: SwiftOptions(),
  ),
)
/// 自研原生能力的 HostApi。改完必须重生成 Dart / Swift / Kotlin，禁止手改生成物。
@HostApi()
abstract class AppPlatformHostApi {
  /// 读取系统版本字符串。
  String? getPlatformVersion();
}
