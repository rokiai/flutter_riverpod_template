import 'package:flutter/material.dart';

/// 基于 ColorScheme 的文本样式。
abstract final class AppTextStyles {
  /// 按 [colorScheme] 生成 TextTheme。
  static TextTheme textTheme(ColorScheme colorScheme) {
    return TextTheme(
      displaySmall: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 30,
        fontWeight: FontWeight.w800,
        height: 1.1,
      ),
      headlineSmall: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 23,
        fontWeight: FontWeight.w800,
        height: 1.2,
      ),
      titleMedium: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      bodyLarge: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 16,
        height: 1.4,
      ),
      bodyMedium: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: 14,
        height: 1.35,
      ),
      labelLarge: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      labelSmall: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
    );
  }
}
