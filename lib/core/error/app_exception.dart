/// 应用统一异常。UI 按 [code] 映射 l10n，不直接展示原始 Dio/Drift 错误。
sealed class AppException implements Exception {
  const AppException({
    required this.code,
    required this.message,
    this.statusCode,
    this.cause,
  });

  /// 稳定、非本地化的错误码；UI 用它映射 l10n，不要直接展示 [message]。
  final String code;

  /// 调试/日志用英文说明，不是给用户看的文案。
  final String message;

  /// HTTP 状态码；非网络错误时为 null。
  final int? statusCode;

  /// 原始异常，便于日志排查。
  final Object? cause;

  @override
  String toString() => message;
}

/// 请求失败（4xx 或无法归类的错误）。
final class NetworkRequestException extends AppException {
  const NetworkRequestException({
    super.message = 'The request could not be completed.',
    super.statusCode,
    super.cause,
  }) : super(code: 'network.request');
}

/// 无网络或连接超时。
final class NetworkOfflineException extends AppException {
  const NetworkOfflineException({
    super.message = 'The network is unavailable.',
    super.cause,
  }) : super(code: 'network.offline');
}

/// 服务端 5xx。
final class NetworkServerException extends AppException {
  const NetworkServerException({
    super.message = 'The server is temporarily unavailable.',
    required super.statusCode,
    super.cause,
  }) : super(code: 'network.server');
}
