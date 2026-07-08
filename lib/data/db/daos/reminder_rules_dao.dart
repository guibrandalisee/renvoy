part of '../database.dart';

@DriftAccessor(tables: [ReminderRules])
class ReminderRulesDao extends DatabaseAccessor<AppDatabase>
    with _$ReminderRulesDaoMixin {
  ReminderRulesDao(super.db);

  Stream<List<ReminderRule>> watchGlobal() {
    final query = select(reminderRules)
      ..where((tbl) => tbl.subscriptionId.isNull() & tbl.deletedAt.isNull())
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.daysBefore)]);
    return query.watch();
  }

  Stream<List<ReminderRule>> watchForSubscription(String id) {
    final query = select(reminderRules)
      ..where((tbl) => tbl.subscriptionId.equals(id) & tbl.deletedAt.isNull())
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.daysBefore)]);
    return query.watch();
  }

  Future<void> replaceForSubscription(String id, List<int> daysBefore) {
    return _replace(id, daysBefore);
  }

  Future<void> replaceGlobal(List<int> daysBefore) {
    return _replace(null, daysBefore);
  }

  Future<void> _replace(String? subscriptionId, List<int> daysBefore) async {
    await transaction(() async {
      final now = _nowMs();
      final deleteQuery = db.update(reminderRules);
      if (subscriptionId == null) {
        deleteQuery.where(
          (tbl) => tbl.subscriptionId.isNull() & tbl.deletedAt.isNull(),
        );
      } else {
        deleteQuery.where(
          (tbl) =>
              tbl.subscriptionId.equals(subscriptionId) &
              tbl.deletedAt.isNull(),
        );
      }
      await deleteQuery.write(
        ReminderRulesCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          dirty: const Value(true),
        ),
      );

      await batch((batch) {
        batch.insertAll(
          reminderRules,
          daysBefore.map(
            (days) => ReminderRulesCompanion.insert(
              id: _newId(),
              createdAt: now,
              updatedAt: now,
              subscriptionId: Value(subscriptionId),
              daysBefore: days,
            ),
          ),
        );
      });
    });
  }
}
