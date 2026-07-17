import 'dart:convert';

import 'package:http/http.dart' as http;

class ExchangeRateApiException implements Exception {
  const ExchangeRateApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ExchangeRateApiException: $message';
}

class ExchangeRateApiResponse {
  const ExchangeRateApiResponse({
    required this.baseCurrency,
    required this.rateDate,
    required this.rates,
  });

  final String baseCurrency;
  final DateTime rateDate;
  final Map<String, double> rates;
}

abstract interface class ExchangeRateApi {
  Future<ExchangeRateApiResponse> fetchLatest({
    required String baseCurrency,
    required Set<String> quoteCurrencies,
  });
}

class FrankfurterExchangeRateApi implements ExchangeRateApi {
  FrankfurterExchangeRateApi({http.Client? client}) : _client = client;

  http.Client? _client;

  @override
  Future<ExchangeRateApiResponse> fetchLatest({
    required String baseCurrency,
    required Set<String> quoteCurrencies,
  }) async {
    final base = baseCurrency.toUpperCase();
    final quotes =
        quoteCurrencies
            .map((currency) => currency.toUpperCase())
            .where((currency) => currency != base)
            .toSet()
            .toList()
          ..sort();

    if (quotes.isEmpty) {
      return ExchangeRateApiResponse(
        baseCurrency: base,
        rateDate: DateTime.now().toUtc(),
        rates: {base: 1},
      );
    }

    final uri = Uri.https('api.frankfurter.dev', '/v2/rates', {
      'base': base,
      'quotes': quotes.join(','),
    });

    try {
      final response = await (_client ??= http.Client())
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw ExchangeRateApiException(
          'Exchange-rate request failed.',
          statusCode: response.statusCode,
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const ExchangeRateApiException(
          'Exchange-rate response has an invalid shape.',
        );
      }

      final rates = <String, double>{base: 1};
      DateTime? rateDate;
      for (final item in decoded.whereType<Map>()) {
        final quote = item['quote'];
        final rate = item['rate'];
        final date = item['date'];
        if (quote is! String || rate is! num || rate <= 0 || date is! String) {
          continue;
        }
        rates[quote.toUpperCase()] = rate.toDouble();
        final parsedDate = _parseUtcDate(date);
        if (parsedDate != null &&
            (rateDate == null || parsedDate.isBefore(rateDate))) {
          rateDate = parsedDate;
        }
      }

      final missing = quotes.where((currency) => !rates.containsKey(currency));
      if (missing.isNotEmpty || rateDate == null) {
        throw const ExchangeRateApiException(
          'Exchange-rate response is incomplete.',
        );
      }

      return ExchangeRateApiResponse(
        baseCurrency: base,
        rateDate: rateDate,
        rates: rates,
      );
    } on ExchangeRateApiException {
      rethrow;
    } on Object catch (error) {
      throw ExchangeRateApiException('Unable to load exchange rates: $error');
    }
  }

  void dispose() => _client?.close();
}

DateTime? _parseUtcDate(String value) {
  final parts = value.split('-');
  if (parts.length != 3) {
    return null;
  }
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) {
    return null;
  }
  return DateTime.utc(year, month, day);
}
