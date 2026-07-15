import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renvoy/app/app.dart';
import 'package:renvoy/data/db/database.dart';
import 'package:renvoy/data/db/database_provider.dart';
import 'package:renvoy/data/db/settings_keys.dart';

void main() {
  testWidgets('RenvoyApp follows the device locale by default', (tester) async {
    tester.binding.platformDispatcher.localesTestValue = const [Locale('es')];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          bootstrapProvider.overrideWith((ref) async {}),
        ],
        child: const RenvoyApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(Scaffold), findsWidgets);
    expect(find.text('Inicio'), findsWidgets);

    await database.settingsDao.setValue(SettingsKeys.localeOverride, 'pt');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Início'), findsWidgets);

    await database.settingsDao.setValue(SettingsKeys.localeOverride, 'system');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Inicio'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 1));
    }
  });
}
