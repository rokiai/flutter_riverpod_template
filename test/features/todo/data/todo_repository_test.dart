import 'package:drift/native.dart';
import 'package:flutter_riverpod_template/core/error/app_exception.dart';
import 'package:flutter_riverpod_template/core/storage/app_database.dart';
import 'package:flutter_riverpod_template/features/todo/data/todo_local_data_source.dart';
import 'package:flutter_riverpod_template/features/todo/data/todo_remote_data_source.dart';
import 'package:flutter_riverpod_template/features/todo/data/todo_repository.dart';
import 'package:flutter_riverpod_template/features/todo/models/todo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final seed = Todo(
    id: 'todo-1',
    title: 'Write tests',
    isCompleted: false,
    createdAt: DateTime(2026, 8, 23),
  );

  test('loads from remote and persists a cache snapshot', () async {
    // 成功路径：远端数据要落到 Drift，供后续离线读取。
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = TodoRepository(
      remote: MockTodoRemoteDataSource(
        seed: <Todo>[seed],
        responseDelay: Duration.zero,
      ),
      local: DriftTodoLocalDataSource(database),
    );

    final result = await repository.getTodos();

    expect(result.items, <Todo>[seed]);
    expect(result.fromCache, isFalse);
    expect(await DriftTodoLocalDataSource(database).readTodos(), <Todo>[seed]);
  });

  test('falls back to cached data when remote loading fails', () async {
    // 先写入缓存再让远端失败，验证降级而不是抛错。
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final local = DriftTodoLocalDataSource(database);
    await local.saveTodos(<Todo>[seed]);
    final remote = MockTodoRemoteDataSource(responseDelay: Duration.zero)
      ..shouldFail = true;
    final repository = TodoRepository(remote: remote, local: local);

    final result = await repository.getTodos();

    expect(result.items, <Todo>[seed]);
    expect(result.fromCache, isTrue);
  });

  test(
    'distinguishes an explicitly cached empty snapshot from no cache',
    () async {
      // 空列表也是合法缓存：不能把「缓存了 0 条」当成「从未缓存」。
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final local = DriftTodoLocalDataSource(database);
      await local.saveTodos(const <Todo>[]);
      final remote = MockTodoRemoteDataSource(responseDelay: Duration.zero)
        ..shouldFail = true;
      final repository = TodoRepository(remote: remote, local: local);

      final result = await repository.getTodos();

      expect(result.items, isEmpty);
      expect(result.fromCache, isTrue);
    },
  );

  test('throws a normalized network error without cached data', () async {
    // 从未写入过 metadata 时，失败必须抛 [NetworkOfflineException]。
    final remote = MockTodoRemoteDataSource(responseDelay: Duration.zero)
      ..shouldFail = true;
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = TodoRepository(
      remote: remote,
      local: DriftTodoLocalDataSource(database),
    );

    expect(repository.getTodos, throwsA(isA<NetworkOfflineException>()));
  });

  test('memory cache works as the Widget Preview fallback', () async {
    final repository = TodoRepository(
      remote: MockTodoRemoteDataSource(responseDelay: Duration.zero)
        ..shouldFail = true,
      local: MemoryTodoLocalDataSource(cached: <Todo>[seed]),
    );

    final result = await repository.getTodos();

    expect(result.items, <Todo>[seed]);
    expect(result.fromCache, isTrue);
  });
}
