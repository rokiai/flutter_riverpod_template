import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_riverpod_template/core/platform/bridges/app_platform_bridge.dart';

/// 原生能力出口。Feature 只依赖本 Service，不依赖 Bridge。
final platformServiceProvider = Provider<PlatformService>((ref) {
  return PlatformService(AppPlatformBridge());
});

/// 业务层可注入的原生能力封装。
final class PlatformService {
  const PlatformService(this.bridge);

  final AppPlatformBridge bridge;

  /// 读取平台版本；插件未接入时返回 null。
  Future<String?> platformVersion() => bridge.platformVersion();
}
