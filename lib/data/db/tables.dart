import 'package:drift/drift.dart';

import 'converters.dart';

abstract class SyncTable extends Table {
  TextColumn get id => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Subscriptions extends SyncTable {
  TextColumn get name => text()();
  TextColumn get serviceSlug => text().nullable()();
  IntColumn get priceMinor => integer()();
  TextColumn get currency => text().withLength(min: 3, max: 3)();
  TextColumn get cycleUnit => text().map(const CycleUnitConverter())();
  IntColumn get cycleCount => integer().withDefault(const Constant(1))();
  TextColumn get firstBillDate => text()();
  TextColumn get nextBillDate => text()();
  TextColumn get trialEndDate => text().nullable()();
  TextColumn get status => text().map(const SubscriptionStatusConverter())();
  TextColumn get paymentMethod => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get manageUrl => text().nullable()();
  TextColumn get groupId => text().nullable().references(Groups, #id)();
  TextColumn get colorHex => text().nullable()();
  TextColumn get iconName => text().nullable()();
}

class Groups extends SyncTable {
  TextColumn get name => text()();
  TextColumn get icon => text()();
  TextColumn get color => text()();
  TextColumn get parentId => text().nullable().references(Groups, #id)();
  IntColumn get position => integer().withDefault(const Constant(0))();
}

class PriceHistory extends SyncTable {
  TextColumn get subscriptionId => text().references(Subscriptions, #id)();
  IntColumn get changedAt => integer()();
  IntColumn get oldPriceMinor => integer()();
  IntColumn get newPriceMinor => integer()();
}

class ReminderRules extends SyncTable {
  TextColumn get subscriptionId =>
      text().nullable().references(Subscriptions, #id)();
  IntColumn get daysBefore => integer()();
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
