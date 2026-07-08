import 'package:flutter_test/flutter_test.dart';
import 'package:renvoy/data/backup/backup_service.dart';
import 'package:renvoy/data/db/database.dart';
import 'package:renvoy/domain/models/enums.dart';

void main() {
  test('buildSubscriptionsCsv quotes values and resolves groups', () {
    const subscription = Subscription(
      id: 'sub-1',
      createdAt: 1,
      updatedAt: 1,
      dirty: true,
      name: 'Plan, "Pro"\nTeam',
      priceMinor: 1234,
      currency: 'USD',
      cycleUnit: CycleUnit.month,
      cycleCount: 1,
      firstBillDate: '2026-01-01',
      nextBillDate: '2026-02-01',
      status: SubscriptionStatus.active,
      groupId: 'group-1',
      paymentMethod: 'Card',
      notes: 'Line 1\nLine 2',
      manageUrl: 'https://example.com',
    );

    final csv = buildSubscriptionsCsv(const [
      subscription,
    ], groupName: (id) => id == 'group-1' ? 'Work' : '');

    expect(csv, contains('"Plan, ""Pro""\nTeam"'));
    expect(csv, contains(',12.34,USD,month,2026-02-01,active,Work,'));
    expect(csv, contains('"Line 1\nLine 2"'));
  });
}
