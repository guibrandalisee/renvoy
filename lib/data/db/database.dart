import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/enums.dart';
import '../../domain/models/group_node.dart';
import 'converters.dart';
import 'settings_keys.dart';
import 'tables.dart';

part 'daos/groups_dao.dart';
part 'daos/price_history_dao.dart';
part 'daos/reminder_rules_dao.dart';
part 'daos/settings_dao.dart';
part 'daos/subscriptions_dao.dart';
part 'database.g.dart';

@DriftDatabase(
  tables: [Subscriptions, Groups, PriceHistory, ReminderRules, Settings],
  daos: [
    SubscriptionsDao,
    GroupsDao,
    PriceHistoryDao,
    ReminderRulesDao,
    SettingsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedDefaults();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(subscriptions, subscriptions.startDate);
        await customStatement(
          'UPDATE subscriptions SET start_date = first_bill_date',
        );
        await customStatement(
          'UPDATE subscriptions '
          'SET first_bill_date = trial_end_date, '
          'next_bill_date = trial_end_date '
          'WHERE trial_end_date IS NOT NULL',
        );
      }
    },
  );

  Future<void> _seedDefaults() async {
    final now = _nowMs();

    final entertainmentId = _newId();
    await batch((batch) {
      batch.insertAll(reminderRules, [
        ReminderRulesCompanion.insert(
          id: _newId(),
          createdAt: now,
          updatedAt: now,
          daysBefore: 3,
        ),
        ReminderRulesCompanion.insert(
          id: _newId(),
          createdAt: now,
          updatedAt: now,
          daysBefore: 0,
        ),
      ]);

      batch.insertAll(groups, [
        GroupsCompanion.insert(
          id: entertainmentId,
          createdAt: now,
          updatedAt: now,
          name: 'Entertainment',
          icon: 'movie',
          color: '#7C5CFC',
        ),
        GroupsCompanion.insert(
          id: _newId(),
          createdAt: now,
          updatedAt: now,
          name: 'Streaming',
          icon: 'play',
          color: '#8B7CFC',
          parentId: Value(entertainmentId),
        ),
        GroupsCompanion.insert(
          id: _newId(),
          createdAt: now,
          updatedAt: now,
          name: 'Music',
          icon: 'music',
          color: '#9C8CFD',
          parentId: Value(entertainmentId),
        ),
        GroupsCompanion.insert(
          id: _newId(),
          createdAt: now,
          updatedAt: now,
          name: 'Games',
          icon: 'device-gamepad',
          color: '#AD9DFE',
          parentId: Value(entertainmentId),
        ),
        GroupsCompanion.insert(
          id: _newId(),
          createdAt: now,
          updatedAt: now,
          name: 'Work',
          icon: 'briefcase',
          color: '#38BDF8',
        ),
        GroupsCompanion.insert(
          id: _newId(),
          createdAt: now,
          updatedAt: now,
          name: 'Health',
          icon: 'heart',
          color: '#34D399',
        ),
        GroupsCompanion.insert(
          id: _newId(),
          createdAt: now,
          updatedAt: now,
          name: 'Utilities',
          icon: 'bolt',
          color: '#FBBF24',
        ),
      ]);

      batch.insertAll(settings, [
        SettingsCompanion.insert(
          key: SettingsKeys.defaultCurrency,
          value: 'USD',
        ),
        SettingsCompanion.insert(key: SettingsKeys.themeMode, value: 'system'),
        SettingsCompanion.insert(key: SettingsKeys.firstDayOfWeek, value: '1'),
        SettingsCompanion.insert(
          key: SettingsKeys.defaultReminderDays,
          value: '3,0',
        ),
      ]);
    });
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'renvoy');
}

int _nowMs() => DateTime.now().toUtc().millisecondsSinceEpoch;

String _newId() => const Uuid().v7();
