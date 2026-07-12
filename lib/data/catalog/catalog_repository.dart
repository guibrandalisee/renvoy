import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database_provider.dart';
import '../db/settings_keys.dart';
import 'catalog_api.dart';
import 'catalog_models.dart';

const catalogCacheTtl = Duration(days: 7);

bool isCatalogCacheFresh(DateTime fetchedAt, DateTime now) =>
    now.difference(fetchedAt) < catalogCacheTtl;

abstract interface class CatalogCacheStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class SettingsCatalogCacheStore implements CatalogCacheStore {
  SettingsCatalogCacheStore(this._ref);

  final Ref _ref;

  @override
  Future<String?> read(String key) =>
      _ref.read(settingsDaoProvider).getValue(key);

  @override
  Future<void> write(String key, String value) =>
      _ref.read(settingsDaoProvider).setValue(key, value);
}

class CatalogRepository {
  CatalogRepository({
    required CatalogApi api,
    required CatalogCacheStore cacheStore,
    DateTime Function()? now,
  }) : _api = api,
       _cacheStore = cacheStore,
       _now = now ?? (() => DateTime.now().toUtc());

  final CatalogApi _api;
  final CatalogCacheStore _cacheStore;
  final DateTime Function() _now;

  Future<List<CatalogService>> getServices() async {
    final cached = await _readCache();
    final now = _now();
    if (cached != null && isCatalogCacheFresh(cached.fetchedAt, now)) {
      return cached.services;
    }

    try {
      final response = await _api.fetchServices();
      await _cacheStore.write(SettingsKeys.catalogCache, response.rawJson);
      await _cacheStore.write(
        SettingsKeys.catalogFetchedAt,
        now.toIso8601String(),
      );
      return response.services;
    } on CatalogApiException {
      if (cached != null) return cached.services;
      rethrow;
    }
  }

  Future<_CachedCatalog?> _readCache() async {
    final rawJson = await _cacheStore.read(SettingsKeys.catalogCache);
    final timestamp = await _cacheStore.read(SettingsKeys.catalogFetchedAt);
    if (rawJson == null || timestamp == null) return null;
    try {
      final fetchedAt = DateTime.parse(timestamp).toUtc();
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map || decoded['data'] is! List) return null;
      final services = (decoded['data'] as List)
          .whereType<Map>()
          .map(
            (item) => CatalogService.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false);
      return _CachedCatalog(fetchedAt: fetchedAt, services: services);
    } on FormatException {
      return null;
    }
  }
}

class _CachedCatalog {
  const _CachedCatalog({required this.fetchedAt, required this.services});

  final DateTime fetchedAt;
  final List<CatalogService> services;
}

final catalogApiProvider = Provider<HttpCatalogApi>((ref) {
  final api = HttpCatalogApi();
  ref.onDispose(api.dispose);
  return api;
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(
    api: ref.watch(catalogApiProvider),
    cacheStore: SettingsCatalogCacheStore(ref),
  );
});

final catalogServicesProvider = FutureProvider<List<CatalogService>>((ref) {
  return ref.watch(catalogRepositoryProvider).getServices();
});
