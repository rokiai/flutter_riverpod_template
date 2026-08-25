import 'package:flutter_riverpod_template/routing/routes/todo_routes.dart'
    as todo_routes;
import 'package:go_router/go_router.dart';

export 'routes/todo_routes.dart' show TodoRoute;

/// 应用全部路由表。
///
/// 新 Feature 在 `routes/<name>_routes.dart` 声明后，把生成的 `$appRoutes` 展开进来。
final appRoutes = <RouteBase>[...todo_routes.$appRoutes];

/// 启动后的初始路径。
final appInitialLocation = const todo_routes.TodoRoute().location;
