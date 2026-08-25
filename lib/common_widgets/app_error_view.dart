import 'package:flutter/material.dart';
import 'package:flutter_riverpod_template/core/error/app_exception.dart';
import 'package:flutter_riverpod_template/core/network/network_error_handler.dart';
import 'package:flutter_riverpod_template/core/theme/app_spacing.dart';
import 'package:flutter_riverpod_template/l10n/app_localizations.dart';

/// 错误态：把异常归一后展示本地化文案，并提供重试。
class AppErrorView extends StatelessWidget {
  const AppErrorView({required this.error, required this.onRetry, super.key});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    // 先归一再映射 l10n，避免 UI 直接读 Dio/Drift 原文。
    final errorMessage = switch (normalizeError(error)) {
      NetworkOfflineException() => l10n.networkOffline,
      NetworkServerException() => l10n.networkServer,
      _ => l10n.networkRequest,
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.medium),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
