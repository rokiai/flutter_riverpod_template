import 'package:flutter/material.dart';
import 'package:flutter_riverpod_template/core/theme/app_preview.dart';
import 'package:flutter_riverpod_template/core/theme/app_spacing.dart';
import 'package:flutter_riverpod_template/features/todo/models/todo.dart';
import 'package:flutter_riverpod_template/features/todo/models/todo_state.dart';
import 'package:flutter_riverpod_template/features/todo/widgets/todo_composer.dart';
import 'package:flutter_riverpod_template/features/todo/widgets/todo_filter_bar.dart';
import 'package:flutter_riverpod_template/features/todo/widgets/todo_header.dart';
import 'package:flutter_riverpod_template/features/todo/widgets/todo_tile.dart';
import 'package:flutter_riverpod_template/l10n/app_localizations.dart';

/// 列表页外壳：Scaffold 与最大宽度，不含数据加载。
class TodoPageFrame extends StatelessWidget {
  const TodoPageFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                AppSpacing.large,
                AppSpacing.medium,
                AppSpacing.medium,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// 已加载后的列表内容：下拉刷新、筛选、缓存降级提示。
class TodoView extends StatelessWidget {
  const TodoView({
    required this.state,
    required this.todos,
    required this.filter,
    required this.onAdd,
    required this.onToggle,
    required this.onDelete,
    required this.onClearCompleted,
    required this.onRefresh,
    required this.onFilterChanged,
    super.key,
  });

  final TodoState state;
  final List<Todo> todos;
  final TodoFilter filter;
  final Future<void> Function(String title) onAdd;
  final Future<void> Function(String id) onToggle;
  final Future<void> Function(String id) onDelete;
  final Future<void> Function() onClearCompleted;
  final Future<void> Function() onRefresh;
  final ValueChanged<TodoFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: TodoHeader(
              activeCount: state.activeCount,
              completedCount: state.completedCount,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.large)),
          SliverToBoxAdapter(child: TodoComposer(onSubmit: onAdd)),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.large)),
          SliverToBoxAdapter(
            child: TodoFilterBar(
              activeFilter: filter,
              completedCount: state.completedCount,
              onFilterChanged: onFilterChanged,
              onClearCompleted: onClearCompleted,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.medium)),
          // 当前列表来自本地降级时提示用户，避免误以为已与远端同步。
          if (state.fromCache)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.small),
                child: Text(AppLocalizations.of(context)!.cachedData),
              ),
            ),
          if (todos.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyTodoView(),
            )
          else
            SliverList.separated(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return TodoTile(
                  key: ValueKey(todo.id),
                  todo: todo,
                  onToggle: () => onToggle(todo.id),
                  onDelete: () => onDelete(todo.id),
                );
              },
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.small),
            ),
        ],
      ),
    );
  }
}

/// 当前筛选下没有任务时的空态。
class _EmptyTodoView extends StatelessWidget {
  const _EmptyTodoView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(l10n.noTasks, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xSmall),
          Text(l10n.noTasksHint, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// 整页 Preview 用的假数据。
final previewTodoItems = <Todo>[
  Todo(
    id: 'preview-1',
    title: '评审 Feature-First 边界',
    isCompleted: true,
    createdAt: DateTime(2026, 8, 20),
  ),
  Todo(
    id: 'preview-2',
    title: '给列表页加上 Widget Preview',
    isCompleted: false,
    createdAt: DateTime(2026, 8, 22),
  ),
  Todo(
    id: 'preview-3',
    title: '接入生产 API',
    isCompleted: false,
    createdAt: DateTime(2026, 8, 23),
  ),
  Todo(
    id: 'preview-4',
    title: '补齐仓库单测',
    isCompleted: false,
    createdAt: DateTime(2026, 8, 24),
  ),
  Todo(
    id: 'preview-5',
    title: '整理 PR 说明',
    isCompleted: true,
    createdAt: DateTime(2026, 8, 21),
  ),
];

/// 整页「有数据」Preview。假数据，不走 Controller。
@AppPreview(name: '有数据', group: 'todo', page: true)
Widget previewTodoViewLoaded() {
  const filter = TodoFilter.all;
  final state = TodoState(
    items: previewTodoItems,
    fromCache: false,
    lastSyncedAt: DateTime(2026, 8, 25, 14, 30),
  );
  return TodoPageFrame(
    child: TodoView(
      state: state,
      todos: state.visibleItems(filter),
      filter: filter,
      onAdd: (_) async {},
      onToggle: (_) async {},
      onDelete: (_) async {},
      onClearCompleted: () async {},
      onRefresh: () async {},
      onFilterChanged: (_) {},
    ),
  );
}
