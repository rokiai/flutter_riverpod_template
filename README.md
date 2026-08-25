# Flutter Riverpod Template

Feature-First Flutter + Riverpod 脚手架。仓库里的 Todo 示例覆盖：**接口请求、缓存回退、声明式路由、原生桥、Widget Preview、测试**。下面的教程**不依赖 Todo**，用一个独立的**计数器**说明怎么加 Feature、怎么跨 Feature 共享状态。

- SDK：Flutter **3.47.0+** / Dart **3.13.0+**（已验证 3.47.1 / 3.13.1）
- 给 Agent 的硬性规则和门禁：[Agents.md](Agents.md)
- 分层细则：[`.agents/skills/architecture-feature-first/SKILL.md`](.agents/skills/architecture-feature-first/SKILL.md)

## 目录

1. [跑起来](#跑起来)
2. [目录约定](#目录约定)
3. [分层一句话](#分层一句话)
4. [教程：新增计数器 Feature](#教程新增计数器-feature)
5. [教程：跨 Feature 共享状态](#教程跨-feature-共享状态)
6. [路由与跳转](#路由与跳转)
7. [Widget Preview](#widget-preview)
8. [本地化](#本地化)
9. [生成物与门禁](#生成物与门禁)
10. [常见错误](#常见错误)

## 跑起来

只有一个 Dart 入口：`lib/main.dart`。不要再加 `main_dev.dart`、`--flavor`、`.env.*`。

```bash
flutter pub get
flutter gen-l10n
dart run pigeon --input pigeons/app_platform.dart
dart run build_runner build
flutter run
```

VS Code / Cursor 用 `.vscode/launch.json` 里的 `flutter_riverpod_template` 即可。

## 目录约定

```text
lib/
├── main.dart / app.dart
├── core/                 # error, network, platform, storage, theme, utils
├── shared/               # 至少 2 个 Feature 才放的业务契约
├── common_widgets/       # 无业务的通用 UI
├── routing/              # GoRouter；业务路由在 routes/<feature>_routes.dart
├── features/todo/        # 仓库自带示例（接口 + 缓存），与下面教程无关
└── l10n/
pigeons/                  # Pigeon schema
test/features/todo/
```

新业务只进 `lib/features/<name>/`，**按需建文件**，禁止空壳。

```text
features/<feature>/
├── models/               # 实体 + *State，默认 @freezed
├── data/                 # 有 IO 才建
│   ├── *_remote_data_source.dart
│   ├── *_local_data_source.dart
│   ├── *_repository.dart     # Provider 写在这里
│   └── utils/                # Feature 内唯一允许的 utils
├── <feature>_controller.dart
├── <feature>_screen.dart
└── widgets/
```

Feature 根目录禁止 `utils/`。禁止 `Page` / `View` / `ViewModel` / `Cubit` / Feature 内 `*_service.dart`。

## 分层一句话

| 层 | 做什么 | 不做什么 |
| --- | --- | --- |
| **Screen** | `watch` 状态，`read.notifier` 发命令，组 UI | HTTP、Drift、Pigeon、重计算 |
| **Controller** | `@riverpod`，调 Repository，持有页面状态 | 直接碰 Dio / Drift / Bridge |
| **Repository** | 该资源的唯一出口：编排 DataSource、缓存、错误 → `AppException` | 画 UI |
| **DataSource** | 只做 I/O | 文件里写 Provider / `Ref` |

数据往下（Data → Controller → Screen），命令往上（Screen → Controller → Repository）。

没有网络、没有本地存储时，**不要**为了分层去建空 `data/`。

---

## 教程：新增计数器 Feature

场景：一个独立页面，显示当前数字，可以 **+1 / −1 / 归零**。  
计数器**没有接口**，第一版也**不落盘**。所以不要建空的 `*_remote_data_source.dart` / `*_local_data_source.dart`，没有 IO 就不要 `data/`。当前数字属于页面状态，放 Controller。

### 0. 动手前

先搜 `core/`、`shared/`、`common_widgets/`、`pubspec.yaml` 和现有 Feature。没有现成计数器，才新建 `features/counter/`。

### 1. 只建用得到的文件

```text
lib/features/counter/
├── models/
│   └── counter_state.dart
├── counter_controller.dart
├── counter_screen.dart
└── widgets/
    ├── counter_display.dart     # 数字展示
    └── counter_view.dart        # 整页纯 UI（给 Preview 用）
lib/routing/routes/counter_routes.dart
test/features/counter/
    └── counter_controller_test.dart
```

### 2. 状态

`models/counter_state.dart`：只描述形状，不要 `DateTime.now()`、Riverpod、Flutter UI。

```dart
@freezed
abstract class CounterState with _$CounterState {
  const CounterState._();
  const factory CounterState({
    @Default(0) int value,
  }) = _CounterState;

  bool get isZero => value == 0;
}
```

### 3. Controller

`@riverpod` Notifier。加减和归零都是内存状态，不进 Screen。

```dart
@riverpod
class CounterController extends _$CounterController {
  @override
  CounterState build() => const CounterState();

  void increment() => state = state.copyWith(value: state.value + 1);

  void decrement() => state = state.copyWith(value: state.value - 1);

  void reset() => state = const CounterState();
}
```

以后若要「下次打开还记得数字」，再补：

- `data/counter_local_data_source.dart`（Drift / 安全存储）
- `data/counter_repository.dart`（在此声明 Provider）
- Controller 改为调 Repository，仍然不碰 Drift

没有真实 API 就不要 Mock 空壳 RemoteDataSource。

### 4. Screen 与 widgets

`CounterScreen` 只 `watch` / `read.notifier`，把回调传给 `CounterView`。

```dart
class CounterScreen extends ConsumerWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(counterControllerProvider);
    final controller = ref.read(counterControllerProvider.notifier);
    return CounterView(
      state: state,
      onIncrement: controller.increment,
      onDecrement: controller.decrement,
      onReset: controller.reset,
    );
  }
}
```

子组件不必加 Preview。整页 `@AppPreview(...)` 写在 `counter_view.dart`，**不要**标在 `CounterScreen` 上（Screen 一旦接 Repository/Drift，预览器会报 Invalid）。

```dart
@AppPreview(name: '非零', group: 'counter')
Widget previewCounterViewValue() {
  return CounterView(
    state: const CounterState(value: 7),
    onIncrement: () {},
    onDecrement: () {},
    onReset: () {},
  );
}
```

### 5. 文案走 l10n

`lib/l10n/app_zh.arb` / `app_en.arb` 增加 `counterTitle`、`counterIncrement` 等 key，然后：

```bash
flutter gen-l10n
```

禁止在 Widget 里写死用户可见中文（Preview 假数据除外）。

### 6. 路由

`lib/routing/routes/counter_routes.dart`：

```dart
@TypedGoRoute<CounterRoute>(path: '/counter', name: 'counter')
class CounterRoute extends GoRouteData with $CounterRoute {
  const CounterRoute();

  @override
  CustomTransitionPage<void> buildPage(
    BuildContext context,
    GoRouterState state,
  ) {
    return SlideTransitionPage<void>(
      key: state.pageKey,
      child: const CounterScreen(),
    );
  }
}
```

在 `lib/routing/routes.dart` 把生成的路由展开进 `appRoutes`（已有条目保持不动）：

```dart
final appRoutes = <RouteBase>[
  ...existingFeatureRoutes,
  ...counter_routes.$appRoutes,
];
```

其他 Feature 要打开计数器时，只 import 路由，**禁止** import `features/counter/`：

```dart
const CounterRoute().push(context);
```

参数只传 ID / URL-safe 字符串，不传对象、不传 `$extra`。

### 7. 生成与测试

```bash
dart run build_runner build
dart run tool/check_source_size.dart
flutter analyze --fatal-warnings --fatal-infos
flutter test
```

测试放 `test/features/counter/`。

### 8. 自检

- [ ] 没有空壳 DataSource
- [ ] 没有 Feature 根 `utils/`、`*_helper` / `*_service` / `*_manager`
- [ ] Screen 不碰 IO
- [ ] Screen 抽离的 View 有 `@AppPreview`，不写在 `*Screen` 或子组件上
- [ ] 单文件有效代码行 ≤ 500（Preview 代码不计）

---

## 教程：跨 Feature 共享状态

**Feature 禁止互相 import。** `stats` 不能 `import .../features/counter/...`，反过来也不行。

跳转走 `routing/` 的 `TypedGoRoute`。共享**业务状态**才进 `shared/`，并且 **至少两个 Feature 都要用** 才建；一个 Feature 私有的状态不要提前放到 `shared/`。

依赖方向：

```text
routing → features/<feature> → shared / core / common_widgets
shared → core
core → （无业务依赖）
```

### 什么时候用哪一种

| 需求 | 做法 |
| --- | --- |
| 打开另一个页面 | `XxxRoute().push(context)`，只传 ID |
| 两个页面都要读同一份进行中的数据 | `shared/providers/` 里一个 Notifier，拥有方写入，使用方 `watch` |
| 一方变更后，另一方要重新拉自己的数据 | 拥有方在 `shared/providers/` **广播**；被影响方 `listen` 后自己 `refresh` |
| 无业务的按钮、空态、加载圈 | `common_widgets/`，不要塞 Feature 模型 |

不要预建 `core/event_bus/`。

### 例子：统计页显示当前计数

另有一个 **stats（统计）** Feature，仪表盘上要显示计数器的当前值。这份数字被 **counter + stats** 两个 Feature 使用，所以放到 `shared/`。计数器页面自己的加减逻辑仍留在 `CounterController`，不要让 stats 去碰它。

```text
lib/shared/
├── models/
│   └── counter_snapshot.dart            # 契约：当前值
└── providers/
    └── counter_snapshot_provider.dart   # 广播，不是 Feature Controller
```

契约（无 UI、无 IO）：

```dart
@freezed
abstract class CounterSnapshot with _$CounterSnapshot {
  const factory CounterSnapshot({
    @Default(0) int value,
  }) = _CounterSnapshot;
}
```

广播：

```dart
@riverpod
class CounterSnapshotHolder extends _$CounterSnapshotHolder {
  @override
  CounterSnapshot build() => const CounterSnapshot();

  void publish(int value) => state = CounterSnapshot(value: value);
}
```

**写入（counter 拥有加减）：** `CounterController` 每次 increment / decrement / reset 后：

```dart
ref.read(counterSnapshotHolderProvider.notifier).publish(state.value);
```

**读取（stats 只用契约）：**

```dart
final snapshot = ref.watch(counterSnapshotHolderProvider);
Text('当前计数 ${snapshot.value}');
```

两边都只依赖 `shared/`，不依赖对方 Feature。

### 例子：归零后，统计页自己刷新

stats 可能还有自己的汇总（今日操作次数等）。它不需要知道 Counter 内部实现，只需要「数字被清零了」这个信号。

```dart
@riverpod
class CounterResetTick extends _$CounterResetTick {
  @override
  int build() => 0;

  void notify() => state++;
}
```

`CounterController.reset()` 里 `notify()`。stats 的 Controller 在 `build` 里：

```dart
ref.listen(counterResetTickProvider, (previous, next) {
  if (previous != next) {
    refresh();
  }
});
```

被影响方**自己** refresh，不要让 counter 去 import `StatsRepository`。

### 不要这样做

```dart
// 错误：Feature 互相 import
import 'package:flutter_riverpod_template/features/counter/counter_controller.dart';

// 错误：只有 counter 用，却塞进 shared/
lib/shared/providers/counter_internal_value.dart

// 错误：跳转塞不可恢复对象
context.push('/counter', extra: someObject); // 用 const CounterRoute().push(context)
```

---

## 路由与跳转

- 每个 Feature 一个 `lib/routing/routes/<feature>_routes.dart`
- `@TypedGoRoute` + `go_router` 代码生成（`*.g.dart` 禁止手改）
- 新路由在 `lib/routing/routes.dart` 的 `appRoutes` 里展开
- 参数只传 ID / URL-safe 字符串

## Widget Preview

1. 安装官方 Dart + Flutter 扩展，SDK ≥ 3.47
2. 活动栏打开 **Flutter Widget Preview**（没有则命令面板：`Flutter: Enable Widget Previews`）
3. 打开 View 文件，打开底部 **Filter previews by selected file**

只给 Screen 抽离的 View 加 `@AppPreview(...)`。不要给 `AppPreview` 加命名构造或自定义字段。子组件不必加 Preview。

细则：[`.agents/skills/flutter-add-widget-preview/SKILL.md`](.agents/skills/flutter-add-widget-preview/SKILL.md)

## 本地化

用户可见文案进 `lib/l10n/app_zh.arb` / `app_en.arb`，改完跑 `flutter gen-l10n`。生成的 `app_localizations*.dart` 不要手改。

## 生成物与门禁

禁止手改：`.g.dart`、`.freezed.dart`、Drift 生成物、Pigeon 生成的 Dart / Swift / Kotlin。改 `pigeons/app_platform.dart` 后必须重跑 Pigeon。

提交前：

```bash
flutter gen-l10n
dart run pigeon --input pigeons/app_platform.dart
dart run build_runner build
dart run tool/check_source_size.dart
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze --fatal-warnings --fatal-infos
flutter test
```

提交：`type(scope): 中文说明`，新功能用 `feat`；不要带工具签名。详见 [Agents.md](Agents.md)。

## 常见错误

| 错误 | 正确做法 |
| --- | --- |
| 新建 `CounterPage` / `CounterViewModel` | `CounterScreen` + `CounterController` |
| Feature 里写 `counter_service.dart` | 无 IO 就只留 Controller；有 IO 走 Repository |
| 没有接口也写 RemoteDataSource | 不建该文件 |
| Provider 写在 DataSource 文件 | 写在 `*_repository.dart` |
| `stats` import `counter` | `shared/` 契约或 `TypedGoRoute` |
| 给 tile / header 也加 Preview | 只给 Screen 抽离的 View 加 |
| 为过 500 行删注释、建 `*_helper` | 按白名单拆文件；Preview 代码本就不计 |

完整检查清单见 architecture skill 第 9 节。
