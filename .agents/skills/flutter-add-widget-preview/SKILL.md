---
name: flutter-add-widget-preview
description: >-
  Adds Widget Preview for Screen-extracted View widgets in this repository.
  Do not add previews on *Screen or on child widgets (tiles, bars, common_widgets).
---

# Widget Preview

只给 **Screen 抽离出来的 View** 加 `@AppPreview`（见 `todo_view.dart` 的 `TodoView`）。`*Screen`、tile / header / 输入条等子组件、`common_widgets` **不要**加 Preview。

本仓库用 `@AppPreview`（`lib/core/theme/app_preview.dart`），不要写裸 `@Preview`。不要给 `AppPreview` 加命名构造或自定义字段。

## VS Code / Cursor 怎么打开

1. 安装官方 Dart + Flutter 扩展，Flutter SDK ≥ 3.47。
2. 打开仓库后，点活动栏 **Flutter Widget Preview**。没有该页签时，命令面板运行 `Flutter: Enable Widget Previews`。
3. 打开 View 文件。预览器底部打开 **Filter previews by selected file**。
4. 改 widget 会自动刷新。静态初始化变了点右下角全局 hot restart。
5. 命令行：`flutter widget-preview start`。缓存目录 `.widget_preview/` 已 gitignore。

## 怎么加

- [ ] Preview 写在 View **同文件**（画布 375×812 由 `AppPreview` 注入），假数据 / 空回调。
- [ ] `*Screen` 不预览（会带入 Controller / Drift）。
- [ ] 子组件不预览，整页 View 里已经能看到它们。

```dart
@AppPreview(name: '有数据', group: 'todo')
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

## 限制

- 预览器是 Web：原生插件、`dart:io` / `dart:ffi` 会抛错。
- 体积门禁不计 Widget Preview 代码。
- 注解参数必须是 compile-time constant，且只能用 `Preview` 已有字段（`name` / `group` / `size` 等）。不要写 `page: true`，预览器会把它塞进 `textScaleFactor` 红屏。主题 / wrapper / 375×812 在 `transform()` 里注入。
