import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:renvoy/core/formatters.dart';

void main() {
  test('CurrencyDefaults uses the region from the preferred locale', () {
    expect(CurrencyDefaults.fromLocales(const [Locale('pt', 'BR')]), 'BRL');
    expect(CurrencyDefaults.fromLocales(const [Locale('en', 'GB')]), 'GBP');
    expect(CurrencyDefaults.fromLocales(const [Locale('es', 'MX')]), 'MXN');
  });

  test('CurrencyDefaults falls back safely for unsupported locales', () {
    expect(CurrencyDefaults.fromLocales(const [Locale('zz')]), 'USD');
  });

  test('Money.format handles unknown currency codes', () {
    expect(() => Money.format(1234, 'XYZ', locale: 'en'), returnsNormally);
    expect(Money.format(1234, 'XYZ', locale: 'en'), contains('XYZ'));
  });
}
