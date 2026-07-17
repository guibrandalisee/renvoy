import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:renvoy/data/exchange_rates/exchange_rate_api.dart';
import 'package:renvoy/data/exchange_rates/exchange_rate_repository.dart';

void main() {
  test(
    'Frankfurter client parses latest rates and requests selected quotes',
    () async {
      late Uri requestedUri;
      final client = MockClient((request) async {
        requestedUri = request.url;
        return http.Response(
          jsonEncode([
            {'date': '2026-07-15', 'base': 'BRL', 'quote': 'BRL', 'rate': 1},
            {'date': '2026-07-15', 'base': 'BRL', 'quote': 'USD', 'rate': 0.2},
            {'date': '2026-07-14', 'base': 'BRL', 'quote': 'EUR', 'rate': 0.17},
          ]),
          200,
        );
      });
      final api = FrankfurterExchangeRateApi(client: client);

      final response = await api.fetchLatest(
        baseCurrency: 'BRL',
        quoteCurrencies: const {'USD', 'EUR'},
      );

      expect(requestedUri.host, 'api.frankfurter.dev');
      expect(requestedUri.path, '/v2/rates');
      expect(requestedUri.queryParameters['base'], 'BRL');
      expect(requestedUri.queryParameters['quotes'], 'EUR,USD');
      expect(response.rates, {'BRL': 1, 'USD': 0.2, 'EUR': 0.17});
      expect(response.rateDate, DateTime.utc(2026, 7, 14));
    },
  );

  test('conversion turns quote units into the configured base currency', () {
    final rates = ExchangeRates(
      baseCurrency: 'BRL',
      rateDate: DateTime.utc(2026, 7, 15),
      rates: const {'BRL': 1, 'USD': 0.2},
      isStale: false,
    );

    expect(rates.convertToBase(1000, 'USD'), 5000);
    expect(rates.convertToBase(1000, 'BRL'), 1000);
  });

  test(
    'repository falls back to a complete stale cache while offline',
    () async {
      final store = _MemoryCacheStore();
      final now = DateTime.utc(2026, 7, 16, 12);
      store.values['exchangeRatesCache:BRL'] = jsonEncode({
        'fetchedAt': now.subtract(const Duration(days: 2)).toIso8601String(),
        'rateDate': '2026-07-14T00:00:00.000Z',
        'rates': {'BRL': 1, 'USD': 0.2},
      });
      final repository = ExchangeRateRepository(
        api: const _FailingApi(),
        cacheStore: store,
        now: () => now,
      );

      final rates = await repository.getLatest(
        baseCurrency: 'BRL',
        currencies: const {'BRL', 'USD'},
      );

      expect(rates.isStale, isTrue);
      expect(rates.convertToBase(1000, 'USD'), 5000);
    },
  );
}

class _MemoryCacheStore implements ExchangeRateCacheStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}

class _FailingApi implements ExchangeRateApi {
  const _FailingApi();

  @override
  Future<ExchangeRateApiResponse> fetchLatest({
    required String baseCurrency,
    required Set<String> quoteCurrencies,
  }) {
    throw const ExchangeRateApiException('offline');
  }
}
