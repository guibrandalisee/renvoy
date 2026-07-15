import 'package:flutter_test/flutter_test.dart';
import 'package:renvoy/data/db/database.dart';
import 'package:renvoy/domain/models/enums.dart';
import 'package:renvoy/features/calendar/calendar_providers.dart';

void main() {
  test('buildRenewalMap includes known bill date in visible month', () {
    final subscription = Subscription(
      id: 'sub_1',
      createdAt: 0,
      updatedAt: 0,
      dirty: true,
      name: 'Netflix',
      priceMinor: 1299,
      currency: 'USD',
      cycleUnit: CycleUnit.month,
      cycleCount: 1,
      firstBillDate: '2026-01-10',
      nextBillDate: '2026-07-10',
      status: SubscriptionStatus.active,
    );

    final map = buildRenewalMap([subscription], DateTime.utc(2026, 7));

    expect(map[DateTime.utc(2026, 7, 10)], [subscription]);
  });

  test('buildRenewalMap handles an empty month', () {
    final subscription = _subscription(
      firstBillDate: '2026-01-10',
      cycleUnit: CycleUnit.year,
    );

    final map = buildRenewalMap([subscription], DateTime.utc(2026, 2));

    expect(map, isEmpty);
  });

  test('buildRenewalMap handles February and monthly 31st anchors', () {
    final subscription = _subscription(firstBillDate: '2026-01-31');

    final map = buildRenewalMap([subscription], DateTime.utc(2026, 2));

    expect(map.keys, contains(DateTime.utc(2026, 2, 28)));
    expect(map[DateTime.utc(2026, 2, 28)], [subscription]);
  });

  test('free trial appears on its first charge date, not its start date', () {
    final subscription = Subscription(
      id: 'sub_1',
      createdAt: 0,
      updatedAt: 0,
      dirty: true,
      name: 'Trial service',
      priceMinor: 2790,
      currency: 'BRL',
      cycleUnit: CycleUnit.month,
      cycleCount: 1,
      startDate: '2026-07-10',
      firstBillDate: '2026-07-17',
      nextBillDate: '2026-07-17',
      trialEndDate: '2026-07-17',
      status: SubscriptionStatus.active,
    );

    final map = buildRenewalMap([subscription], DateTime.utc(2026, 7));

    expect(map[DateTime.utc(2026, 7, 10)], isNull);
    expect(map[DateTime.utc(2026, 7, 17)], [subscription]);
  });
}

Subscription _subscription({
  required String firstBillDate,
  CycleUnit cycleUnit = CycleUnit.month,
}) {
  return Subscription(
    id: 'sub_1',
    createdAt: 0,
    updatedAt: 0,
    dirty: true,
    name: 'Netflix',
    priceMinor: 1299,
    currency: 'USD',
    cycleUnit: cycleUnit,
    cycleCount: 1,
    firstBillDate: firstBillDate,
    nextBillDate: firstBillDate,
    status: SubscriptionStatus.active,
  );
}
