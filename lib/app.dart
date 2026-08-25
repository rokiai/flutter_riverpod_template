import 'package:flutter/material.dart';
import 'package:flutter_riverpod_template/core/theme/app_theme.dart';
import 'package:flutter_riverpod_template/l10n/app_localizations.dart';
import 'package:flutter_riverpod_template/routing/app_router.dart';
import 'package:go_router/go_router.dart';

/// 根 Widget：装配主题、本地化和路由，不包含业务逻辑。
class App extends StatelessWidget {
  /// [router] 仅测试注入；产品路径走默认 [appRouter]。
  App({GoRouter? router, super.key}) : router = router ?? appRouter;

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
