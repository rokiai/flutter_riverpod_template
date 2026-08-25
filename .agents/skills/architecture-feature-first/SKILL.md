---
name: architecture-feature-first
description: >-
  Use when creating a Flutter feature, designing Feature-First folders, adding
  Screen/Controller/Repository/DataSource, deciding which layer owns logic,
  wiring Riverpod DI, sharing state across features, or connecting native
  capabilities in this repository.
---

# Feature-First 架构

新增或重构 Feature 时按本文件执行。仓库总览、命令和门禁见根目录 `AGENTS.md`。

本仓库固定使用 `Screen` + `Controller` + `Repository` + 按需 DataSource；DI 只用 Riverpod Provider。

动手前先做 `AGENTS.md` 的前缀校验：先复用项目已有能力，再考虑热门库，最后才自研；单文件有效代码行 ≤ 500（生成物与 Widget Preview 不计），写完跑 `dart run tool/check_source_size.dart`；公开类型/方法写中文 `///`，业务实现（私有方法、缓存/错误/状态衔接）也写清意图。

## 何时使用

- 设计或新增 `features/<name>/`
- 决定逻辑落在 Screen、Controller、Repository 还是 DataSource
- 添加远程/本地数据、缓存回退、算法加工
- 跨 Feature 共享状态或跳转
- 接入插件或自研 Pigeon 原生能力

## 1. 分层

```text
┌─────────────────────────────────────────────────────────────┐
│ UI          Screen + Controller（@riverpod AsyncNotifier）   │
├─────────────────────────────────────────────────────────────┤
│ Data        Repository（唯一出口）                            │
│             ├ RemoteDataSource   仅当有真实网络 API            │
│             ├ LocalDataSource    仅当有 Drift / 安全存储        │
│             └ data/utils         仅当有无状态算法/格式化/映射    │
└─────────────────────────────────────────────────────────────┘
```

- 页面：`*Screen`，文件 `<feature>_screen.dart`
- 状态：`*Controller`，文件 `<feature>_controller.dart`
- 数据出口：`*Repository`
- 远端 I/O：`*RemoteDataSource`（禁止 `*_service.dart`）
- 复杂计算：放 `data/utils/`，不另建 UseCase / domain 层
- Provider 声明在 `*_repository.dart`

规则：

- 只允许相邻层通信。Screen / Controller **禁止**直接碰 DataSource、`data/utils`、Dio、Drift、Pigeon Bridge。
- 数据变更只发生在 Data 层。Repository 是该资源的唯一出口。
- 单向数据流：状态向下（Data → Controller → Screen），命令向上（Screen → Controller → Repository）。
- 不预建空壳：没有网络就不要 `*_remote_data_source.dart`；没有本地持久化就不要 `*_local_data_source.dart`。
- 禁止 `Page`、`View`、`ViewModel`、`Cubit`、`ui/`、`domain/`、`get_it`。

## 2. Feature 目录（按需创建）

```text
features/<feature>/
├── models/
│   ├── <resource>.dart              # 领域实体，默认 @freezed
│   └── <feature>_state.dart         # UI 状态，@freezed
├── constants/                       # 仅 Feature 专属常量/枚举
├── data/
│   ├── utils/                       # Feature 内唯一允许的 utils
│   │   ├── <feature>_formatter.dart
│   │   ├── <feature>_sorter.dart
│   │   ├── <feature>_hash_utils.dart / <feature>_algo_utils.dart
│   │   └── <feature>_mapper.dart
│   ├── <feature>_remote_data_source.dart   # 按需
│   ├── <feature>_local_data_source.dart    # 按需
│   └── <feature>_repository.dart
├── <feature>_controller.dart
├── <feature>_screen.dart
└── widgets/                         # 纯展示、Dialog、BottomSheet
```

**Feature 根目录严禁 `utils/`。** 路由声明放 `lib/routing/routes/<feature>_routes.dart`，不放进 Feature。

测试镜像到 `test/features/<feature>/`。

## 3. 各层职责

### Screen

- 只构建 UI、接收路由参数、分发交互。
- `ref.watch(*ControllerProvider)` 读状态；`ref.read(*ControllerProvider.notifier).command()` 发命令。
- 禁止 HTTP、SQLite、原生 Bridge、重计算。

### Controller

- 类名以 `Controller` 结尾。`@riverpod` 生成式 `AsyncNotifier` / `Notifier`。
- 持有 `AsyncValue<FeatureState>`，调用 Repository，不碰 Dio / Drift / Bridge。

### Repository

- Data 层唯一公开出口。编排 DataSource 与 `data/utils`。
- 负责缓存策略（优先远端、失败回退本地）和错误归一化（→ `AppException`）。

### DataSource

- 只做 I/O：Remote 把 JSON 变成类型化 DTO/Model；Local 做 Drift 读写与 row 映射。
- **文件内禁止** `@riverpod`、`Ref`、Provider。Provider 写在 `*_repository.dart`。
- 不向上泄露 `Response`、`Map<String, dynamic>` 或原始 SQLite 异常。

### Model

