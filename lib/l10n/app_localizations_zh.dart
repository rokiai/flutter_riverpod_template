// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Flutter Riverpod 脚手架';

  @override
  String get navigationError => '导航出错';

  @override
  String get backToStart => '返回首页';

  @override
  String get tryAgain => '重试';

  @override
  String get networkOffline => '网络不可用。';

  @override
  String get networkServer => '服务器暂时不可用。';

  @override
  String get networkRequest => '请求无法完成。';

  @override
  String get todoTitle => '每日清单';

  @override
  String get todoSubtitle => '把小步行动清楚地放在眼前。';

  @override
  String get newTodoHint => '有什么需要你关注？';

  @override
  String get addTodo => '添加任务';

  @override
  String get all => '全部';

  @override
  String get active => '进行中';

  @override
  String get completed => '已完成';

  @override
  String get activeTasks => '待办';

  @override
  String get completedTasks => '完成';

  @override
  String get clearCompleted => '清除已完成任务';

  @override
  String get noTasks => '这里还没有任务';

  @override
  String get noTasksHint => '添加一个小任务，让它清晰可见。';

  @override
  String get cachedData => '当前显示的是缓存数据';

  @override
  String get syncedData => '刚刚同步';

  @override
  String deleteTodo(String title) {
    return '删除 $title';
  }

  @override
  String markTodoActive(String title) {
    return '将 $title 标记为进行中';
  }

  @override
  String markTodoCompleted(String title) {
    return '将 $title 标记为已完成';
  }
}
