import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 淡入的路由过渡页。
class FadeTransitionPage<T> extends CustomTransitionPage<T> {
  FadeTransitionPage({required super.key, required super.child})
    : super(
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
}
