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
              startDate: dateOnlyUtc(DateTime.now()),
              trialEndDate: null,
              groupId: null,
              paymentMethod: '',
              notes: '',
              manageUrl: '',
              useDefaultReminders: true,
              reminderDays: const [],
              serviceSlug: 'netflix',
              colorHex: '#E50914',
              iconName: 'si:netflix',
            ),
          );

      final rows = await database.subscriptionsDao.watchAll().first.timeout(
        const Duration(seconds: 2),
      );
      expect(rows, hasLength(1));
      expect(rows.single.name, 'Netflix');
      expect(rows.single.priceMinor, 1299);
      expect(rows.single.serviceSlug, 'netflix');
      expect(rows.single.colorHex, '#E50914');
      expect(rows.single.iconName, 'si:netflix');
      expect(
        _parseDate(
          rows.single.nextBillDate,
        ).isBefore(dateOnlyUtc(DateTime.now())),
        isFalse,
      );
    },
  );

  test(
    'free trial anchors the first charge and renewals at trial end',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(database)],
      );
      addTearDown(container.dispose);
      addTearDown(database.close);
      final startDate = dateOnlyUtc(DateTime.now());
      final trialEndDate = startDate.add(const Duration(days: 7));

      await container
          .read(subscriptionFormControllerProvider)
          .save(
            SubscriptionDraft(
              name: 'Trial service',
              priceMinor: 2790,
              currency: 'BRL',
              cycleUnit: CycleUnit.month,
              cycleCount: 1,
              startDate: startDate,
              trialEndDate: trialEndDate,
              groupId: null,
              paymentMethod: '',
              notes: '',
              manageUrl: '',
              useDefaultReminders: true,
              reminderDays: const [],
            ),
          );

      final subscription =
          (await database.subscriptionsDao.watchAll().first).single;
      final expectedStart = _formatDate(startDate);
      final expectedFirstCharge = _formatDate(trialEndDate);
      expect(subscription.startDate, expectedStart);
      expect(subscription.firstBillDate, expectedFirstCharge);
      expect(subscription.nextBillDate, expectedFirstCharge);
      expect(subscription.trialEndDate, expectedFirstCharge);
    },
  );
}

DateTime _parseDate(String value) {
  final parts = value.split('-').map(int.parse).toList();
  return DateTime.utc(parts[0], parts[1], parts[2]);
}

String _formatDate(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
