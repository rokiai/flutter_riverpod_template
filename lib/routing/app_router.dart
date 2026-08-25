import 'package:flutter/material.dart';
import 'package:flutter_riverpod_template/l10n/app_localizations.dart';
import 'package:flutter_riverpod_template/routing/routes.dart';
import 'package:go_router/go_router.dart';

/// 应用级 GoRouter：聚合业务路由并处理未知路径。
final appRouter = GoRouter(
  initialLocation: appInitialLocation,
  routes: appRoutes,
  // 未知 path 不抛到框架，给用户一条回首页的路。
  errorBuilder: (_, _) => const _RouterErrorView(),
);

/// 未知路由时的兜底页。
final class _RouterErrorView extends StatelessWidget {
  const _RouterErrorView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.navigationError),
      ),
      body: Center(
        child: FilledButton.icon(
          onPressed: () => context.go(appInitialLocation),
          icon: const Icon(Icons.home_outlined),
          label: Text(AppLocalizations.of(context)!.backToStart),
        ),
      ),
    );
  }
}
