import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database_provider.dart';
import '../db/settings_keys.dart';
import 'exchange_rate_api.dart';

const exchangeRateCacheTtl = Duration(hours: 24);

class ExchangeRates {
  const ExchangeRates({
    required this.baseCurrency,
    required this.rateDate,
    required this.rates,
    required this.isStale,
  });

  final String baseCurrency;
  final DateTime rateDate;
  final Map<String, double> rates;
  final bool isStale;

  double convertToBase(double amount, String sourceCurrency) {
    final source = sourceCurrency.toUpperCase();
    if (source == baseCurrency) {
      return amount;
    }
    final quotePerBase = rates[source];
    if (quotePerBase == null || quotePerBase <= 0) {
      throw ExchangeRateApiException('No exchange rate for $source.');
    }
    return amount / quotePerBase;
  }

  bool covers(Iterable<String> currencies) {
    return currencies.every(
      (currency) =>
          currency.toUpperCase() == baseCurrency ||
          rates.containsKey(currency.toUpperCase()),
    );
  }

  ExchangeRates stale() => ExchangeRates(
    baseCurrency: baseCurrency,
    rateDate: rateDate,
    rates: rates,
    isStale: true,
  );
}

abstract interface class ExchangeRateCacheStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class SettingsExchangeRateCacheStore implements ExchangeRateCacheStore {
  SettingsExchangeRateCacheStore(this._ref);

  final Ref _ref;

  @override
  Future<String?> read(String key) =>
      _ref.read(settingsDaoProvider).getValue(key);

  @override
  Future<void> write(String key, String value) =>
      _ref.read(settingsDaoProvider).setValue(key, value);
}

class ExchangeRateRepository {
  ExchangeRateRepository({
    required ExchangeRateApi api,
    required ExchangeRateCacheStore cacheStore,
    DateTime Function()? now,
  }) : _api = api,
       _cacheStore = cacheStore,
       _now = now ?? (() => DateTime.now().toUtc());

  final ExchangeRateApi _api;
  final ExchangeRateCacheStore _cacheStore;
  final DateTime Function() _now;

  Future<ExchangeRates> getLatest({
    required String baseCurrency,
    required Set<String> currencies,
  }) async {
    final base = baseCurrency.toUpperCase();
    final normalized =
        currencies.map((currency) => currency.toUpperCase()).toSet()..add(base);
    if (normalized.length == 1) {
      return ExchangeRates(
        baseCurrency: base,
        rateDate: _now(),
        rates: {base: 1},
        isStale: false,
      );
    }

    final cached = await _readCache(base);
    final now = _now();
    if (cached != null &&
        cached.rates.covers(normalized) &&
        now.difference(cached.fetchedAt) < exchangeRateCacheTtl) {
      return cached.rates;
    }

    final requested = <String>{...normalized};
    if (cached != null) {
      requested.addAll(cached.rates.rates.keys);
    }

    try {
      final response = await _api.fetchLatest(
        baseCurrency: base,
        quoteCurrencies: requested,
      );
      final rates = ExchangeRates(
        baseCurrency: response.baseCurrency,
        rateDate: response.rateDate,
        rates: response.rates,
        isStale: false,
      );
      await _writeCache(rates, now);
      return rates;
    } on Object {
      if (cached != null && cached.rates.covers(normalized)) {
        return cached.rates.stale();
      }
      rethrow;
    }
  }

  Future<_CachedExchangeRates?> _readCache(String base) async {
    final raw = await _cacheStore.read(SettingsKeys.exchangeRatesCache(base));
    if (raw == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }
      final fetchedAt = DateTime.parse(decoded['fetchedAt'] as String).toUtc();
      final rateDate = DateTime.parse(decoded['rateDate'] as String).toUtc();
      final jsonRates = decoded['rates'];
      if (jsonRates is! Map) {
        return null;
      }
      final rates = <String, double>{};
      for (final entry in jsonRates.entries) {
        if (entry.key is String && entry.value is num && entry.value > 0) {
          rates[(entry.key as String).toUpperCase()] = (entry.value as num)
              .toDouble();
        }
      }
      final normalizedBase = base.toUpperCase();
      rates[normalizedBase] = 1;
      return _CachedExchangeRates(
        fetchedAt: fetchedAt,
        rates: ExchangeRates(
          baseCurrency: normalizedBase,
          rateDate: rateDate,
          rates: rates,
          isStale: false,
        ),
      );
    } on Object {
      return null;
    }
  }

  Future<void> _writeCache(ExchangeRates rates, DateTime fetchedAt) {
    return _cacheStore.write(
      SettingsKeys.exchangeRatesCache(rates.baseCurrency),
      jsonEncode({
        'fetchedAt': fetchedAt.toIso8601String(),
        'rateDate': rates.rateDate.toIso8601String(),
        'rates': rates.rates,
      }),
    );
  }
}

class _CachedExchangeRates {
  const _CachedExchangeRates({required this.fetchedAt, required this.rates});

  final DateTime fetchedAt;
  final ExchangeRates rates;
}

final exchangeRateApiProvider = Provider<FrankfurterExchangeRateApi>((ref) {
  final api = FrankfurterExchangeRateApi();
  ref.onDispose(api.dispose);
  return api;
});

final exchangeRateRepositoryProvider = Provider<ExchangeRateRepository>((ref) {
  return ExchangeRateRepository(
    api: ref.watch(exchangeRateApiProvider),
    cacheStore: SettingsExchangeRateCacheStore(ref),
  );
});
