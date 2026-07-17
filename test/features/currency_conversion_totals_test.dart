import 'package:flutter_test/flutter_test.dart';
import 'package:renvoy/data/db/database.dart';
import 'package:renvoy/data/exchange_rates/exchange_rate_repository.dart';
import 'package:renvoy/domain/models/enums.dart';
import 'package:renvoy/features/home/home_providers.dart';

void main() {
  test('mixed currency subscriptions are converted before being summed', () {
    final spending = convertMonthlySpending(
      [_subscription('brl', 5000, 'BRL'), _subscription('usd', 1000, 'USD')],
      ExchangeRates(
        baseCurrency: 'BRL',
        rateDate: DateTime.utc(2026, 7, 15),
        rates: const {'BRL': 1, 'USD': 0.2},
        isStale: false,
      ),
    );

    expect(spending.bySubscriptionId['brl'], 5000);
    expect(spending.bySubscriptionId['usd'], 5000);
    expect(spending.totalMinor, 10000);
    expect(spending.currencyCode, 'BRL');
    expect(spending.usesExchangeRates, isTrue);
  });
}

Subscription _subscription(String id, int priceMinor, String currency) {
  return Subscription(
    id: id,
    createdAt: 0,
    updatedAt: 0,
    dirty: true,
    name: id,
    priceMinor: priceMinor,
    currency: currency,
    cycleUnit: CycleUnit.month,
    cycleCount: 1,
    firstBillDate: '2026-07-01',
    nextBillDate: '2026-08-01',
    status: SubscriptionStatus.active,
  );
}
