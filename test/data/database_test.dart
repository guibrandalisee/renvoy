import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renvoy/data/db/database.dart';
import 'package:renvoy/data/db/settings_keys.dart';
import 'package:renvoy/domain/models/enums.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('seed data is present after open', () async {
    final groups = await database.groupsDao.watchAllTree().first;
    final globalRules = await database.reminderRulesDao.watchGlobal().first;

    expect(groups.map((node) => node.group.name), contains('Entertainment'));
    expect(
      groups
          .firstWhere((node) => node.group.name == 'Entertainment')
          .children
          .map((node) => node.group.name),
      containsAll(['Streaming', 'Music', 'Games']),
    );
    expect(globalRules.map((rule) => rule.daysBefore), [0, 3]);
    expect(
      await database.settingsDao.getValue(SettingsKeys.defaultCurrency),
      null,
    );
  });

  test('subscription insert emits through watchAll', () async {
    final expectation = expectLater(
      database.subscriptionsDao.watchAll(),
      emitsThrough(hasLength(1)),
    );

    await database.subscriptionsDao.insert(_subscription(name: 'Netflix'));

    await expectation;
  });

  test('softDelete excludes subscription from watchers', () async {
    final id = await database.subscriptionsDao.insert(
      _subscription(name: 'Dropbox'),
    );

    expect(await database.subscriptionsDao.watchAll().first, hasLength(1));

    await database.subscriptionsDao.softDelete(id);

    expect(await database.subscriptionsDao.watchAll().first, isEmpty);
  });

  test('duplicate creates a new row with copy suffix', () async {
    final id = await database.subscriptionsDao.insert(
      _subscription(name: 'Figma'),
    );

    final copyId = await database.subscriptionsDao.duplicate(id);
    final rows = await database.subscriptionsDao.watchAll().first;

    expect(copyId, isNot(id));
    expect(rows.map((row) => row.name), containsAll(['Figma', 'Figma copy']));
  });

  test('watchUpcoming filters by window and status', () async {
    final today = DateTime.now().toUtc();

    await database.subscriptionsDao.insert(
      _subscription(
        name: 'Soon',
        nextBillDate: _date(today.add(const Duration(days: 2))),
      ),
    );
    await database.subscriptionsDao.insert(
      _subscription(
        name: 'Later',
        nextBillDate: _date(today.add(const Duration(days: 10))),
      ),
    );
    await database.subscriptionsDao.insert(
      _subscription(
        name: 'Paused',
        nextBillDate: _date(today.add(const Duration(days: 1))),
        status: SubscriptionStatus.paused,
      ),
    );

    final rows = await database.subscriptionsDao.watchUpcoming(3).first;

    expect(rows.map((row) => row.name), ['Soon']);
  });

  test('group cascade delete soft-deletes subscriptions', () async {
    final groupId = await database.groupsDao.insert(
      const GroupsCompanion(
        name: Value('Education'),
        icon: Value('book'),
        color: Value('#22C55E'),
      ),
    );
    await database.subscriptionsDao.insert(
      _subscription(name: 'Course', groupId: groupId),
    );

    await database.groupsDao.deleteGroupCascade(groupId);

    expect(await database.subscriptionsDao.watchAll().first, isEmpty);
  });

  test('settings set/get roundtrip', () async {
    await database.settingsDao.setValue(SettingsKeys.themeMode, 'dark');

    expect(await database.settingsDao.getValue(SettingsKeys.themeMode), 'dark');
    expect(
      await database.settingsDao.watchValue(SettingsKeys.themeMode).first,
      'dark',
    );
  });
}

SubscriptionsCompanion _subscription({
  required String name,
  String? nextBillDate,
  String? groupId,
  SubscriptionStatus status = SubscriptionStatus.active,
}) {
  final today = _date(DateTime.now().toUtc());
  return SubscriptionsCompanion(
    name: Value(name),
    priceMinor: const Value(999),
    currency: const Value('USD'),
    cycleUnit: const Value(CycleUnit.month),
    firstBillDate: Value(today),
    nextBillDate: Value(nextBillDate ?? today),
    status: Value(status),
    groupId: Value(groupId),
  );
}

String _date(DateTime value) {
  final utc = value.toUtc();
  final year = utc.year.toString().padLeft(4, '0');
  final month = utc.month.toString().padLeft(2, '0');
  final day = utc.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
