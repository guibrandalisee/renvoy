import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/db/database_provider.dart';
import '../../data/db/settings_keys.dart';
import '../../data/exchange_rates/exchange_rate_repository.dart';
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

class ConvertedMonthlySpending {
  const ConvertedMonthlySpending({
    required this.currencyCode,
    required this.totalMinor,
    required this.bySubscriptionId,
    required this.rateDate,
    required this.usesExchangeRates,
    required this.isStale,
  });

  final String currencyCode;
  final double totalMinor;
  final Map<String, double> bySubscriptionId;
  final DateTime rateDate;
  final bool usesExchangeRates;
  final bool isStale;
}

final exchangeRatesProvider = FutureProvider<ExchangeRates>((ref) async {
  final subscriptions = await ref.watch(activeSubscriptionsProvider.future);
  final baseCurrency = await ref.watch(defaultCurrencyProvider.future);
  return ref
      .watch(exchangeRateRepositoryProvider)
      .getLatest(
        baseCurrency: baseCurrency,
        currencies: subscriptions
            .map((subscription) => subscription.currency)
            .toSet(),
      );
});

final convertedMonthlySpendingProvider =
    FutureProvider<ConvertedMonthlySpending>((ref) async {
      final subscriptions = await ref.watch(activeSubscriptionsProvider.future);
      final rates = await ref.watch(exchangeRatesProvider.future);
      return convertMonthlySpending(subscriptions, rates);
    });

ConvertedMonthlySpending convertMonthlySpending(
  List<Subscription> subscriptions,
  ExchangeRates rates,
) {
  final amounts = <String, double>{};
  var total = 0.0;
  var usesExchangeRates = false;

  for (final subscription in subscriptions) {
    final monthly = monthlyEquivalentMinor(
      subscription.priceMinor,
      subscription.cycleUnit,
      subscription.cycleCount,
    );
    final converted = rates.convertToBase(monthly, subscription.currency);
    amounts[subscription.id] = converted;
    total += converted;
    usesExchangeRates |=
        subscription.currency.toUpperCase() != rates.baseCurrency;
  }

  return ConvertedMonthlySpending(
    currencyCode: rates.baseCurrency,
    totalMinor: total,
    bySubscriptionId: amounts,
    rateDate: rates.rateDate,
    usesExchangeRates: usesExchangeRates,
    isStale: rates.isStale,
  );
}
