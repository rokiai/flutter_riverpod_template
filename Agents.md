# Flutter Riverpod Template

Feature-First Flutter + Riverpod 脚手架。示例覆盖接口请求、缓存回退、路由、原生桥与测试。

SDK：Flutter 3.47.0+ / Dart 3.13.0+（已验证 3.47.1 / 3.13.1）。

## Agent 前缀校验（动手前必做）

1. **复用顺序**（先检索，再写代码）
   1. 项目已有：`core/`、`shared/`、`common_widgets/`、`pubspec.yaml` 已有依赖、现有 Feature 里可复用的 widgets / Service。
   2. 项目没有：再选 pub.dev 上下载量高、维护活跃的库，并按本仓库分层包一层（插件进 `core/platform/services/`，UI 进 `common_widgets/` 或 Feature `widgets/`）。
   3. 仍没有：才自研。禁止重复实现项目里已经有的能力。
2. **体积**：单文件有效代码行 ≤ 500（不含 `import` / `export` / `part` / `package`、注释、空行）。生成物与 Widget Preview（`@AppPreview`、`previewXxx`、假数据、`app_preview.dart`）不计。超了按白名单拆，禁止为过关删注释或新建 `*_manager` / `*_helper` / `*_logic`。写完必须跑：

```bash
dart run tool/check_source_size.dart
```

3. **注释**：公开类型/方法写中文 `///` 说明职责；私有方法、关键分支和业务策略（缓存回退、错误归一、状态衔接、原生降级）同样写中文注释，说明**为什么**这样写。不要复述代码；不要给 `build` 布局树、`copyWith` 灌水。生成物不手写注释。

## Widget Preview（VS Code / Cursor）

每个可展示组件在**同文件**用 `@AppPreview` 标注；整页加 `page: true`（375×812）。**不要**在 `*Screen` 上预览（会带入 Drift，预览器会报 Invalid）。整页 Preview 写在纯 UI widget 上，塞假数据。不要给 `AppPreview` 加命名构造，预览器会扫不到。

1. 安装官方 **Dart** + **Flutter** 扩展，SDK ≥ 3.47。
2. 打开本仓库后，点活动栏 **Flutter Widget Preview**（没有则命令面板运行 `Flutter: Enable Widget Previews`）。
3. 打开组件文件；预览器底部打开 **Filter previews by selected file**。
4. 改 UI 会自动刷新；全局状态变了点右下角 hot restart。

命令行：`flutter widget-preview start`。

## 硬性规则

- 页面 `*Screen`，状态 `*Controller`（`@riverpod`）。禁止 `Page` / `View` / `ViewModel` / `Cubit` / Feature 内 `*_service.dart`。
- Feature 根目录禁止 `utils/`。Screen 只 `watch` / `read.notifier`；IO 与算法走 Repository。
- DataSource **按需创建**，禁止空壳。Provider 写在 `*_repository.dart`，不写在 DataSource 文件。
- Feature 禁止互相 import。跨 Feature 用 `shared/` 或 `shared/providers/` 事件；跳转用 `TypedGoRoute`。
- Feature 只依赖 `core/platform/services/`，禁止 import `bridges/`。
- 公开类/方法写中文 `///`；业务实现（私有方法与关键分支）同样注释意图。禁止复述代码。
- git提交信息用中文，写清为什么改。禁止出现 Codex、Cursor、Claude Code，以及 `Co-Authored-By` / `Made-with` / `Generated with` 等工具签名。

分层、命名白名单、新增 Feature 步骤与自检：`.agents/skills/architecture-feature-first/SKILL.md`。

## 按任务读 Skill

| 任务 | Skill |
| --- | --- |
| 新增/重构 Feature、分层、DI | `.agents/skills/architecture-feature-first/SKILL.md` |
| Widget Preview | `.agents/skills/flutter-add-widget-preview/SKILL.md` |

## 门禁

生成物（`.g.dart`、`.freezed.dart`、Drift、Pigeon）禁止手改。改 Pigeon schema 后重生成 Dart / Swift / Kotlin。

```bash
flutter gen-l10n
dart run pigeon --input pigeons/app_platform.dart
dart run build_runner build
dart run tool/check_source_size.dart
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze --fatal-warnings --fatal-infos
flutter test
```
