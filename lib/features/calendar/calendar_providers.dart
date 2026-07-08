import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/db/database_provider.dart';
import '../../data/db/settings_keys.dart';
import '../../domain/billing/billing_math.dart';
import '../../domain/models/enums.dart';
import '../home/home_providers.dart';
import '../subscriptions/widgets/subscription_row.dart';

final visibleCalendarMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime.utc(now.year, now.month);
});

final selectedCalendarDayProvider = StateProvider<DateTime?>((ref) => null);

final firstDayOfWeekProvider = StreamProvider<int>((ref) {
  return ref
      .watch(settingsDaoProvider)
      .watchValue(SettingsKeys.firstDayOfWeek)
      .map((value) => int.tryParse(value ?? '1') ?? 1);
});

final renewalMapProvider = Provider<Map<DateTime, List<Subscription>>>((ref) {
  final subscriptions =
      ref.watch(activeSubscriptionsProvider).valueOrNull ?? [];
  final month = ref.watch(visibleCalendarMonthProvider);
  return buildRenewalMap(subscriptions, month);
});

Map<DateTime, List<Subscription>> buildRenewalMap(
  List<Subscription> subscriptions,
  DateTime visibleMonth,
) {
  final start = DateTime.utc(visibleMonth.year, visibleMonth.month);
  final end = DateTime.utc(visibleMonth.year, visibleMonth.month + 1);
  final map = <DateTime, List<Subscription>>{};

  for (final subscription in subscriptions) {
    if (subscription.status != SubscriptionStatus.active) {
      continue;
    }
    final firstBill = parseDate(subscription.firstBillDate);
    var next = nextBillOnOrAfter(
      firstBill,
      subscription.cycleUnit,
      subscription.cycleCount,
      start,
    );
    while (next.isBefore(end)) {
      map.putIfAbsent(next, () => []).add(subscription);
      next = addCycle(next, subscription.cycleUnit, subscription.cycleCount);
    }
  }

  return map;
}
