import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/database.dart';
import '../../../data/db/database_provider.dart';
import '../../../domain/models/enums.dart';

enum SubscriptionSort { nextRenewal, price, name }

final subscriptionSearchProvider = StateProvider<String>((ref) => '');
final subscriptionStatusFilterProvider = StateProvider<SubscriptionStatus?>(
  (ref) => null,
);
final subscriptionSortProvider = StateProvider<SubscriptionSort>(
  (ref) => SubscriptionSort.nextRenewal,
);

final subscriptionsListProvider = StreamProvider<List<Subscription>>((ref) {
  return ref.watch(subscriptionsDaoProvider).watchAll();
});

final filteredSubscriptionsProvider = Provider<List<Subscription>>((ref) {
  final subscriptions = ref.watch(subscriptionsListProvider).valueOrNull ?? [];
  final query = ref.watch(subscriptionSearchProvider).trim().toLowerCase();
  final status = ref.watch(subscriptionStatusFilterProvider);
  final sort = ref.watch(subscriptionSortProvider);

  final filtered = subscriptions.where((subscription) {
    final matchesQuery =
        query.isEmpty ||
        subscription.name.toLowerCase().contains(query) ||
        (subscription.notes ?? '').toLowerCase().contains(query);
    final matchesStatus = status == null || subscription.status == status;
    return matchesQuery && matchesStatus;
  }).toList();

  filtered.sort((a, b) {
    return switch (sort) {
      SubscriptionSort.nextRenewal => _byNextBill(a, b),
      SubscriptionSort.price => b.priceMinor.compareTo(a.priceMinor),
      SubscriptionSort.name => a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      ),
    };
  });
  return filtered;
});

int _byNextBill(Subscription a, Subscription b) {
  final date = a.nextBillDate.compareTo(b.nextBillDate);
  return date == 0 ? a.name.compareTo(b.name) : date;
}

class Debouncer {
  Debouncer(this.duration);

  final Duration duration;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
