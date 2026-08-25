import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 滑入方向。
enum SlideDirection { right, left, up, down }

/// 水平/垂直滑入的路由过渡页。
class SlideTransitionPage<T> extends CustomTransitionPage<T> {
  SlideTransitionPage({
    required super.key,
    required super.child,
    SlideDirection direction = SlideDirection.left,
  }) : super(
         transitionDuration: const Duration(milliseconds: 280),
         reverseTransitionDuration: const Duration(milliseconds: 280),
         transitionsBuilder: (_, animation, _, child) {
           final curvedAnimation = CurvedAnimation(
             parent: animation,
             curve: Curves.easeOutCubic,
             reverseCurve: Curves.easeInCubic,
           );

           return SlideTransition(
             position: Tween<Offset>(
               begin: _slideOffset(direction),
               end: Offset.zero,
             ).animate(curvedAnimation),
             child: child,
           );
         },
       );
}

/// 入场前的偏移：left 表示从右侧滑入（常见 push）。
Offset _slideOffset(SlideDirection direction) {
  return switch (direction) {
    SlideDirection.right => const Offset(-1, 0),
    SlideDirection.left => const Offset(1, 0),
    SlideDirection.up => const Offset(0, 1),
    SlideDirection.down => const Offset(0, -1),
  };
}
