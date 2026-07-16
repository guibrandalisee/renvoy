import '../../data/db/database.dart';

class GroupNode {
  const GroupNode({
    required this.group,
    required this.children,
    required this.subscriptionCount,
  });

  final Group group;
  final List<GroupNode> children;
  final int subscriptionCount;
}

/// A stable, presentation-neutral representation of a group's ancestry.
class GroupPath {
  const GroupPath(this.groups);

  final List<Group> groups;

  Group get root => groups.first;
  Group get selected => groups.last;

  String label({String separator = ' › '}) {
    return groups.map((group) => group.name).join(separator);
  }
}

Map<String, GroupPath> buildGroupPathIndex(List<GroupNode> roots) {
  final index = <String, GroupPath>{};

  void visit(GroupNode node, List<Group> ancestors) {
    final path = [...ancestors, node.group];
    index[node.group.id] = GroupPath(path);
    for (final child in node.children) {
      visit(child, path);
    }
  }

  for (final root in roots) {
    visit(root, const []);
  }
  return index;
}

GroupPath? findGroupPath(List<GroupNode> roots, String? groupId) {
  if (groupId == null) return null;
  return buildGroupPathIndex(roots)[groupId];
}
