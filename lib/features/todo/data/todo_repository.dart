import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_riverpod_template/core/network/network_error_handler.dart';
import 'package:flutter_riverpod_template/core/storage/database_provider.dart';
import 'package:flutter_riverpod_template/features/todo/data/todo_local_data_source.dart';
import 'package:flutter_riverpod_template/features/todo/data/todo_remote_data_source.dart';
import 'package:flutter_riverpod_template/features/todo/models/todo.dart';

/// Todo 远端数据源。默认注入内存 Mock；接真实 API 时换成 [DioTodoRemoteDataSource]。
final todoRemoteDataSourceProvider = Provider<TodoRemoteDataSource>((ref) {
  return MockTodoRemoteDataSource();
});

/// Todo 数据层出口：编排远端、本地缓存和错误归一化。
final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository(
    remote: ref.watch(todoRemoteDataSourceProvider),
    local: DriftTodoLocalDataSource(ref.watch(appDatabaseProvider)),
  );
});

/// Todo Feature 的数据层唯一出口。
final class TodoRepository {
  const TodoRepository({required this.remote, required this.local});

  final TodoRemoteDataSource remote;
  final TodoLocalDataSource local;

  /// 优先拉远端并写入缓存；远端失败且有缓存时回退本地。
  Future<TodoLoadResult> getTodos() async {
    try {
      final todos = await remote.fetchTodos();
      await local.saveTodos(todos);
      return TodoLoadResult(
        items: todos,
        fromCache: false,
        syncedAt: DateTime.now(),
      );
    } on Object catch (error, stackTrace) {
      // 有缓存就降级展示，让离线/超时仍能看列表；没有缓存才把错误抛给 UI。
      final cachedTodos = await local.readTodos();
      if (cachedTodos != null) {
        return TodoLoadResult(
          items: cachedTodos,
          fromCache: true,
          syncedAt: null,
        );
      }
      Error.throwWithStackTrace(normalizeError(error), stackTrace);
    }
  }

  /// 创建任务并更新本地缓存快照。
  Future<Todo> createTodo(String title) {
    return _runMutation(() async {
      final todo = await remote.createTodo(title);
      // 用「当前快照 + 新任务」整表覆盖，避免缓存只剩这一条。
      final current = await _readCachedOrRemote();
      await local.saveTodos(<Todo>[todo, ...current]);
      return todo;
    });
  }

  /// 更新任务并同步缓存。
  Future<Todo> updateTodo(Todo todo) {
    return _runMutation(() async {
      final updated = await remote.updateTodo(todo);
      final current = await _readCachedOrRemote();
      final next = current
          .map((item) => item.id == updated.id ? updated : item)
          .toList(growable: false);
      await local.saveTodos(next);
      return updated;
    });
  }

  /// 删除任务并同步缓存。
  Future<void> deleteTodo(String id) {
    return _runMutation(() async {
      await remote.deleteTodo(id);
      final current = await _readCachedOrRemote();
      await local.saveTodos(
        current.where((todo) => todo.id != id).toList(growable: false),
      );
    });
  }

  /// 写缓存前优先用本地快照；缓存空则再拉远端，避免覆盖成不完整列表。
  Future<List<Todo>> _readCachedOrRemote() async {
    final cached = await local.readTodos();
    if (cached != null) {
      return cached;
    }
    return remote.fetchTodos();
  }

  /// 写操作统一归一成 [AppException]，Controller 不再处理 Dio/Drift 细节。
  Future<T> _runMutation<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(normalizeError(error), stackTrace);
    }
  }
}

/// 一次列表加载的结果：数据、是否来自缓存、最近成功同步时间。
final class TodoLoadResult {
  const TodoLoadResult({
    required this.items,
    required this.fromCache,
    required this.syncedAt,
  });

  /// 本次列表数据。
  final List<Todo> items;

  /// true 表示远端失败后回退了本地缓存。
  final bool fromCache;

  /// 最近一次远端成功同步时间；走缓存时为 null。
  final DateTime? syncedAt;
}
