import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_riverpod_template/core/storage/app_database.dart';

/// 默认 Drift 数据库。测试通过 override 注入内存库。
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase.defaults();
  // Provider 销毁时关掉文件句柄，测试 override 内存库时同样适用。
  ref.onDispose(database.close);
  return database;
});
