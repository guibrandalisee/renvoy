import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:renvoy/l10n/app_localizations.dart';

class CurrencyDefaults {
  const CurrencyDefaults._();

  static String fromLocales(
    Iterable<Locale> locales, {
    String fallback = 'USD',
  }) {
    for (final locale in locales) {
      try {
        final currency = NumberFormat.simpleCurrency(
          locale: locale.toString(),
        ).currencyName?.toUpperCase();
        if (currency != null && RegExp(r'^[A-Z]{3}$').hasMatch(currency)) {
          return currency;
        }
      } on ArgumentError {
        // Try the next preferred locale when intl does not know this one.
      }
    }
    return fallback;
  }
}

class Money {
  const Money._();

  static String format(int minorUnits, String currencyCode, {String? locale}) {
    final format = NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
    );
    return format.format(minorUnits / 100);
  }
}

class Dates {
  const Dates._();

  static String short(DateTime date, String? locale) {
    return DateFormat.yMMMd(locale).format(date);
  }

  static String monthYear(DateTime date, String? locale) {
    return DateFormat.yMMMM(locale).format(date);
  }

  static String relative(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final difference = target.difference(today).inDays;

    return switch (difference) {
      0 => l10n.relativeToday,
      1 => l10n.relativeTomorrow,
      -1 => l10n.relativeYesterday,
      > 1 => l10n.relativeInDays(difference),
      < -1 => l10n.relativeDaysAgo(difference.abs()),
      _ => l10n.relativeToday,
    };
  }
}
