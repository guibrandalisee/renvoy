import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renvoy/app/app.dart';
import 'package:renvoy/data/db/database.dart';
import 'package:renvoy/data/db/database_provider.dart';

void main() {
  testWidgets('tapping Subscriptions tab shows list screen', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          bootstrapProvider.overrideWith((ref) async {}),
        ],
        child: const RenvoyApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Subscriptions'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Subscriptions'), findsWidgets);
    expect(find.text('No subscriptions yet'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 1));
    }
    await database.close();
  });
}
