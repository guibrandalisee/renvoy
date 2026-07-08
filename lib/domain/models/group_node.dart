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
