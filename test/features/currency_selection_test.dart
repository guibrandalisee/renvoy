import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renvoy/app/theme/app_theme.dart';
import 'package:renvoy/data/db/database.dart';
import 'package:renvoy/data/db/database_provider.dart';
import 'package:renvoy/data/db/settings_keys.dart';
import 'package:renvoy/features/subscriptions/edit/subscription_form_screen.dart';
import 'package:renvoy/l10n/app_localizations.dart';

void main() {
  testWidgets('new subscription form keeps USD selected after rebuilding', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database.settingsDao.setValue(SettingsKeys.defaultCurrency, 'BRL');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SubscriptionFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BRL'), findsOneWidget);
    await tester.tap(find.text('BRL'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USD'));
    await tester.pumpAndSettle();

    expect(find.text('USD'), findsOneWidget);
    expect(find.text('BRL'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 1));
    }
  });
}
