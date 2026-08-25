import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_riverpod_template/core/network/interceptors.dart';
import 'package:flutter_riverpod_template/core/utils/logger.dart';

/// 全局 Dio 实例。超时和日志策略集中在这里。
final dioClientProvider = Provider<DioClient>((ref) {
  final talker = ref.watch(appTalkerProvider);
  // 超时和 baseUrl 只在这里改；Feature 不要各自 new Dio。
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.example.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: const {'accept': 'application/json'},
    ),
  )..interceptors.add(createNetworkLogger(talker));

  ref.onDispose(dio.close);
  return DioClient(dio);
});

/// Dio 包装，避免 Feature 直接依赖裸 [Dio] 配置。
final class DioClient {
  const DioClient(this.dio);

  final Dio dio;
}
