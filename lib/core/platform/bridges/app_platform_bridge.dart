import 'package:flutter/services.dart';
import 'package:flutter_riverpod_template/core/platform/bridges/app_platform.g.dart';

/// Pigeon HostApi 的 Dart 侧 facade。Feature 禁止直接依赖本文件。
final class AppPlatformBridge {
  AppPlatformBridge({AppPlatformHostApi? api})
    : _api = api ?? AppPlatformHostApi();

  final AppPlatformHostApi _api;

  /// 向原生查询系统版本。
  Future<String?> platformVersion() async {
    try {
      return await _api.getPlatformVersion();
    } on MissingPluginException {
      // 插件未接入（例如纯 Dart 测试）时当作没有原生能力。
      return null;
    } on PlatformException catch (error) {
      // Pigeon 通道未注册同样降级，避免启动直接失败。
      if (error.code == 'channel-error') {
        return null;
      }
      rethrow;
    }
  }
}
