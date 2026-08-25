// Test helpers live outside lib/ by design.
// ignore_for_file: always_use_package_imports

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_template/features/todo/data/todo_remote_data_source.dart';
import 'package:flutter_riverpod_template/features/todo/todo_screen.dart';
import 'package:flutter_riverpod_template/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_container.dart';

void main() {
  testWidgets('adds and completes a task from the screen', (tester) async {
    final remote = MockTodoRemoteDataSource(
      seed: const [],
      responseDelay: Duration.zero,
    );
    final container = createTestContainer(remote: remote);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // 不走 GoRouter，直接挂 Screen，只测交互。
          home: const TodoScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nothing here yet'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Prepare release notes');
    await tester.tap(find.text('Add task'));
    await tester.pumpAndSettle();

    expect(find.text('Prepare release notes'), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, isTrue);
  });
}
