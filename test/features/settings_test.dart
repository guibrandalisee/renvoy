import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:renvoy/app/theme/app_theme.dart';
import 'package:renvoy/data/db/database.dart';
import 'package:renvoy/data/db/database_provider.dart';
import 'package:renvoy/data/db/settings_keys.dart';
import 'package:renvoy/features/settings/settings_screen.dart';
import 'package:renvoy/l10n/app_localizations.dart';

void main() {
  testWidgets('settings screen renders rows and persists theme change', (
    tester,
  ) async {
    PackageInfo.setMockInitialValues(
      appName: 'Renvoy',
      packageName: 'dev.g22.renvoy',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Currency'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Export backup'), findsOneWidget);

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(await database.settingsDao.getValue(SettingsKeys.themeMode), 'dark');

    await tester.scrollUntilVisible(find.text('1.0.0 (1)'), 500);
    expect(find.text('1.0.0 (1)'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 1));
    }
  });
}
