# Flutter Riverpod Template

Feature-First Flutter + Riverpod 脚手架。示例覆盖接口请求、缓存回退、路由、原生桥与测试。

SDK：Flutter 3.47.0+ / Dart 3.13.0+（已验证 3.47.1 / 3.13.1）。

## Agent 前缀校验（动手前必做）

1. **复用顺序**（先检索，再写代码）
   1. 项目已有：`core/`、`shared/`、`common_widgets/`、`pubspec.yaml` 已有依赖、现有 Feature 里可复用的 widgets / Service。
   2. 项目没有：再选 pub.dev 上下载量高、维护活跃的库，并按本仓库分层包一层（插件进 `core/platform/services/<module>/`，UI 进 `common_widgets/` 或 Feature `widgets/`）。
   3. 仍没有：才自研。禁止重复实现项目里已经有的能力。
2. **体积与拆分**：手写源文件单文件有效代码行 ≤ 500（Dart、Swift、Kotlin 等原生代码同样适用；不含 `import` / `export` / `part` / `package`、注释、空行）。生成物与 Widget Preview（`@AppPreview`、`previewXxx`、假数据、`app_preview.dart`）不计。超过上限时，先分析文件职责、内聚性、依赖关系、测试边界和拆分后的可读性；只有存在清晰职责边界且拆分能降低复杂度时，才按白名单拆分。若合理拆分会破坏内聚性，应先调整职责或设计并说明原因，不能把超限当作绕过门禁的理由。禁止为了过门禁机械拆分、制造只转发的空壳文件、删注释或新建 `*_manager` / `*_helper` / `*_logic`。最终仍须通过：

```bash
dart run tool/check_source_size.dart
```

3. **注释**：注释规则适用于 Dart、Swift、Kotlin 等手写源码，包括 `ios/`、`android/` 中的平台实现和原生桥接。公开类型/方法写中文文档注释（按语言惯例使用 `///`、KDoc `/** */` 等）；私有方法、关键分支和业务策略（缓存回退、错误归一、状态衔接、原生桥接、线程/生命周期、权限、错误码映射、原生降级）同样写中文注释，说明**为什么**这样写。Pigeon、Drift、插件等生成物不手写、不补注释。不要复述代码；不要给 `build` 布局树、`copyWith` 灌水。

## Widget Preview（VS Code / Cursor）

只给 **Screen 抽离出来的 View** 加 `@AppPreview(...)`（375×812 由注解注入，假数据）。**不要**标在 `*Screen` 上（会带入 Drift）。tile / header / 输入条等子组件和 `common_widgets` 不必加 Preview。不要给 `AppPreview` 加命名构造或自定义字段（不要写 `page: true`）。

1. 安装官方 **Dart** + **Flutter** 扩展，SDK ≥ 3.47。
2. 打开本仓库后，点活动栏 **Flutter Widget Preview**（没有则命令面板运行 `Flutter: Enable Widget Previews`）。
3. 打开 View 文件；预览器底部打开 **Filter previews by selected file**。
4. 改 UI 会自动刷新；全局状态变了点右下角 hot restart。

命令行：`flutter widget-preview start`。

## 硬性规则

- 页面 `*Screen`，状态 `*Controller`（`@riverpod`）。禁止 `Page` / `View` / `ViewModel` / `Cubit` / Feature 内 `*_service.dart`。
- Feature 根目录禁止 `utils/`。Screen 只 `watch` / `read.notifier`；IO 与算法走 Repository。
- DataSource **按需创建**，禁止空壳。Provider 写在 `*_repository.dart`，不写在 DataSource 文件。
- Feature 禁止互相 import。跨 Feature 用 `shared/` 或 `shared/providers/` 事件；跳转用 `TypedGoRoute`。
- Feature 只依赖 `core/platform/services/<module>/`，禁止 import `bridges/`。Service 按模块分子目录，禁止在 `services/` 根平铺。
- Dart 与原生代码（Swift、Kotlin、Java、Objective-C 等）的公开类/方法都写中文文档注释；业务实现（私有方法与关键分支）同样注释意图，原生桥接、线程/生命周期、权限、错误码映射和降级策略不得省略。Pigeon、插件等生成物不手写、不补注释。禁止复述代码。
- 提交：`type(scope): 中文说明`（新功能用 `feat`，不要写成 `feature`）。禁止 Codex / Cursor / Claude Code 及 `Co-Authored-By` 等工具签名。

仓库目录、分层、命名白名单、新增 Feature 步骤与自检：`.agents/skills/architecture-feature-first/SKILL.md`。

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
