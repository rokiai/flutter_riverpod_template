---
name: flutter-add-widget-preview
description: >-
  Adds Widget Preview annotations in this repository. Use when creating or
  updating Screen children, common_widgets, or any user-visible Flutter widget
  that should render in the VS Code / Cursor Flutter Widget Preview tab.
---

# Widget Preview

本仓库用自定义 `@AppPreview`（`lib/core/theme/app_preview.dart`），不要直接写裸 `@Preview`。它会注入 `AppTheme`、中文 l10n 和 `ProviderScope`。

## VS Code / Cursor 怎么打开

1. 安装官方 Dart + Flutter 扩展，Flutter SDK ≥ 3.47。
2. 打开仓库后，点活动栏 **Flutter Widget Preview**。没有该页签时，命令面板运行 `Flutter: Enable Widget Previews`。
3. 打开组件文件。预览器底部打开 **Filter previews by selected file**，只看当前文件。
4. 改 widget 会自动刷新。静态初始化变了点右下角全局 hot restart；单个卡片点卡片上的 restart。
5. 也可用命令行：`flutter widget-preview start`（浏览器）。缓存目录 `.widget_preview/` 已 gitignore。

## 给组件加预览

- [ ] `import 'package:flutter_riverpod_template/core/theme/app_preview.dart';`
- [ ] 预览写在**组件同文件**（方便按文件过滤）。
- [ ] 无必填参数：把 `@AppPreview` 标在公开构造上（见 `LoadingView`）。
- [ ] 有必填参数：写公开顶层函数 `previewXxx()`，函数体内填假数据 / 空回调。
- [ ] 设 `name`、`group`（`common` / Feature 名）。默认宽 375，一般不用传 `size`。
- [ ] `*Screen` 不要加 Preview（会带入 Drift）。整页用 `@AppPreview(..., page: true)` 挂在纯 UI widget 上，塞假数据（见 `todo_view.dart`）。不要给 `AppPreview` 加命名构造。

## 限制

- 预览器是 Web：原生插件、`dart:io` / `dart:ffi` 调用会抛错。
- 体积门禁不计 Widget Preview：`@AppPreview`、`previewXxx()`、Preview 假数据、`app_preview.dart` / `*_preview.dart`。
- 注解参数必须是 compile-time constant。`AppPreview` 的主题 / wrapper 在 `transform()` 里注入，注解上只放 `name` / `group` / `page` 这类简单常量。
- 不要给 `AppPreview` 写命名构造（如 `.page`）：预览器 `computeConstantValue()` 失败会直接跳过，整份 Preview 列表可能变成空的。
- 资源走 package 路径：`packages/flutter_riverpod_template/...`。

## 示例

无必填参数：

```dart
@AppPreview(name: '加载', group: 'common')
const LoadingView({super.key});
```

有必填参数：

```dart
@AppPreview(name: '未完成', group: 'todo')
Widget previewTodoTileActive() {
  return TodoTile(
    todo: Todo(
      id: 'preview-1',
      title: 'Review widget previews',
      isCompleted: false,
      createdAt: DateTime(2026, 8, 20),
    ),
    onToggle: () {},
    onDelete: () {},
  );
}
```

现成例子：`lib/features/todo/widgets/`、`lib/common_widgets/`。整页见 `todo_view.dart`。

整页：

```dart
@AppPreview(name: '有数据', group: 'todo', page: true)
Widget previewTodoViewLoaded() {
  return TodoPageFrame(
    child: TodoView(
      state: TodoState(items: previewTodoItems),
      todos: previewTodoItems,
      filter: TodoFilter.all,
      onAdd: (_) async {},
      onToggle: (_) async {},
      onDelete: (_) async {},
      onClearCompleted: () async {},
      onRefresh: () async {},
      onFilterChanged: (_) {},
    ),
  );
}
```
