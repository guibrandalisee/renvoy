class CatalogService {
  const CatalogService({
    required this.slug,
    required this.name,
    required this.domain,
    required this.group,
    this.iconSlug = '',
    this.color,
    this.manageUrl,
  });

  final String slug;
  final String name;
  final String domain;
  final String iconSlug;
  final String? color;
  final String? manageUrl;
  final CatalogGroup group;

  String get iconName {
    final value = iconSlug.trim();
    if (value.isEmpty) return '';
    return value.contains(':') ? value : 'si:$value';
  }

  factory CatalogService.fromJson(Map<String, dynamic> json) {
    final group = CatalogGroup.fromJson(_map(json['group']));
    return CatalogService(
      slug: _string(json['slug']),
      name: _string(json['name']),
      domain: _string(json['domain']),
      iconSlug: _iconSlug(json['icon_slug']),
      color: _nullableString(json['color']),
      manageUrl: _nullableString(json['manage_url']),
      group: group,
    );
  }
}

class CatalogGroup {
  const CatalogGroup({
    required this.key,
    required this.name,
    required this.icon,
    required this.color,
  });

  final String key;
  final CatalogGroupName name;
  final String icon;
  final String color;

  factory CatalogGroup.fromJson(Map<String, dynamic> json) {
    return CatalogGroup(
      key: _string(json['key']),
      name: CatalogGroupName.fromJson(_map(json['name'])),
      icon: _string(json['icon']),
      color: _string(json['color']),
    );
  }
}

class CatalogGroupName {
  const CatalogGroupName({
    required this.en,
    required this.pt,
    required this.es,
  });

  final String en;
  final String pt;
  final String es;

  factory CatalogGroupName.fromJson(Map<String, dynamic> json) {
    return CatalogGroupName(
      en: _string(json['en']),
      pt: _string(json['pt']),
      es: _string(json['es']),
    );
  }
}

Map<String, dynamic> _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : const <String, dynamic>{};

String _string(Object? value) => value is String ? value : '';

String? _nullableString(Object? value) {
  final string = value is String ? value.trim() : '';
  return string.isEmpty ? null : string;
}

String _iconSlug(Object? value) {
  final icon = _nullableString(value);
  if (icon != null) return icon;
  return '';
}
