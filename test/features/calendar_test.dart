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
}
