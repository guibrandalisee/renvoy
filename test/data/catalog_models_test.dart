import 'package:flutter_test/flutter_test.dart';
import 'package:renvoy/data/catalog/catalog_models.dart';

void main() {
  test('CatalogService parses a complete API response item', () {
    final service = CatalogService.fromJson({
      'slug': 'netflix',
      'name': 'Netflix',
      'domain': 'netflix.com',
      'icon_slug': 'netflix',
      'color': '#E50914',
      'manage_url': null,
      'group': {
        'key': 'streaming',
        'name': {'en': 'Streaming', 'pt': 'Streaming', 'es': 'Streaming'},
        'icon': 'play',
        'color': '#8B7CFC',
      },
    });

    expect(service.slug, 'netflix');
    expect(service.iconSlug, 'netflix');
    expect(service.iconName, 'si:netflix');
    expect(service.manageUrl, isNull);
    expect(service.group.name.pt, 'Streaming');
  });

  test('CatalogService tolerates null and missing optional fields', () {
    final service = CatalogService.fromJson({
      'slug': null,
      'name': null,
      'domain': null,
      'icon_slug': null,
      'color': null,
      'manage_url': null,
      'group': null,
    });

    expect(service.slug, isEmpty);
    expect(service.name, isEmpty);
    expect(service.domain, isEmpty);
    expect(service.iconSlug, isEmpty);
    expect(service.iconName, isEmpty);
    expect(service.color, isNull);
    expect(service.group.name.en, isEmpty);
  });
}
