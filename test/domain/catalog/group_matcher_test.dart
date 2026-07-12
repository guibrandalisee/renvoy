import 'package:flutter_test/flutter_test.dart';
import 'package:renvoy/data/catalog/catalog_models.dart';
import 'package:renvoy/data/db/database.dart';
import 'package:renvoy/domain/catalog/group_matcher.dart';
import 'package:renvoy/domain/models/group_node.dart';

void main() {
  final service = CatalogService(
    slug: 'spotify',
    name: 'Spotify',
    domain: 'spotify.com',
    group: CatalogGroup(
      key: 'music',
      name: CatalogGroupName(en: 'Music', pt: 'Música', es: 'Música'),
      icon: 'music',
      color: '#1DB954',
    ),
  );

  test('matches an exact catalog group name', () {
    expect(
      matchCatalogServiceGroupId(service, [_group('Music', 'music')]),
      'music',
    );
  });

  test('matches names case-insensitively', () {
    expect(
      matchCatalogServiceGroupId(service, [_group('mUsIc', 'music')]),
      'music',
    );
  });

  test('matches names without diacritics', () {
    expect(
      matchCatalogServiceGroupId(service, [_group('musica', 'music')]),
      'music',
    );
  });

  test('does not assign a renamed group', () {
    expect(
      matchCatalogServiceGroupId(service, [
        _group('Entertainment', 'entertainment'),
      ]),
      isNull,
    );
  });

  test('returns the first group by position for duplicate names', () {
    final groups = [
      _group('Music', 'second', position: 1),
      _group('Music', 'first', position: 0),
    ];
    expect(matchCatalogServiceGroupId(service, groups), 'first');
  });
}

GroupNode _group(String name, String id, {int position = 0}) {
  return GroupNode(
    group: Group(
      id: id,
      createdAt: 0,
      updatedAt: 0,
      dirty: false,
      name: name,
      icon: '',
      color: '#000000',
      position: position,
    ),
    children: const [],
    subscriptionCount: 0,
  );
}
