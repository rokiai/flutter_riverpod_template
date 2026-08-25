import 'package:flutter/material.dart';
import 'package:flutter_riverpod_template/core/theme/app_spacing.dart';
import 'package:flutter_riverpod_template/l10n/app_localizations.dart';

/// 列表标题与未完成/已完成统计。
class TodoHeader extends StatelessWidget {
  const TodoHeader({
    required this.activeCount,
    required this.completedCount,
    super.key,
  });

  final int activeCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.todoTitle, style: theme.textTheme.displaySmall),
        const SizedBox(height: AppSpacing.small),
        Text(l10n.todoSubtitle, style: theme.textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.large),
        Row(
          children: [
            _SummaryValue(
              value: activeCount,
              label: l10n.activeTasks,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.large),
            _SummaryValue(
              value: completedCount,
              label: l10n.completedTasks,
              color: theme.colorScheme.secondary,
            ),
          ],
        ),
      ],
    );
  }
}

/// 标题旁的数字 + 标签（未完成 / 已完成）。
class _SummaryValue extends StatelessWidget {
  const _SummaryValue({
    required this.value,
    required this.label,
    required this.color,
  });

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          '$value',
          style: theme.textTheme.headlineSmall?.copyWith(color: color),
        ),
        const SizedBox(width: AppSpacing.xSmall),
        Text(label, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
