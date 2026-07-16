import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renvoy/app/app.dart';
import 'package:renvoy/data/catalog/catalog_repository.dart';
import 'package:renvoy/data/db/database.dart';
import 'package:renvoy/data/db/database_provider.dart';

void main() {
  testWidgets('custom catalog search prefills the subscription name', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          bootstrapProvider.overrideWith((ref) async {}),
          catalogServicesProvider.overrideWith((ref) async => const []),
        ],
        child: const RenvoyApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Add subscription').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byType(EditableText), 'Chat GPT');
    await tester.pump();
    expect(find.text('Create custom: Chat GPT'), findsOneWidget);

    await tester.tap(find.text('Create custom: Chat GPT'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final fields = tester.widgetList<EditableText>(find.byType(EditableText));
    expect(fields.any((field) => field.controller.text == 'Chat GPT'), isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    for (var index = 0; index < 8; index++) {
      await tester.pump(const Duration(milliseconds: 1));
    }
  });
}
