import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker/talker.dart';

/// 全局 Talker 实例。
final appTalkerProvider = Provider<Talker>((ref) => AppLogger.instance);

/// 应用日志入口。
abstract final class AppLogger {
  static final Talker instance = Talker();

  /// 输出 info 日志。
  static void info(String message, {String name = 'app'}) {
    instance.info(_formatMessage(message, name));
  }

  /// 输出 error 日志。
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String name = 'app',
  }) {
    instance.error(_formatMessage(message, name), error, stackTrace);
  }

  /// 非默认 [name] 时加上前缀，方便按模块过滤日志。
  static String _formatMessage(String message, String name) {
    return name == 'app' ? message : '[$name] $message';
  }
}
