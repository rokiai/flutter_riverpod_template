import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_template/features/todo/data/todo_repository.dart';
import 'package:flutter_riverpod_template/features/todo/models/todo.dart';
import 'package:flutter_riverpod_template/features/todo/models/todo_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'todo_controller.g.dart';

/// Todo 页面状态：加载列表并响应增删改。
@riverpod
class TodoController extends _$TodoController {
  TodoRepository get _repository => ref.read(todoRepositoryProvider);

  @override
  Future<TodoState> build() => _load();

  /// 把 Repository 结果映射成页面状态（含是否缓存降级）。
  Future<TodoState> _load() async {
    final result = await _repository.getTodos();
    return TodoState(
      items: result.items,
      fromCache: result.fromCache,
      lastSyncedAt: result.syncedAt,
    );
  }

  /// 从远端重新拉取列表（失败时 Repository 可回退缓存）。
  Future<void> refresh() async {
    await _run((_) => _load());
  }

  /// 新增一条任务；空白标题会被忽略。
  Future<void> addTodo(String rawTitle) async {
    final title = rawTitle.trim();
    // 空白不是合法任务，不打远端，避免产生空记录。
    if (title.isEmpty) {
      return;
    }

    await _run((previous) async {
      final todo = await _repository.createTodo(title);
      final current = previous ?? TodoState();
      // 新任务插到列表头，并标记为刚同步成功（不再是缓存降级）。
      return TodoState(
        items: <Todo>[todo, ...current.items],
        fromCache: false,
        lastSyncedAt: DateTime.now(),
      );
    });
  }

  /// 切换指定任务的完成状态。
  Future<void> toggleTodo(String id) async {
    await _run((previous) async {
      final current = previous ?? TodoState();
      final todo = _findTodo(current, id);
      // 并发删除或列表已变时不再打接口。
      if (todo == null) {
        return current;
      }

      final updated = await _repository.updateTodo(
        todo.copyWith(isCompleted: !todo.isCompleted),
      );
      return TodoState(
        items: current.items
            .map((item) => item.id == updated.id ? updated : item)
            .toList(growable: false),
        fromCache: false,
        lastSyncedAt: DateTime.now(),
      );
    });
  }

  /// 删除指定任务。
  Future<void> deleteTodo(String id) async {
    await _run((previous) async {
      final current = previous ?? TodoState();
      await _repository.deleteTodo(id);
      return TodoState(
        items: current.items
            .where((todo) => todo.id != id)
            .toList(growable: false),
        fromCache: false,
        lastSyncedAt: DateTime.now(),
      );
    });
  }

  /// 删除所有已完成任务。
  Future<void> clearCompleted() async {
    await _run((previous) async {
      final current = previous ?? TodoState();
      final completed = current.items.where((todo) => todo.isCompleted);
      // Mock/真实 API 都没有批量删除，逐条删以保持缓存与远端一致。
      for (final todo in completed) {
        await _repository.deleteTodo(todo.id);
      }
      return TodoState(
        items: current.items
            .where((todo) => !todo.isCompleted)
            .toList(growable: false),
        fromCache: false,
        lastSyncedAt: DateTime.now(),
      );
    });
  }

  /// 一次写操作：先进入 loading，再用 [AsyncValue.guard] 收口成功/失败。
  Future<void> _run(
    Future<TodoState> Function(TodoState? previous) operation,
  ) async {
    final previous = state;
    state = const AsyncLoading<TodoState>();

    final next = await AsyncValue.guard(() => operation(previous.value));
    // 页面已销毁时不要再写 state，避免 Riverpod 报错。
    if (!ref.mounted) {
      return;
    }
    state = next;
  }

  /// 按 id 查找当前列表项；找不到返回 null。
  Todo? _findTodo(TodoState state, String id) {
    for (final todo in state.items) {
      if (todo.id == id) {
        return todo;
      }
    }
    return null;
  }
}

/// 列表筛选条件（全部 / 未完成 / 已完成）。
class TodoFilterController extends Notifier<TodoFilter> {
  @override
  TodoFilter build() => TodoFilter.all;

  /// 更新当前筛选。
  void setFilter(TodoFilter filter) {
    state = filter;
  }
}

/// 列表筛选状态。
final todoFilterProvider = NotifierProvider<TodoFilterController, TodoFilter>(
  TodoFilterController.new,
);

/// 当前筛选下可见的任务列表。
final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final todoState = ref.watch(todoControllerProvider).value;
  final filter = ref.watch(todoFilterProvider);
  // loading/error 时 value 为空，给空列表让 UI 不必再判空。
  return todoState?.visibleItems(filter) ?? const <Todo>[];
});
