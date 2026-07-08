import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renvoy/data/db/database.dart';
import 'package:renvoy/domain/models/enums.dart';

void main() {
  test('groups dao emits tree and delete move up updates children', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final parentId = await _insertGroup(database, 'Parent');
    final childId = await _insertGroup(database, 'Child', parentId: parentId);
    final grandchildId = await _insertGroup(
      database,
      'Grandchild',
      parentId: childId,
    );
    final subscriptionId = await _insertSubscription(
      database,
      'Netflix',
      groupId: childId,
    );

    final tree = await database.groupsDao.watchAllTree().first;
    final parent = tree.firstWhere((node) => node.group.id == parentId);
    expect(parent.children.map((node) => node.group.id), contains(childId));

    await database.groupsDao.deleteGroupMoveChildrenUp(childId);

    final movedTree = await database.groupsDao.watchAllTree().first;
    final movedParent = movedTree.firstWhere(
      (node) => node.group.id == parentId,
    );
    expect(
      movedParent.children.map((node) => node.group.id),
      contains(grandchildId),
    );
    expect(
      movedParent.children.map((node) => node.group.id),
      isNot(contains(childId)),
    );
    final movedSubscription = await database.subscriptionsDao
        .watchById(subscriptionId)
        .first;
    expect(movedSubscription?.groupId, parentId);

    await database.close();
  });

  test('delete ungroup makes child groups top-level', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final parentId = await _insertGroup(database, 'Parent');
    final childId = await _insertGroup(database, 'Child', parentId: parentId);

    await database.groupsDao.deleteGroupUngroupSubscriptions(parentId);

    final tree = await database.groupsDao.watchAllTree().first;
    expect(tree.map((node) => node.group.id), contains(childId));

    await database.close();
  });
}

Future<String> _insertGroup(
  AppDatabase database,
  String name, {
  String? parentId,
}) {
  return database.groupsDao.insert(
    GroupsCompanion.insert(
      id: '',
      createdAt: 0,
      updatedAt: 0,
      name: name,
      icon: 'category_outlined',
      color: '#7C5CFC',
      parentId: Value(parentId),
    ),
  );
}

Future<String> _insertSubscription(
  AppDatabase database,
  String name, {
  required String groupId,
}) {
  return database.subscriptionsDao.insert(
    SubscriptionsCompanion.insert(
      id: '',
      createdAt: 0,
      updatedAt: 0,
      name: name,
      priceMinor: 1299,
      currency: 'USD',
      cycleUnit: CycleUnit.month,
      firstBillDate: '2026-07-01',
      nextBillDate: '2026-07-15',
      status: SubscriptionStatus.active,
      groupId: Value(groupId),
      colorHex: const Value('#7C5CFC'),
    ),
  );
}
