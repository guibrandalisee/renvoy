import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renvoy/data/db/database.dart';
import 'package:renvoy/data/db/database_provider.dart';
import 'package:renvoy/domain/models/enums.dart';
import 'package:renvoy/features/home/home_providers.dart';

void main() {
  test('soft delete then undo restores', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final id = await database.subscriptionsDao.insert(_subscription());

    await database.subscriptionsDao.softDelete(id);
    expect(await database.subscriptionsDao.watchAll().first, isEmpty);

    await database.subscriptionsDao.restore(id);
    final rows = await database.subscriptionsDao.watchAll().first;
    expect(rows.single.id, id);

    await database.close();
  });

  test('pause excludes subscription from home totals provider', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    addTearDown(database.close);

    final id = await database.subscriptionsDao.insert(_subscription());
    await container.read(activeSubscriptionsProvider.future);

    expect(container.read(monthlyTotalMinorProvider), 1000);

    await database.subscriptionsDao.setStatus(id, SubscriptionStatus.paused);
    container.invalidate(activeSubscriptionsProvider);
    await container.read(activeSubscriptionsProvider.future);

    expect(container.read(monthlyTotalMinorProvider), 0);
  });

  test('expired trial active subscriptions are counted in totals', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    addTearDown(database.close);

    await database.subscriptionsDao.insert(
      _subscription(trialEndDate: '2026-01-01'),
    );
    await container.read(activeSubscriptionsProvider.future);

    expect(container.read(monthlyTotalMinorProvider), 1000);
  });
}

SubscriptionsCompanion _subscription({String? trialEndDate}) {
  return SubscriptionsCompanion.insert(
    id: '',
    createdAt: 0,
    updatedAt: 0,
    name: 'Netflix',
    priceMinor: 1000,
    currency: 'USD',
    cycleUnit: CycleUnit.month,
    firstBillDate: '2026-07-08',
    nextBillDate: '2026-07-08',
    status: SubscriptionStatus.active,
    cycleCount: const Value(1),
    trialEndDate: trialEndDate == null
        ? const Value.absent()
        : Value(trialEndDate),
  );
}
