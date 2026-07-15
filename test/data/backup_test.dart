import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renvoy/data/backup/backup_service.dart';
import 'package:renvoy/data/db/database.dart';
import 'package:renvoy/domain/models/enums.dart';

void main() {
  test('export import roundtrip reproduces active rows', () async {
    final source = AppDatabase.forTesting(NativeDatabase.memory());
    final target = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(source.close);
    addTearDown(target.close);
    await _clear(source);
    await _clear(target);

    await _seedBackupRows(source);

    final json = await BackupService(source).exportJson();
    final preview = await BackupService(target).importJson(json);

    expect(preview.subscriptions, 1);
    expect(preview.groups, 1);
    expect(preview.priceHistory, 1);
    expect(preview.reminderRules, 1);

    final subscriptions = await target.subscriptionsDao.watchAll().first;
    final groups = await target.groupsDao.watchAllTree().first;
    final rules = await target.reminderRulesDao.watchGlobal().first;

    expect(subscriptions, hasLength(1));
    expect(subscriptions.single.name, 'Netflix');
    expect(subscriptions.single.priceMinor, 1299);
    expect(groups.single.group.name, 'Streaming');
    expect(rules.single.daysBefore, 3);
  });

  test('soft deleted rows are excluded from export', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await _clear(database);

    await _seedBackupRows(database);
    await database.subscriptionsDao.softDelete('sub-1');

    final preview = await BackupService(
      database,
    ).previewImport(await BackupService(database).exportJson());

    expect(preview.subscriptions, 0);
    expect(preview.groups, 1);
  });

  test('invalid json and wrong format are rejected', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final service = BackupService(database);

    expect(() => service.previewImport('not json'), throwsFormatException);
    expect(
      () => service.previewImport('{"format":"other","version":1,"data":{}}'),
      throwsFormatException,
    );
  });

  test('import overwrites existing id without duplicating', () async {
    final source = AppDatabase.forTesting(NativeDatabase.memory());
    final target = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(source.close);
    addTearDown(target.close);
    await _clear(source);
    await _clear(target);

    await _seedBackupRows(source, name: 'Imported');
    await _seedBackupRows(target, name: 'Existing');

    await BackupService(
      target,
    ).importJson(await BackupService(source).exportJson());

    final subscriptions = await target.subscriptionsDao.watchAll().first;
    expect(subscriptions, hasLength(1));
    expect(subscriptions.single.name, 'Imported');
  });

  test('import accepts groups whose parent is missing from backup', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await _clear(database);
    final source = _backupJson(
      groups: [
        {
          'id': 'group-orphan',
          'createdAt': 0,
          'updatedAt': 0,
          'deletedAt': null,
          'dirty': true,
          'name': 'Orphan',
          'icon': 'category_outlined',
          'color': '#7C5CFC',
          'parentId': 'missing-group',
          'position': 0,
        },
      ],
    );

    final preview = await BackupService(database).importJson(source);
    final tree = await database.groupsDao.watchAllTree().first;

    expect(preview.groups, 1);
    expect(tree.map((node) => node.group.id), contains('group-orphan'));
  });

  test('import normalizes trial dates from version 1 backups', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await _clear(database);
    final source = _backupJson(
      version: 1,
      subscriptions: [
        {
          'id': 'legacy-trial',
          'createdAt': 0,
          'updatedAt': 0,
          'deletedAt': null,
          'dirty': true,
          'name': 'Legacy trial',
          'serviceSlug': null,
          'priceMinor': 2790,
          'currency': 'BRL',
          'cycleUnit': 'month',
          'cycleCount': 1,
          'firstBillDate': '2026-07-10',
          'nextBillDate': '2026-07-17',
          'trialEndDate': '2026-07-17',
          'status': 'active',
          'paymentMethod': null,
          'notes': null,
          'manageUrl': null,
          'groupId': null,
          'colorHex': null,
          'iconName': null,
        },
      ],
    );

    await BackupService(database).importJson(source);

    final subscription =
        (await database.subscriptionsDao.watchAll().first).single;
    expect(subscription.startDate, '2026-07-10');
    expect(subscription.firstBillDate, '2026-07-17');
    expect(subscription.nextBillDate, '2026-07-17');
  });
}

Future<void> _clear(AppDatabase database) async {
  await database
      .update(database.reminderRules)
      .write(const ReminderRulesCompanion(deletedAt: Value(1)));
  await database
      .update(database.priceHistory)
      .write(const PriceHistoryCompanion(deletedAt: Value(1)));
  await database
      .update(database.subscriptions)
      .write(const SubscriptionsCompanion(deletedAt: Value(1)));
  await database
      .update(database.groups)
      .write(const GroupsCompanion(deletedAt: Value(1)));
}

Future<void> _seedBackupRows(
  AppDatabase database, {
  String name = 'Netflix',
}) async {
  const now = 1000;
  await database
      .into(database.groups)
      .insert(
        GroupsCompanion.insert(
          id: 'group-1',
          createdAt: now,
          updatedAt: now,
          name: 'Streaming',
          icon: 'play',
          color: '#7C5CFC',
        ),
      );
  await database
      .into(database.subscriptions)
      .insert(
        SubscriptionsCompanion.insert(
          id: 'sub-1',
          createdAt: now,
          updatedAt: now,
          name: name,
          priceMinor: 1299,
          currency: 'USD',
          cycleUnit: CycleUnit.month,
          startDate: const Value('2026-01-01'),
          firstBillDate: '2026-01-01',
          nextBillDate: '2026-08-01',
          status: SubscriptionStatus.active,
          groupId: const Value('group-1'),
        ),
      );
  await database
      .into(database.priceHistory)
      .insert(
        PriceHistoryCompanion.insert(
          id: 'price-1',
          createdAt: now,
          updatedAt: now,
          subscriptionId: 'sub-1',
          changedAt: now,
          oldPriceMinor: 999,
          newPriceMinor: 1299,
        ),
      );
  await database
      .into(database.reminderRules)
      .insert(
        ReminderRulesCompanion.insert(
          id: 'rule-1',
          createdAt: now,
          updatedAt: now,
          daysBefore: 3,
        ),
      );
}

String _backupJson({
  int version = BackupService.currentVersion,
  List<Map<String, Object?>> subscriptions = const [],
  List<Map<String, Object?>> groups = const [],
}) {
  return jsonEncode({
    'format': BackupService.format,
    'version': version,
    'exported_at': '2026-07-08T00:00:00.000Z',
    'data': {
      'subscriptions': subscriptions,
      'groups': groups,
      'price_history': const [],
      'reminder_rules': const [],
    },
  });
}
