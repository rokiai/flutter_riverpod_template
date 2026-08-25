import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_template/core/storage/app_database.dart';
import 'package:flutter_riverpod_template/core/storage/database_provider.dart';
import 'package:flutter_riverpod_template/features/todo/data/todo_remote_data_source.dart';
import 'package:flutter_riverpod_template/features/todo/data/todo_repository.dart';
import 'package:flutter_riverpod_template/features/todo/models/todo.dart';

/// 测试用 [ProviderContainer]：内存 Drift + 可注入的 Mock 远端。
ProviderContainer createTestContainer({
  List<Todo> seed = const <Todo>[],
  AppDatabase? database,
  MockTodoRemoteDataSource? remote,
}) {
  return ProviderContainer(
    overrides: [
      // 默认内存库；调用方传入 database 时由调用方负责 close。
      appDatabaseProvider.overrideWith((ref) {
        final testDatabase = database ?? AppDatabase(NativeDatabase.memory());
        if (database == null) {
          ref.onDispose(testDatabase.close);
        }
        return testDatabase;
      }),
      todoRemoteDataSourceProvider.overrideWithValue(
        remote ??
            // 测试关掉 Mock 延迟，避免 widget/unit 测试被 160ms 拖慢。
            MockTodoRemoteDataSource(seed: seed, responseDelay: Duration.zero),
      ),
    ],
  );
}
