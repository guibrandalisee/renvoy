import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/db/database_provider.dart';
import '../../data/db/settings_keys.dart';
import '../../domain/billing/billing_math.dart';
import '../../domain/models/group_node.dart';
import '../../domain/models/enums.dart';

final activeSubscriptionsProvider = StreamProvider<List<Subscription>>((ref) {
  return ref.watch(subscriptionsDaoProvider).watchAll().map((subscriptions) {
    return subscriptions
        .where(
          (subscription) => subscription.status == SubscriptionStatus.active,
        )
        .toList();
  });
});

final upcomingProvider = StreamProvider<List<Subscription>>((ref) {
  return ref.watch(subscriptionsDaoProvider).watchUpcoming(30);
});

final groupsTreeProvider = StreamProvider<List<GroupNode>>((ref) {
  return ref.watch(groupsDaoProvider).watchAllTree();
});

final monthlyEquivalentViewProvider = StreamProvider<bool>((ref) {
  return ref
      .watch(settingsDaoProvider)
      .watchValue(SettingsKeys.monthlyEquivalentView)
      .map((value) => value != 'yearly');
});

final defaultCurrencyProvider = StreamProvider<String>((ref) {
  return ref
      .watch(settingsDaoProvider)
      .watchValue(SettingsKeys.defaultCurrency)
      .map((value) => value ?? 'USD');
});

final monthlyTotalMinorProvider = Provider<double>((ref) {
  final subscriptions =
      ref.watch(activeSubscriptionsProvider).valueOrNull ?? [];

  // TODO: Phase-4 FX should convert mixed currencies before display.
  return subscriptions.fold<double>(0, (total, subscription) {
    return total +
        monthlyEquivalentMinor(
          subscription.priceMinor,
          subscription.cycleUnit,
          subscription.cycleCount,
        );
  });
});
