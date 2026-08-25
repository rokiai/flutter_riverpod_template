import 'package:flutter/material.dart';
import 'package:flutter_riverpod_template/core/theme/app_preview.dart';
import 'package:flutter_riverpod_template/core/theme/app_spacing.dart';
import 'package:flutter_riverpod_template/features/todo/models/todo.dart';
import 'package:flutter_riverpod_template/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// 一条 Todo 的展示与完成/删除操作。
class TodoTile extends StatelessWidget {
  const TodoTile({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    super.key,
  });

  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      // 已完成任务划掉并降对比度，和筛选「已完成」视觉一致。
      decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
      color: todo.isCompleted
          ? theme.colorScheme.onSurfaceVariant
          : theme.colorScheme.onSurface,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.small,
          vertical: AppSpacing.xSmall,
        ),
        child: Row(
          children: [
            Checkbox(
              value: todo.isCompleted,
              onChanged: (_) => onToggle(),
              semanticLabel: todo.isCompleted
                  ? l10n.markTodoActive(todo.title)
                  : l10n.markTodoCompleted(todo.title),
            ),
            const SizedBox(width: AppSpacing.xSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(todo.title, style: titleStyle),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.yMMMd(
                      Localizations.localeOf(context).toLanguageTag(),
                    ).format(todo.createdAt),
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.deleteTodo(todo.title),
              onPressed: onDelete,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}

@AppPreview(name: '未完成', group: 'todo')
Widget previewTodoTileActive() {
  return TodoTile(
    todo: Todo(
      id: 'preview-1',
      title: 'Review widget previews',
      isCompleted: false,
      createdAt: DateTime(2026, 8, 20),
    ),
    onToggle: () {},
    onDelete: () {},
  );
}

@AppPreview(name: '已完成', group: 'todo')
Widget previewTodoTileCompleted() {
  return TodoTile(
    todo: Todo(
      id: 'preview-2',
      title: 'Connect the production API',
      isCompleted: true,
      createdAt: DateTime(2026, 8, 18),
    ),
    onToggle: () {},
    onDelete: () {},
  );
}
