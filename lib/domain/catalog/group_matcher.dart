import '../../core/text_normalize.dart';
import '../../data/catalog/catalog_models.dart';
import '../models/group_node.dart';

String? matchCatalogServiceGroupId(
  CatalogService service,
  List<GroupNode> groups,
) {
  final expectedNames = {
    normalizeForSearch(service.group.name.en),
    normalizeForSearch(service.group.name.pt),
    normalizeForSearch(service.group.name.es),
  };

  final orderedGroups = _flatten(groups).toList()
    ..sort((a, b) => a.group.position.compareTo(b.group.position));
  for (final group in orderedGroups) {
    if (expectedNames.contains(normalizeForSearch(group.group.name))) {
      return group.group.id;
    }
  }
  return null;
}

Iterable<GroupNode> _flatten(List<GroupNode> groups) sync* {
  for (final group in groups) {
    yield group;
    yield* _flatten(group.children);
  }
}
