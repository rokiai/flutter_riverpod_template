import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_template/core/theme/app_preview.dart';
import 'package:flutter_riverpod_template/core/theme/app_spacing.dart';
import 'package:flutter_riverpod_template/features/todo/models/todo_state.dart';
import 'package:flutter_riverpod_template/l10n/app_localizations.dart';

/// 筛选分段按钮，以及清空已完成。
class TodoFilterBar extends ConsumerWidget {
  const TodoFilterBar({
    required this.activeFilter,
    required this.completedCount,
    required this.onFilterChanged,
    required this.onClearCompleted,
    super.key,
  });

  final TodoFilter activeFilter;
  final int completedCount;
  final ValueChanged<TodoFilter> onFilterChanged;
  final VoidCallback onClearCompleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: SegmentedButton<TodoFilter>(
            segments: [
              ButtonSegment(value: TodoFilter.all, label: Text(l10n.all)),
              ButtonSegment(value: TodoFilter.active, label: Text(l10n.active)),
              ButtonSegment(
                value: TodoFilter.completed,
                label: Text(l10n.completed),
              ),
            ],
            selected: <TodoFilter>{activeFilter},
            onSelectionChanged: (selection) {
              onFilterChanged(selection.first);
            },
            showSelectedIcon: false,
          ),
        ),
        if (completedCount > 0) ...[
          const SizedBox(width: AppSpacing.small),
          // 没有已完成项时隐藏，避免空操作入口。
          IconButton(
            tooltip: l10n.clearCompleted,
            onPressed: onClearCompleted,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ],
    );
  }
}

@AppPreview(name: '筛选', group: 'todo')
Widget previewTodoFilterBar() {
  return TodoFilterBar(
    activeFilter: TodoFilter.all,
    completedCount: 2,
    onFilterChanged: (_) {},
    onClearCompleted: () {},
  );
}
