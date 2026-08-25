// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Riverpod Template';

  @override
  String get navigationError => 'Navigation error';

  @override
  String get backToStart => 'Back to start';

  @override
  String get tryAgain => 'Try again';

  @override
  String get networkOffline => 'The network is unavailable.';

  @override
  String get networkServer => 'The server is temporarily unavailable.';

  @override
  String get networkRequest => 'The request could not be completed.';

  @override
  String get todoTitle => 'Daily list';

  @override
  String get todoSubtitle => 'Small steps, clearly in view.';

  @override
  String get newTodoHint => 'What needs your attention?';

  @override
  String get addTodo => 'Add task';

  @override
  String get all => 'All';

  @override
  String get active => 'Active';

  @override
  String get completed => 'Done';

  @override
  String get activeTasks => 'to do';

  @override
  String get completedTasks => 'done';

  @override
  String get clearCompleted => 'Clear completed tasks';

  @override
  String get noTasks => 'Nothing here yet';

  @override
  String get noTasksHint => 'Add one small task and make it visible.';

  @override
  String get cachedData => 'Showing cached data';

  @override
  String get syncedData => 'Synced just now';

  @override
  String deleteTodo(String title) {
    return 'Delete $title';
  }

  @override
  String markTodoActive(String title) {
    return 'Mark $title as active';
  }

  @override
  String markTodoCompleted(String title) {
    return 'Mark $title as completed';
  }
}
