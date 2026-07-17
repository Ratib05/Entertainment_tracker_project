import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:entertainment_tracker/main.dart';

Future<void> _logIn(WidgetTester tester) async {
  await tester.enterText(
    find.byType(TextFormField).at(0),
    'user@example.com',
  );
  await tester.enterText(
    find.byType(TextFormField).at(1),
    'password123',
  );
  await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Movies mode loads and can log a film', (WidgetTester tester) async {
    await tester.pumpWidget(const ReelLogApp());

    expect(find.text('Entertainment Tracker'), findsOneWidget);
    await _logIn(tester);

    expect(find.text('Movies and Shows Tracker'), findsOneWidget);
    expect(find.text('Nothing logged yet'), findsOneWidget);

    await tester.tap(find.text('Log your first title'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'Inception',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add to Log'));
    await tester.pumpAndSettle();

    expect(find.text('Inception'), findsOneWidget);
    expect(find.text('Film'), findsOneWidget);
  });

  testWidgets('Games mode can log a game', (WidgetTester tester) async {
    await tester.pumpWidget(const ReelLogApp());
    await _logIn(tester);

    await tester.tap(find.byIcon(Icons.sports_esports));
    await tester.pumpAndSettle();

    expect(find.text('Games Tracker'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Hades');
    await tester.tap(find.widgetWithText(FilledButton, 'Add to Log'));
    await tester.pumpAndSettle();

    expect(find.text('Hades'), findsOneWidget);
    expect(find.text('Game'), findsOneWidget);
  });
}
