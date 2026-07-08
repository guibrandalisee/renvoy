import 'package:flutter_test/flutter_test.dart';
import 'package:renvoy/core/formatters.dart';

void main() {
  test('Money.format handles unknown currency codes', () {
    expect(() => Money.format(1234, 'XYZ', locale: 'en'), returnsNormally);
    expect(Money.format(1234, 'XYZ', locale: 'en'), contains('XYZ'));
  });
}
