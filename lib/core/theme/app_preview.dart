import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_template/core/theme/app_spacing.dart';
import 'package:flutter_riverpod_template/core/theme/app_theme.dart';
import 'package:flutter_riverpod_template/l10n/app_localizations.dart';

/// 本仓库默认 Widget Preview：注入 [AppTheme]、中文 l10n 和 [ProviderScope]。
///
/// 组件默认宽 375，高度由内容撑开。整页传 [page]：画布 375×812，且不加组件 Padding。
/// Preview 写在不依赖 Controller / Drift 的 widget 上，用假数据。
///
/// 主题和 wrapper 在 [transform] 里注入，不写进构造。预览器只对简单常量参数做常量求值，
/// 自定义命名构造（例如 `AppPreview.page`）会被直接跳过。
final class AppPreview extends Preview {
  /// 移动端设计稿宽度。
  static const Size mobileSize = Size.fromWidth(375);

  /// 整页预览画布：375 宽 × iPhone X 高度。
  static const Size pageSize = Size(375, 812);

  const AppPreview({
    super.name,
    super.group = 'app',
    super.size,
    super.textScaleFactor,
    super.brightness,
    this.page = false,
  });

  /// 为 true 时用整页画布和 [wrapPage]。
  final bool page;

  @override
  Preview transform() {
    final builder = super.transform().toBuilder()
      ..theme = AppPreview.themeBuilder
      ..localizations = AppPreview.localizationsBuilder
      ..wrapper = page ? AppPreview.wrapPage : AppPreview.wrap;
    builder.size ??= page ? AppPreview.pageSize : AppPreview.mobileSize;
    return builder.build();
  }

  static PreviewThemeData themeBuilder() => const AppPreviewThemeData();

  static PreviewLocalizationsData localizationsBuilder() {
    return const PreviewLocalizationsData(
      locale: Locale('zh'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }

  /// ConsumerWidget 需要 [ProviderScope]；预览器本身不提供。
  static Widget wrap(Widget child) {
    return ProviderScope(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: child,
      ),
    );
  }

  /// 整页 Preview：只有 [ProviderScope]，不加组件 Padding。
  static Widget wrapPage(Widget child) {
    return ProviderScope(child: child);
  }
}

/// 按预览器当前亮度套上 [AppTheme]，保证和真机主题一致。
final class AppPreviewThemeData extends PreviewThemeData {
  const AppPreviewThemeData();

  @override
  Widget apply(BuildContext context, Widget child) {
    final brightness =
        MediaQuery.maybeOf(context)?.platformBrightness ??
        Theme.of(context).brightness;
    final theme = brightness == Brightness.dark
        ? AppTheme.dark
        : AppTheme.light;
    return Theme(
      data: theme,
      child: ColoredBox(color: theme.scaffoldBackgroundColor, child: child),
    );
  }
}
