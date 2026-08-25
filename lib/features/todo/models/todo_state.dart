import 'package:flutter_riverpod_template/features/todo/models/todo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_state.freezed.dart';

/// 列表筛选：全部 / 未完成 / 已完成。
enum TodoFilter { all, active, completed }

/// Todo 页面的不可变 UI 状态。
@freezed
abstract class TodoState with _$TodoState {
  const factory TodoState({
    /// 全量列表；筛选在 [visibleItems] 里做，不在 Controller 里另存一份。
    @Default(<Todo>[]) List<Todo> items,

    /// 当前数据是否来自本地降级。
    @Default(false) bool fromCache,

    /// 最近一次远端成功同步时间；缓存降级时为 null。
    DateTime? lastSyncedAt,
  }) = _TodoState;

  const TodoState._();

  /// 已完成数量。
  int get completedCount => items.where((todo) => todo.isCompleted).length;

  /// 未完成数量。
  int get activeCount => items.length - completedCount;

  /// 按 [filter] 返回当前可见任务。
  List<Todo> visibleItems(TodoFilter filter) {
    return switch (filter) {
      TodoFilter.all => items,
      TodoFilter.active =>
        items.where((todo) => !todo.isCompleted).toList(growable: false),
      TodoFilter.completed =>
        items.where((todo) => todo.isCompleted).toList(growable: false),
    };
  }
}
