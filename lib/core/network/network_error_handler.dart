import 'package:dio/dio.dart';

import 'package:flutter_riverpod_template/core/error/app_exception.dart';

/// 把 Dio 等原始错误归一成 [AppException]。
AppException normalizeError(Object error) {
  // 已经是应用异常则原样返回，避免二次包装丢掉 [AppException.code]。
  if (error is AppException) {
    return error;
  }

  if (error is DioException) {
    final statusCode = error.response?.statusCode;
    // 连不上或超时视为离线，UI 展示「网络不可用」。
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return NetworkOfflineException(cause: error);
    }

    // 5xx 单独成类，方便以后做重试/告警；4xx 和其他 Dio 失败走请求错误。
    if (statusCode case final code? when code >= 500) {
      return NetworkServerException(statusCode: code, cause: error);
    }

    return NetworkRequestException(statusCode: statusCode, cause: error);
  }

  // Drift 等非网络异常也收口成请求错误，UI 只认 [AppException]。
  return NetworkRequestException(cause: error);
}
