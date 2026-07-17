import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renvoy/l10n/app_localizations.dart';

void main() {
  test('generated localizations include English, Spanish, and Portuguese', () {
    expect(AppLocalizations.supportedLocales, const [
      Locale('en'),
      Locale('es'),
      Locale('pt'),
    ]);

    final spanish = lookupAppLocalizations(const Locale('es'));
    expect(spanish.navSettings, 'Ajustes');
    expect(spanish.activeCount(1), '1 suscripción activa');
    expect(spanish.activeCount(3), '3 suscripciones activas');
    expect(lookupAppLocalizations(const Locale('pt')).relativeToday, 'hoje');
  });
}
