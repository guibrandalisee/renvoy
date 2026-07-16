import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:renvoy/l10n/app_localizations.dart';

import '../data/db/database_provider.dart';
import '../data/db/settings_keys.dart';
import '../data/notifications/reminder_scheduler.dart';
import '../domain/billing/renewal_service.dart';
import 'router.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

final themeModeProvider = StreamProvider<ThemeMode>((ref) {
  return ref
      .watch(settingsDaoProvider)
      .watchValue(SettingsKeys.themeMode)
      .map(_themeModeFromSetting);
});

final localeProvider = StreamProvider<Locale?>((ref) {
  return ref
      .watch(settingsDaoProvider)
      .watchValue(SettingsKeys.localeOverride)
      .map(_localeFromSetting);
});

final bootstrapProvider = FutureProvider<void>((ref) async {
  try {
    final settingsDao = ref.watch(settingsDaoProvider);
    final currentCurrency = await settingsDao.getValue(
      SettingsKeys.defaultCurrency,
    );
    if (currentCurrency == null || currentCurrency == 'USD') {
      final locale = PlatformDispatcher.instance.locale.toString();
      final currency =
          NumberFormat.simpleCurrency(locale: locale).currencyName ?? 'USD';
      await settingsDao.setValue(SettingsKeys.defaultCurrency, currency);
    }
    await ref.watch(renewalServiceProvider).rollForward(DateTime.now().toUtc());
    await ref.watch(reminderSchedulerProvider).resync();
  } catch (error, stackTrace) {
    debugPrint('Startup renewal roll-forward failed: $error');
    debugPrint('$stackTrace');
  }
});

class RenvoyApp extends ConsumerWidget {
  const RenvoyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(bootstrapProvider);
    final themeMode =
        ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;
    final locale = ref.watch(localeProvider).valueOrNull;

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      builder: (context, child) => CupertinoTheme(
        data: AppTheme.cupertino(
          brightness: Theme.of(context).brightness,
          colors: context.colors,
        ),
        child: child ?? const SizedBox.shrink(),
      ),
      routerConfig: appRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

ThemeMode _themeModeFromSetting(String? value) {
  return switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}

Locale? _localeFromSetting(String? value) {
  return switch (value) {
    'en' => const Locale('en'),
    'es' => const Locale('es'),
    'pt' => const Locale('pt'),
    _ => null,
  };
}
