import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_template/app.dart';

/// 应用入口：初始化绑定并在 [ProviderScope] 中启动 [App]。
Future<void> main() async {
  // 使用插件 / 路径前必须先绑定，即使当前入口还没有异步初始化。
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ProviderScope(child: App()));
}
