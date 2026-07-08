import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renvoy/data/db/database.dart';
import 'package:renvoy/data/db/database_provider.dart';
import 'package:renvoy/domain/billing/billing_math.dart';
import 'package:renvoy/domain/models/enums.dart';
import 'package:renvoy/features/subscriptions/edit/subscription_form_controller.dart';

void main() {
  test(
    'create form controller saves subscription with minor units and next bill',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(database)],
      );
      addTearDown(container.dispose);
      addTearDown(database.close);

      await container
          .read(subscriptionFormControllerProvider)
          .save(
            SubscriptionDraft(
              name: 'Netflix',
              priceMinor: 1299,
              currency: 'USD',
              cycleUnit: CycleUnit.month,
              cycleCount: 1,
              firstBillDate: dateOnlyUtc(DateTime.now()),
              trialEndDate: null,
              groupId: null,
              paymentMethod: '',
              notes: '',
              manageUrl: '',
              useDefaultReminders: true,
              reminderDays: const [],
            ),
          );

      final rows = await database.subscriptionsDao.watchAll().first.timeout(
        const Duration(seconds: 2),
      );
      expect(rows, hasLength(1));
      expect(rows.single.name, 'Netflix');
      expect(rows.single.priceMinor, 1299);
      expect(
        _parseDate(
          rows.single.nextBillDate,
        ).isBefore(dateOnlyUtc(DateTime.now())),
        isFalse,
      );
    },
  );
}

DateTime _parseDate(String value) {
  final parts = value.split('-').map(int.parse).toList();
  return DateTime.utc(parts[0], parts[1], parts[2]);
}
