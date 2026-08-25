import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_template/core/theme/app_theme.dart';
import 'package:flutter_riverpod_template/l10n/app_localizations.dart';

/// 本仓库默认 Widget Preview：注入 [AppTheme]、中文 l10n 和 [ProviderScope]。
///
/// 画布固定 375×812，不加组件 Padding。Preview 只写在 Screen 抽离出的 View 上，用假数据；
/// `*Screen` 和子组件不加。
///
/// 主题和 wrapper 在 [transform] 里注入。预览器只对 [Preview] 已有的简单常量参数做常量求值；
/// 不要加自定义字段或命名构造——例如 `page: true` 会被塞进 [Preview.textScaleFactor] 导致红屏。
final class AppPreview extends Preview {
  /// 整页预览画布：375 宽 × iPhone X 高度。
  static const Size pageSize = Size(375, 812);

  const AppPreview({
    super.name,
    super.group = 'app',
    super.size,
    super.textScaleFactor,
    super.brightness,
  });

  @override
  Preview transform() {
    final builder = super.transform().toBuilder()
      ..theme = AppPreview.themeBuilder
      ..localizations = AppPreview.localizationsBuilder
      ..wrapper = AppPreview.wrap;
    builder.size ??= AppPreview.pageSize;
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
