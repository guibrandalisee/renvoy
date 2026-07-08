part of '../database.dart';

@DriftAccessor(tables: [PriceHistory])
class PriceHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$PriceHistoryDaoMixin {
  PriceHistoryDao(super.db);

  Stream<List<PriceHistoryData>> watchForSubscription(String id) {
    final query = select(priceHistory)
      ..where((tbl) => tbl.subscriptionId.equals(id) & tbl.deletedAt.isNull())
      ..orderBy([
        (tbl) =>
            OrderingTerm(expression: tbl.changedAt, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  Future<String> insert(PriceHistoryCompanion entry) async {
    final id = _newId();
    final now = _nowMs();
    await into(priceHistory).insert(
      entry.copyWith(
        id: Value(id),
        createdAt: Value(now),
        updatedAt: Value(now),
        dirty: const Value(true),
      ),
    );
    return id;
  }
}
