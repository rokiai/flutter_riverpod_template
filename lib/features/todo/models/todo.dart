import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo.freezed.dart';
part 'todo.g.dart';

/// 一条 Todo 任务。
@freezed
abstract class Todo with _$Todo {
  const factory Todo({
    required String id,
    required String title,
    required bool isCompleted,

    /// 创建时间；列表展示用，不参与筛选。
    required DateTime createdAt,
  }) = _Todo;

  /// 从接口 JSON 反序列化。
  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}
