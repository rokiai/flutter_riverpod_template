import 'package:drift/drift.dart';
import 'package:flutter_riverpod_template/core/storage/app_database.dart';
import 'package:flutter_riverpod_template/core/utils/logger.dart';
import 'package:flutter_riverpod_template/features/todo/models/todo.dart';

/// Todo 本地缓存契约。Drift 实现给 App；内存实现给 Widget Preview。
abstract interface class TodoLocalDataSource {
  /// 读取缓存快照；无缓存或读失败时返回 null。
  Future<List<Todo>?> readTodos();

  /// 覆盖写入缓存。
  Future<void> saveTodos(List<Todo> todos);
}

/// Drift 读写与领域模型映射。
final class DriftTodoLocalDataSource implements TodoLocalDataSource {
  const DriftTodoLocalDataSource(this.database);

  final AppDatabase database;

  @override
  Future<List<Todo>?> readTodos() async {
    try {
      final metadata = await (database.select(
        database.todoCacheMetadata,
      )..limit(1)).getSingleOrNull();
      // 没有 metadata 视为从未成功写入过，空表不能当成合法快照。
      if (metadata == null) {
        return null;
      }

      final query = database.select(database.todoEntries)
        ..orderBy([(entry) => OrderingTerm.asc(entry.sortOrder)]);
      final rows = await query.get();
      return List<Todo>.unmodifiable(
        rows.map(
          (row) => Todo(
            id: row.id,
            title: row.title,
            isCompleted: row.isCompleted,
            createdAt: row.createdAt,
          ),
        ),
      );
    } on Object catch (error, stackTrace) {
      // 读缓存失败等同于「没有缓存」，让 Repository 决定抛错还是继续。
      AppLogger.error(
        'Unable to read cached tasks.',
        error: error,
        stackTrace: stackTrace,
        name: 'todo.cache',
      );
      return null;
    }
  }

  @override
  Future<void> saveTodos(List<Todo> todos) async {
    try {
      await database.transaction(() async {
        // 整表替换，避免增量同步漏删；sortOrder 用列表下标固定展示顺序。
        await database.delete(database.todoEntries).go();
        await database.batch((batch) {
          batch.insertAll(
            database.todoEntries,
            todos.indexed
                .map(
                  (item) => TodoEntriesCompanion.insert(
                    id: item.$2.id,
                    title: item.$2.title,
                    isCompleted: item.$2.isCompleted,
                    createdAt: item.$2.createdAt,
                    sortOrder: item.$1,
                  ),
                )
                .toList(growable: false),
          );
        });
        await database
            .into(database.todoCacheMetadata)
            .insertOnConflictUpdate(
              TodoCacheMetadataCompanion.insert(
                id: const Value(1),
                savedAt: DateTime.now(),
              ),
            );
      });
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'Unable to persist cached tasks.',
        error: error,
        stackTrace: stackTrace,
        name: 'todo.cache',
      );
    }
  }
}

/// 内存缓存。Widget Preview 跑在 Web，不能开 Drift 文件/FFI。
final class MemoryTodoLocalDataSource implements TodoLocalDataSource {
  MemoryTodoLocalDataSource({List<Todo>? cached})
    : _snapshot = cached == null ? null : List<Todo>.of(cached);

  List<Todo>? _snapshot;

  @override
  Future<List<Todo>?> readTodos() async {
    final snapshot = _snapshot;
    if (snapshot == null) {
      return null;
    }
    return List<Todo>.unmodifiable(snapshot);
  }

  @override
  Future<void> saveTodos(List<Todo> todos) async {
    _snapshot = List<Todo>.of(todos);
  }
}
