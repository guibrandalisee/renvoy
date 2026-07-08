part of '../database.dart';

@DriftAccessor(tables: [Subscriptions])
class SubscriptionsDao extends DatabaseAccessor<AppDatabase>
    with _$SubscriptionsDaoMixin {
  SubscriptionsDao(super.db);

  Stream<List<Subscription>> watchAll({
    SubscriptionStatus? status,
    String? groupId,
  }) {
    final query = select(subscriptions)..where((tbl) => tbl.deletedAt.isNull());
    if (status != null) {
      query.where((tbl) => tbl.status.equalsValue(status));
    }
    if (groupId != null) {
      query.where((tbl) => tbl.groupId.equals(groupId));
    }
    query.orderBy([
      (tbl) => OrderingTerm(expression: tbl.nextBillDate),
      (tbl) => OrderingTerm(expression: tbl.name),
    ]);
    return query.watch();
  }

  Stream<Subscription?> watchById(String id) {
    final query = select(subscriptions)
      ..where((tbl) => tbl.id.equals(id) & tbl.deletedAt.isNull());
    return query.watchSingleOrNull();
  }

  Stream<List<Subscription>> watchUpcoming(int days) {
    final today = _dateOnly(DateTime.now().toUtc());
    final end = _dateOnly(DateTime.now().toUtc().add(Duration(days: days)));
    final query = select(subscriptions)
      ..where(
        (tbl) =>
            tbl.deletedAt.isNull() &
            tbl.status.equalsValue(SubscriptionStatus.active) &
            tbl.nextBillDate.isBetweenValues(today, end),
      )
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.nextBillDate),
        (tbl) => OrderingTerm(expression: tbl.name),
      ]);
    return query.watch();
  }

  Future<String> insert(SubscriptionsCompanion entry) async {
    final id = _newId();
    final now = _nowMs();
    await into(subscriptions).insert(
      entry.copyWith(
        id: Value(id),
        createdAt: Value(now),
        updatedAt: Value(now),
        dirty: const Value(true),
      ),
    );
    return id;
  }

  Future<int> updateSubscription(SubscriptionsCompanion entry) {
    final now = _nowMs();
    return (db.update(subscriptions)
          ..where((tbl) => tbl.id.equals(entry.id.value)))
        .write(entry.copyWith(updatedAt: Value(now), dirty: const Value(true)));
  }

  Future<int> softDelete(String id) {
    final now = _nowMs();
    return (db.update(subscriptions)..where((tbl) => tbl.id.equals(id))).write(
      SubscriptionsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        dirty: const Value(true),
      ),
    );
  }

  Future<int> restore(String id) {
    final now = _nowMs();
    return (db.update(subscriptions)..where((tbl) => tbl.id.equals(id))).write(
      SubscriptionsCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(now),
        dirty: const Value(true),
      ),
    );
  }

  Future<int> hardDelete(String id) {
    return (delete(subscriptions)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<String> duplicate(String id) async {
    final original = await (select(
      subscriptions,
    )..where((tbl) => tbl.id.equals(id) & tbl.deletedAt.isNull())).getSingle();
    final now = _nowMs();
    final newId = _newId();
    await into(subscriptions).insert(
      original
          .toCompanion(false)
          .copyWith(
            id: Value(newId),
            name: Value('${original.name} copy'),
            createdAt: Value(now),
            updatedAt: Value(now),
            deletedAt: const Value(null),
            dirty: const Value(true),
          ),
    );
    return newId;
  }

  Future<int> setStatus(String id, SubscriptionStatus status) {
    final now = _nowMs();
    return (db.update(subscriptions)..where((tbl) => tbl.id.equals(id))).write(
      SubscriptionsCompanion(
        status: Value(status),
        updatedAt: Value(now),
        dirty: const Value(true),
      ),
    );
  }

  Future<int> updateNextBillDate(String id, String date) {
    final now = _nowMs();
    return (db.update(subscriptions)..where((tbl) => tbl.id.equals(id))).write(
      SubscriptionsCompanion(
        nextBillDate: Value(date),
        updatedAt: Value(now),
        dirty: const Value(true),
      ),
    );
  }

  Future<List<Subscription>> renewalCandidates(String today) {
    final query = select(subscriptions)
      ..where(
        (tbl) =>
            tbl.deletedAt.isNull() &
            tbl.status.equalsValue(SubscriptionStatus.active) &
            (tbl.nextBillDate.isSmallerThanValue(today) |
                (tbl.trialEndDate.isNotNull() &
                    tbl.trialEndDate.isSmallerOrEqualValue(today))),
      )
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.nextBillDate)]);
    return query.get();
  }

  Future<int> updateBillingState({
    required String id,
    String? nextBillDate,
    bool clearTrialEndDate = false,
  }) {
    final now = _nowMs();
    return (db.update(subscriptions)..where((tbl) => tbl.id.equals(id))).write(
      SubscriptionsCompanion(
        nextBillDate: nextBillDate == null
            ? const Value.absent()
            : Value(nextBillDate),
        trialEndDate: clearTrialEndDate
            ? const Value(null)
            : const Value.absent(),
        updatedAt: Value(now),
        dirty: const Value(true),
      ),
    );
  }
}

String _dateOnly(DateTime value) {
  final utc = value.toUtc();
  final year = utc.year.toString().padLeft(4, '0');
  final month = utc.month.toString().padLeft(2, '0');
  final day = utc.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
