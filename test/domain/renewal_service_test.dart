import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renvoy/data/db/database.dart';
import 'package:renvoy/domain/billing/renewal_service.dart';
import 'package:renvoy/domain/models/enums.dart';

void main() {
  late AppDatabase database;
  late RenewalService service;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    service = RenewalService(database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'rollForward updates overdue active subscriptions and expired trials',
    () async {
      final overdueId = await database.subscriptionsDao.insert(
        _subscription(
          name: 'Overdue',
          firstBillDate: '2026-01-31',
          nextBillDate: '2026-02-28',
        ),
      );
      final pausedId = await database.subscriptionsDao.insert(
        _subscription(
          name: 'Paused',
          firstBillDate: '2026-01-31',
          nextBillDate: '2026-02-28',
          status: SubscriptionStatus.paused,
        ),
      );
      final canceledId = await database.subscriptionsDao.insert(
        _subscription(
          name: 'Canceled',
          firstBillDate: '2026-01-31',
          nextBillDate: '2026-02-28',
          status: SubscriptionStatus.canceled,
        ),
      );
      final trialId = await database.subscriptionsDao.insert(
        _subscription(
          name: 'Trial',
          firstBillDate: '2026-01-01',
          nextBillDate: '2026-04-01',
          trialEndDate: '2026-02-28',
        ),
      );
      final currentId = await database.subscriptionsDao.insert(
        _subscription(
          name: 'Current',
          firstBillDate: '2026-01-01',
          nextBillDate: '2026-04-01',
        ),
      );

      final updated = await service.rollForward(DateTime.utc(2026, 3, 1));

      expect(updated, 2);

      final overdue = await database.subscriptionsDao
          .watchById(overdueId)
          .first;
      final paused = await database.subscriptionsDao.watchById(pausedId).first;
      final canceled = await database.subscriptionsDao
          .watchById(canceledId)
          .first;
      final trial = await database.subscriptionsDao.watchById(trialId).first;
      final current = await database.subscriptionsDao
          .watchById(currentId)
          .first;

      expect(overdue?.nextBillDate, '2026-03-31');
      expect(paused?.nextBillDate, '2026-02-28');
      expect(canceled?.nextBillDate, '2026-02-28');
      expect(trial?.trialEndDate, isNull);
      expect(trial?.status, SubscriptionStatus.active);
      expect(trial?.nextBillDate, '2026-04-01');
      expect(current?.nextBillDate, '2026-04-01');
    },
  );

  test('rollForward advances subscriptions left overdue for months', () async {
    final id = await database.subscriptionsDao.insert(
      _subscription(
        name: 'Long overdue',
        firstBillDate: '2025-01-31',
        nextBillDate: '2025-02-28',
      ),
    );

    final updated = await service.rollForward(DateTime.utc(2026, 7, 8));

    expect(updated, 1);
    final subscription = await database.subscriptionsDao.watchById(id).first;
    expect(subscription?.nextBillDate, '2026-07-31');
  });
}

SubscriptionsCompanion _subscription({
  required String name,
  required String firstBillDate,
  required String nextBillDate,
  String? trialEndDate,
  CycleUnit cycleUnit = CycleUnit.month,
  int cycleCount = 1,
  SubscriptionStatus status = SubscriptionStatus.active,
}) {
  return SubscriptionsCompanion(
    name: Value(name),
    priceMinor: const Value(999),
    currency: const Value('USD'),
    cycleUnit: Value(cycleUnit),
    cycleCount: Value(cycleCount),
    firstBillDate: Value(firstBillDate),
    nextBillDate: Value(nextBillDate),
    trialEndDate: trialEndDate == null
        ? const Value.absent()
        : Value(trialEndDate),
    status: Value(status),
  );
}
