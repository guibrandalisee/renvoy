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
  testWidgets('subscription referencing deleted group renders as no group', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final groupId = await database.groupsDao.insert(
      GroupsCompanion.insert(
        id: '',
        createdAt: 0,
        updatedAt: 0,
        name: 'Deleted group',
        icon: 'category_outlined',
        color: '#7C5CFC',
      ),
    );
    await database.subscriptionsDao.insert(
      SubscriptionsCompanion.insert(
        id: '',
        createdAt: 0,
        updatedAt: 0,
        name: 'Netflix',
        priceMinor: 1299,
        currency: 'USD',
        cycleUnit: CycleUnit.month,
        firstBillDate: '2026-07-01',
        nextBillDate: '2026-07-15',
        status: SubscriptionStatus.active,
        groupId: Value(groupId),
      ),
    );
    await database.groupsDao.softDelete(groupId);

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

    expect(find.text('Netflix'), findsOneWidget);

    await tester.tap(find.text('Netflix'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('No group'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 1));
    }
  });
}