- 只描述数据形状。允许基于自身字段的纯 Getter。
- 禁止 Riverpod、Drift、Pigeon、`BuildContext`、`intl`、Flutter UI、`DateTime.now()`、IO。

## 4. Presentation 逻辑归位

1. 弹窗 → `widgets/<feature>_dialog.dart` 或 `*_bottom_sheet.dart`，类上提供 `show`。禁止 `*_dialog_helper.dart`。
2. 派生状态 → State 的 Getter 或 `extension XxxStateX on XxxState`。禁止 `*_selectors.dart`。
3. 展示计算 → Widget 私有方法/Getter。

## 5. 命名白名单 / 黑名单

`models/` 允许：`<resource>.dart`、`<feature>_state.dart`、必要时 `<feature>_models.dart`（或沿用已有聚合文件如 `cleanup.dart`）。模型默认 `@freezed`。

`data/` 顶层只允许三种后缀：`*_remote_data_source.dart`、`*_local_data_source.dart`、`*_repository.dart`。

禁止：`*_helper.dart`、`*_logic.dart`、`*_service.dart`、`*_manager.dart`、`*_selectors.dart`、Feature 根 `utils/`、`data/utils.dart` 平铺文件。

文件 `snake_case`；类型 UpperCamelCase；Provider 以 `Provider` 结尾。手写源文件有效代码行 ≤ 500（不含 import/export/part、注释、空行、生成物、Widget Preview）。超了按白名单拆，禁止为了缩行改生成物或新建黑名单文件。写完跑 `dart run tool/check_source_size.dart`。

## 6. 跨 Feature 与依赖方向

```text
routing → features/<feature> → shared / core / common_widgets
shared → core
core → （无业务依赖）
```

- Feature **禁止**互相 import。
- 跨 Feature 状态：至少两个 Feature 才放 `shared/`。动到别人时用 `shared/providers/` 广播，被影响方自己 refresh。不要预建 `core/event_bus/`。
- 跳转用 `routing/` 的 `TypedGoRoute`。只传 ID 或 URL-safe 字符串，不传不可恢复的 `$extra`。
- `common_widgets` 只依赖 `core/theme` 和无业务 UI。

## 7. 缓存与原生

缓存链路：`appDatabaseProvider` → LocalDataSource → Repository → Controller。测试 override `AppDatabase(NativeDatabase.memory())`。表结构在 `core/storage/app_database.dart` 升 `schemaVersion` 并写 `onUpgrade`。

原生：Feature 只依赖 `core/platform/services/`。插件能力包一层 Service；自研能力才加 `bridges/` + `pigeons/`。改 schema 后重生成 Dart/Swift/Kotlin，禁止手改 `.g.dart`。重活离开主线程；错误码非本地化，Dart 转 `AppException`，UI 走 l10n。

## 8. 工作流：新增 Feature

0. **前缀校验**：检索 `core/`、`shared/`、`common_widgets/`、`pubspec.yaml` 和现有 Feature。已有能力直接用；没有再加热门库并按分层包装；仍没有才自研。
1. 建 `features/<name>/`，**只建用得到的文件**。
2. 有网络才写 RemoteDataSource；有 Drift/安全存储才写 LocalDataSource。
3. 写 Repository：注入 DataSource，做缓存与 `AppException` 归一化；在此文件声明 DataSource / Repository Provider。
4. 写 `@freezed` Model 与 `*State`。
5. 写 `@riverpod` Controller，只依赖 Repository。
6. 写 Screen 与必要 widgets。子组件 `@AppPreview`；整页 `@AppPreview(..., page: true)` 写在不依赖 Controller/Drift 的 widget 上。
7. 在 `lib/routing/routes/<name>_routes.dart` 声明路由并挂到 `routes.dart`。
8. 测试镜像到 `test/features/<name>/`，用 `test/helpers/test_container.dart` override。
9. 自检：无空壳 DataSource、无 Feature 根 `utils/`、无跨 Feature import、无越级依赖；`dart run tool/check_source_size.dart` 通过。

参考现成示例：`lib/features/todo/`。

## 9. 完成后检查

- [ ] 没有空壳 `*_remote_data_source.dart` / `*_local_data_source.dart`
- [ ] 没有 Feature 根 `utils/`、`*_helper`、`*_manager`、`*_service`、`*_logic`
- [ ] DataSource 文件无 Provider；Provider 在 Repository
- [ ] Screen/Controller 不直接访问 DataSource 或 `data/utils`
- [ ] Feature 之间无 import；原生不 import `bridges/`
- [ ] `@riverpod` + 不可变 `@freezed` 状态
- [ ] 异常已转为 `AppException`；重算法走 `compute` / Isolate
- [ ] 没有重复实现 `core/` / `shared/` / `common_widgets/` / 已有依赖里已有的能力
- [ ] `dart run tool/check_source_size.dart` 通过（有效代码行 ≤ 500）
- [ ] 公开类/方法有中文 `///`；私有方法与关键业务分支也有意图注释，没有复述代码的废话
- [ ] 新的可展示组件有 `@AppPreview`；整页 Preview 不写在 `*Screen` 上
