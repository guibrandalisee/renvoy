import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renvoy/app/app.dart';
import 'package:renvoy/data/db/database.dart';
import 'package:renvoy/data/db/database_provider.dart';
import 'package:renvoy/domain/models/enums.dart';

void main() {
  testWidgets('subscriptions list shows, searches, and filters status', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    await _insertSubscription(database, 'Netflix', SubscriptionStatus.active);
    await _insertSubscription(database, 'Spotify', SubscriptionStatus.paused);

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

    await tester.tap(find.text('Subscriptions').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('Spotify'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'net');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('Spotify'), findsNothing);

    await tester.enterText(find.byType(EditableText), '');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Paused').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Spotify'), findsOneWidget);
    expect(find.text('Netflix'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 1));
    }
    await database.close();
  });
}

Future<void> _insertSubscription(
  AppDatabase database,
  String name,
  SubscriptionStatus status,
) {
  return database.subscriptionsDao.insert(
    SubscriptionsCompanion.insert(
      id: '',
      createdAt: 0,
      updatedAt: 0,
      name: name,
      priceMinor: 1299,
      currency: 'USD',
      cycleUnit: CycleUnit.month,
      firstBillDate: '2026-07-01',
      nextBillDate: '2026-07-15',
      status: status,
      colorHex: const Value('#7C5CFC'),
    ),
  );
}
