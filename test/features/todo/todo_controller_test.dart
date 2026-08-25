// Test helpers live outside lib/ by design.
// ignore_for_file: always_use_package_imports

import 'package:flutter_riverpod_template/core/error/app_exception.dart';
import 'package:flutter_riverpod_template/features/todo/data/todo_remote_data_source.dart';
import 'package:flutter_riverpod_template/features/todo/models/todo.dart';
import 'package:flutter_riverpod_template/features/todo/todo_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_container.dart';

void main() {
  final seed = Todo(
    id: 'todo-1',
    title: 'Ship the template',
    isCompleted: false,
    createdAt: DateTime(2026, 8, 23),
  );

  test('loads, adds, toggles and deletes tasks', () async {
    final container = createTestContainer(seed: <Todo>[seed]);
    addTearDown(container.dispose);
    // fireImmediately 保证 provider 被 listen，不会在 await 间隙被销毁。
    final subscription = container.listen(
      todoControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await container.read(todoControllerProvider.future);
    final controller = container.read(todoControllerProvider.notifier);

    await controller.addTodo('Add cache fallback');
    var items = container.read(todoControllerProvider).requireValue.items;
    expect(items.map((todo) => todo.title), contains('Add cache fallback'));

    await controller.toggleTodo(seed.id);
    items = container.read(todoControllerProvider).requireValue.items;
    expect(items.firstWhere((todo) => todo.id == seed.id).isCompleted, isTrue);

    await controller.deleteTodo(seed.id);
    items = container.read(todoControllerProvider).requireValue.items;
    expect(items.any((todo) => todo.id == seed.id), isFalse);
  });

  test('exposes an explicit error when the initial request fails', () async {
    // 无缓存 + 远端失败：Controller 应暴露归一化后的离线错误，而不是空列表。
    final remote = MockTodoRemoteDataSource(responseDelay: Duration.zero)
      ..shouldFail = true;
    final container = createTestContainer(remote: remote);
    addTearDown(container.dispose);
    final subscription = container.listen(
      todoControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await Future<void>.delayed(const Duration(milliseconds: 1));

    final state = container.read(todoControllerProvider);
    expect(state.error, isNotNull);
    expect(state.error, isA<NetworkOfflineException>());
  });
}
