part of '../database.dart';

@DriftAccessor(tables: [Groups, Subscriptions])
class GroupsDao extends DatabaseAccessor<AppDatabase> with _$GroupsDaoMixin {
  GroupsDao(super.db);

  Stream<List<GroupNode>> watchAllTree() {
    return select(groups).watch().asyncMap((rows) async {
      final activeGroups =
          rows.where((group) => group.deletedAt == null).toList()..sort((a, b) {
            final position = a.position.compareTo(b.position);
            return position == 0 ? a.name.compareTo(b.name) : position;
          });

      final counts = <String, int>{};
      for (final group in activeGroups) {
        final count = subscriptions.id.count();
        final query = selectOnly(subscriptions)
          ..addColumns([count])
          ..where(
            subscriptions.groupId.equals(group.id) &
                subscriptions.deletedAt.isNull(),
          );
        counts[group.id] = await query
            .map((row) => row.read(count) ?? 0)
            .getSingle();
      }

      GroupNode build(Group group) {
        final children = activeGroups
            .where((candidate) => candidate.parentId == group.id)
            .map(build)
            .toList();
        final childCount = children.fold<int>(
          0,
          (sum, child) => sum + child.subscriptionCount,
        );
        return GroupNode(
          group: group,
          children: children,
          subscriptionCount: (counts[group.id] ?? 0) + childCount,
        );
      }

      return activeGroups
          .where((group) => group.parentId == null)
          .map(build)
          .toList();
    });
  }

  Future<String> insert(GroupsCompanion entry) async {
    final id = _newId();
    final now = _nowMs();
    await into(groups).insert(
      entry.copyWith(
        id: Value(id),
        createdAt: Value(now),
        updatedAt: Value(now),
        dirty: const Value(true),
      ),
    );
    return id;
  }

  Future<int> updateGroup(GroupsCompanion entry) {
    final now = _nowMs();
    return (db.update(groups)..where((tbl) => tbl.id.equals(entry.id.value)))
        .write(entry.copyWith(updatedAt: Value(now), dirty: const Value(true)));
  }

  Future<int> softDelete(String id) {
    final now = _nowMs();
    return (db.update(groups)..where((tbl) => tbl.id.equals(id))).write(
      GroupsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        dirty: const Value(true),
      ),
    );
  }

  Future<void> deleteGroupMoveChildrenUp(String id) async {
    await transaction(() async {
      final group = await (select(
        groups,
      )..where((tbl) => tbl.id.equals(id))).getSingle();
      final now = _nowMs();
      await (db.update(groups)..where((tbl) => tbl.parentId.equals(id))).write(
        GroupsCompanion(
          parentId: Value(group.parentId),
          updatedAt: Value(now),
          dirty: const Value(true),
        ),
      );
      await (db.update(
        subscriptions,
      )..where((tbl) => tbl.groupId.equals(id) & tbl.deletedAt.isNull())).write(
        SubscriptionsCompanion(
          groupId: Value(group.parentId),
          updatedAt: Value(now),
          dirty: const Value(true),
        ),
      );
      await softDelete(id);
    });
  }

  Future<void> deleteGroupUngroupSubscriptions(String id) async {
    await transaction(() async {
      final now = _nowMs();
      await (db.update(groups)..where((tbl) => tbl.parentId.equals(id))).write(
        GroupsCompanion(
          parentId: const Value(null),
          updatedAt: Value(now),
          dirty: const Value(true),
        ),
      );
      await (db.update(
        subscriptions,
      )..where((tbl) => tbl.groupId.equals(id) & tbl.deletedAt.isNull())).write(
        SubscriptionsCompanion(
          groupId: const Value(null),
          updatedAt: Value(now),
          dirty: const Value(true),
        ),
      );
      await softDelete(id);
    });
  }

  Future<void> deleteGroupCascade(String id) async {
    await transaction(() async {
      final childIds =
          await (select(groups)..where(
                (tbl) => tbl.parentId.equals(id) & tbl.deletedAt.isNull(),
              ))
              .map((group) => group.id)
              .get();
      final ids = [id, ...childIds];
      final now = _nowMs();
      await (db.update(
        subscriptions,
      )..where((tbl) => tbl.groupId.isIn(ids) & tbl.deletedAt.isNull())).write(
        SubscriptionsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          dirty: const Value(true),
        ),
      );
      await (db.update(
        groups,
      )..where((tbl) => tbl.id.isIn(ids) & tbl.deletedAt.isNull())).write(
        GroupsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          dirty: const Value(true),
        ),
      );
    });
  }
}
