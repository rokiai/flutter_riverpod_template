import 'package:flutter/material.dart';

import 'package:flutter_riverpod_template/core/theme/app_colors.dart';
import 'package:flutter_riverpod_template/core/theme/app_text_styles.dart';

/// 亮色/暗色 [ThemeData]。
abstract final class AppTheme {
  /// 亮色主题。
  static ThemeData get light => _build(Brightness.light);

  /// 暗色主题。
  static ThemeData get dark => _build(Brightness.dark);

  /// 用种子色生成 ColorScheme，再覆盖品牌主色和表面色。
  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final baseScheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: brightness,
    );
    final scheme = baseScheme.copyWith(
      primary: AppColors.teal,
      onPrimary: Colors.white,
      secondary: AppColors.coral,
      onSecondary: Colors.white,
      tertiary: AppColors.mustard,
      surface: isLight ? AppColors.surface : AppColors.darkSurface,
      surfaceContainer: isLight ? AppColors.canvas : AppColors.darkCanvas,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surfaceContainer,
      textTheme: AppTextStyles.textTheme(scheme),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surfaceContainer,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.teal, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
    );
  }
}
