import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_riverpod_template/common_widgets/app_error_view.dart';
import 'package:flutter_riverpod_template/common_widgets/loading_view.dart';
import 'package:flutter_riverpod_template/features/todo/todo_controller.dart';
import 'package:flutter_riverpod_template/features/todo/widgets/todo_view.dart';

/// Todo 列表页：只监听 [TodoController] 并分发用户操作。
///
/// 整页 Preview 写在 [TodoView]，避免本文件带入 Drift 导致预览器判定依赖出错。
class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(todoControllerProvider);
    final filter = ref.watch(todoFilterProvider);
    final todos = ref.watch(filteredTodosProvider);
    final controller = ref.read(todoControllerProvider.notifier);

    return TodoPageFrame(
      child: state.when(
        loading: () => const LoadingView(),
        error: (error, _) =>
            AppErrorView(error: error, onRetry: controller.refresh),
        // Screen 只把回调交给子组件，不在这里做 IO。
        data: (todoState) => TodoView(
          state: todoState,
          todos: todos,
          filter: filter,
          onAdd: controller.addTodo,
          onToggle: controller.toggleTodo,
          onDelete: controller.deleteTodo,
          onClearCompleted: controller.clearCompleted,
          onRefresh: controller.refresh,
          onFilterChanged: (nextFilter) {
            ref.read(todoFilterProvider.notifier).setFilter(nextFilter);
          },
        ),
      ),
    );
  }
}
