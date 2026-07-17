import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renvoy/app/theme/app_theme.dart';
import 'package:renvoy/data/db/database.dart';
import 'package:renvoy/domain/models/enums.dart';
import 'package:renvoy/domain/models/group_node.dart';
import 'package:renvoy/features/home/widgets/spend_by_group_card.dart';
import 'package:renvoy/l10n/app_localizations.dart';

void main() {
  testWidgets('spend breakdown keeps subgroups visible under their parent', (
    tester,
  ) async {
    final entertainment = _group('entertainment', 'Entertainment', '#7C5CFC');
    final streaming = _group(
      'streaming',
      'Streaming',
      '#22C55E',
      parentId: entertainment.id,
    );
    final games = _group(
      'games',
      'Games',
      '#F59E0B',
      parentId: entertainment.id,
    );
    final groups = [
      GroupNode(
        group: entertainment,
        subscriptionCount: 2,
        children: [
          GroupNode(group: streaming, children: const [], subscriptionCount: 1),
          GroupNode(group: games, children: const [], subscriptionCount: 1),
        ],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: SpendByGroupCard(
              subscriptions: [
                _subscription('Netflix', 2999, streaming.id),
                _subscription('Xbox Game Pass', 4990, games.id),
              ],
              groups: groups,
              totalMonthlyMinor: 7989,
              monthlyBySubscriptionId: const {
                'Netflix': 2999,
                'Xbox Game Pass': 4990,
              },
              currencyCode: 'USD',
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Entertainment'), findsOneWidget);
    expect(find.text('Streaming'), findsOneWidget);
    expect(find.text('Games'), findsOneWidget);
    expect(find.text(r'$29.99'), findsOneWidget);
    expect(find.text(r'$49.90'), findsOneWidget);
  });
}

Group _group(String id, String name, String color, {String? parentId}) {
  return Group(
    id: id,
    createdAt: 0,
    updatedAt: 0,
    dirty: true,
    name: name,
    icon: 'category_outlined',
    color: color,
    parentId: parentId,
    position: 0,
  );
}

Subscription _subscription(String name, int priceMinor, String groupId) {
  return Subscription(
    id: name,
    createdAt: 0,
    updatedAt: 0,
    dirty: true,
    name: name,
    priceMinor: priceMinor,
    currency: 'USD',
    cycleUnit: CycleUnit.month,
    cycleCount: 1,
    firstBillDate: '2026-07-01',
    nextBillDate: '2026-07-20',
    status: SubscriptionStatus.active,
    groupId: groupId,
  );
}
