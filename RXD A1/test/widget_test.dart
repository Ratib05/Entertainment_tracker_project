import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rxd_a1/main.dart';

void main() {
  testWidgets('ReelLog loads and can log a film', (WidgetTester tester) async {
    await tester.pumpWidget(const ReelLogApp());

    expect(find.text('ReelLog'), findsOneWidget);
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
}
