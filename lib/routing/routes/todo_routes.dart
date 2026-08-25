import 'package:flutter/material.dart';
import 'package:flutter_riverpod_template/features/todo/todo_screen.dart';
import 'package:flutter_riverpod_template/routing/transitions/slide_transition_page.dart';
import 'package:go_router/go_router.dart';

part 'todo_routes.g.dart';

/// Todo 列表路由（应用首页）。
@TypedGoRoute<TodoRoute>(path: '/', name: 'todo')
class TodoRoute extends GoRouteData with $TodoRoute {
  const TodoRoute();

  @override
  CustomTransitionPage<void> buildPage(
    BuildContext context,
    GoRouterState state,
  ) {
    // 首页用滑入，和其他业务页保持同一套过渡。
    return SlideTransitionPage<void>(
      key: state.pageKey,
      child: const TodoScreen(),
    );
  }
}
