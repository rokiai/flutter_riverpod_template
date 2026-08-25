import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Todo 缓存行。领域映射放在 Feature LocalDataSource，core 不依赖 Feature。
class TodoEntries extends Table {
  /// 任务主键，与远端/领域模型的 id 一致。
  TextColumn get id => text()();

  TextColumn get title => text()();

  BoolColumn get isCompleted => boolean()();

  DateTimeColumn get createdAt => dateTime()();

  /// 列表展示顺序；由 LocalDataSource 按快照下标写入。
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// 缓存是否存在及最近写入时间。
class TodoCacheMetadata extends Table {
  /// 单行表，固定为 1。
  IntColumn get id => integer()();

  /// 最近一次成功写入缓存的时间。
  DateTimeColumn get savedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// 应用级 Drift 数据库。表结构变更必须提高 [schemaVersion] 并写迁移。
@DriftDatabase(tables: [TodoEntries, TodoCacheMetadata])
final class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// 使用默认文件/Web worker 打开数据库。
  AppDatabase.defaults()
    : super(
        driftDatabase(
          name: 'flutter_riverpod_template',
          // Web 需要 wasm + worker；原生走默认文件路径。
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  /// 改表必须 +1 并写 `onUpgrade`；当前示例无迁移。
  @override
  int get schemaVersion => 1;
}
