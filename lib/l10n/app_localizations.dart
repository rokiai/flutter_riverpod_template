import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Flutter Riverpod Template'**
  String get appTitle;

  /// No description provided for @navigationError.
  ///
  /// In en, this message translates to:
  /// **'Navigation error'**
  String get navigationError;

  /// No description provided for @backToStart.
  ///
  /// In en, this message translates to:
  /// **'Back to start'**
  String get backToStart;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @networkOffline.
  ///
  /// In en, this message translates to:
  /// **'The network is unavailable.'**
  String get networkOffline;

  /// No description provided for @networkServer.
  ///
  /// In en, this message translates to:
  /// **'The server is temporarily unavailable.'**
  String get networkServer;

  /// No description provided for @networkRequest.
  ///
  /// In en, this message translates to:
  /// **'The request could not be completed.'**
  String get networkRequest;

  /// No description provided for @todoTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily list'**
  String get todoTitle;

  /// No description provided for @todoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Small steps, clearly in view.'**
  String get todoSubtitle;

  /// No description provided for @newTodoHint.
  ///
  /// In en, this message translates to:
  /// **'What needs your attention?'**
  String get newTodoHint;

  /// No description provided for @addTodo.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get addTodo;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get completed;

  /// No description provided for @activeTasks.
  ///
  /// In en, this message translates to:
  /// **'to do'**
  String get activeTasks;

  /// No description provided for @completedTasks.
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get completedTasks;

  /// No description provided for @clearCompleted.
  ///
  /// In en, this message translates to:
  /// **'Clear completed tasks'**
  String get clearCompleted;

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get noTasks;

  /// No description provided for @noTasksHint.
  ///
  /// In en, this message translates to:
  /// **'Add one small task and make it visible.'**
  String get noTasksHint;

  /// No description provided for @cachedData.
  ///
  /// In en, this message translates to:
  /// **'Showing cached data'**
  String get cachedData;

  /// No description provided for @syncedData.
  ///
  /// In en, this message translates to:
  /// **'Synced just now'**
  String get syncedData;

  /// Accessibility label for deleting a todo.
  ///
  /// In en, this message translates to:
  /// **'Delete {title}'**
  String deleteTodo(String title);

  /// Accessibility label for activating a completed todo.
  ///
  /// In en, this message translates to:
  /// **'Mark {title} as active'**
  String markTodoActive(String title);

  /// Accessibility label for completing an active todo.
  ///
  /// In en, this message translates to:
  /// **'Mark {title} as completed'**
  String markTodoCompleted(String title);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
