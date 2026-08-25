import 'package:flutter_riverpod_template/core/error/app_exception.dart';
import 'package:flutter_riverpod_template/core/network/dio_client.dart';
import 'package:flutter_riverpod_template/features/todo/models/todo.dart';

/// Todo 远端访问契约。只做请求与解析，不含缓存策略。
abstract interface class TodoRemoteDataSource {
  /// 拉取任务列表。
  Future<List<Todo>> fetchTodos();

  /// 创建任务。
  Future<Todo> createTodo(String title);

  /// 更新任务。
  Future<Todo> updateTodo(Todo todo);

  /// 按 id 删除任务。
  Future<void> deleteTodo(String id);
}

/// 内存 Mock，供本地运行和测试使用。
final class MockTodoRemoteDataSource implements TodoRemoteDataSource {
  MockTodoRemoteDataSource({
    DateTime Function()? clock,
    List<Todo>? seed,
    this.responseDelay = const Duration(milliseconds: 160),
  }) : _clock = clock ?? DateTime.now,
       // 拷贝 seed，避免测试改列表时污染调用方传入的常量。
       _todos = List<Todo>.of(seed ?? _defaultTodos);

  /// 可注入时钟，测试里用来生成稳定 id。
  final DateTime Function() _clock;
  final List<Todo> _todos;

  /// 模拟 RTT；测试应设为 [Duration.zero]。
  final Duration responseDelay;

  /// 置为 true 时后续请求会抛出 [NetworkOfflineException]，用于测缓存回退。
  bool shouldFail = false;

  @override
  Future<List<Todo>> fetchTodos() async {
    await _waitForMockResponse();
    return List<Todo>.unmodifiable(_todos);
  }

  @override
  Future<Todo> createTodo(String title) async {
    await _waitForMockResponse();
    final todo = Todo(
      id: 'todo-${_clock().microsecondsSinceEpoch}',
      title: title,
      isCompleted: false,
      createdAt: _clock(),
    );
    // 最新任务插到头部，和常见列表接口一致。
    _todos.insert(0, todo);
    return todo;
  }

  @override
  Future<Todo> updateTodo(Todo todo) async {
    await _waitForMockResponse();
    final index = _todos.indexWhere((item) => item.id == todo.id);
    if (index == -1) {
      throw const NetworkRequestException(
        message: 'The task no longer exists.',
      );
    }
    _todos[index] = todo;
    return todo;
  }

  @override
  Future<void> deleteTodo(String id) async {
    await _waitForMockResponse();
    _todos.removeWhere((todo) => todo.id == id);
  }

  /// 模拟网络耗时；[shouldFail] 时抛离线错误，走 Repository 的缓存降级。
  Future<void> _waitForMockResponse() async {
    await Future<void>.delayed(responseDelay);
    if (shouldFail) {
      throw const NetworkOfflineException();
    }
  }

  /// 首次进入页面时的示例数据，方便脚手架开箱即用。
  static final _defaultTodos = <Todo>[
    Todo(
      id: 'todo-1',
      title: 'Review the architecture boundaries',
      isCompleted: true,
      createdAt: DateTime(2026, 8, 20),
    ),
    Todo(
      id: 'todo-2',
      title: 'Build the first product slice',
      isCompleted: false,
      createdAt: DateTime(2026, 8, 21),
    ),
    Todo(
      id: 'todo-3',
      title: 'Connect the production API',
      isCompleted: false,
      createdAt: DateTime(2026, 8, 22),
    ),
  ];
}

/// 基于 Dio 的真实远端实现；默认未启用。
final class DioTodoRemoteDataSource implements TodoRemoteDataSource {
  const DioTodoRemoteDataSource(this.client);

  final DioClient client;

  @override
  Future<List<Todo>> fetchTodos() async {
    final response = await client.dio.get<List<Object?>>('/todos');
    final payload = response.data ?? const <Object?>[];
    return payload.map(_decodeTodo).toList(growable: false);
  }

  @override
  Future<Todo> createTodo(String title) async {
    final response = await client.dio.post<Object?>(
      '/todos',
      data: <String, Object?>{'title': title},
    );
    return _decodeTodo(response.data);
  }

  @override
  Future<Todo> updateTodo(Todo todo) async {
    final response = await client.dio.put<Object?>(
      '/todos/${todo.id}',
      data: todo.toJson(),
    );
    return _decodeTodo(response.data);
  }

  @override
  Future<void> deleteTodo(String id) async {
    await client.dio.delete<void>('/todos/$id');
  }

  /// 把接口 JSON 转成 [Todo]；结构不对视为请求失败，避免 UI 解析崩溃。
  Todo _decodeTodo(Object? payload) {
    if (payload is! Map) {
      throw const NetworkRequestException(message: 'Invalid task response.');
    }
    return Todo.fromJson(Map<String, dynamic>.from(payload));
  }
}
