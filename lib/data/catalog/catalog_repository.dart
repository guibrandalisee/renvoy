import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database_provider.dart';
import '../db/settings_keys.dart';
import 'catalog_api.dart';
import 'catalog_models.dart';

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

  static const _logName = 'CatalogRepository';

  Future<List<CatalogService>> getServices() async {
    developer.log('Loading catalog from cache', name: _logName);
    final cached = await _readCache();
    final now = _now();
    developer.log(
      cached == null
          ? 'No usable catalog cache found; requesting catalog'
          : 'Catalog cache available as fallback; requesting refresh: '
                'services=${cached.services.length}, '
                'fetchedAt=${cached.fetchedAt.toIso8601String()}',
      name: _logName,
    );

    try {
      final response = await _api.fetchServices();
      if (response.services.isEmpty) {
        throw const CatalogApiException(
          'Catalog response contains no services.',
        );
      }
      developer.log(
        'Catalog refresh succeeded: services=${response.services.length}; '
        'saving response to cache',
        name: _logName,
      );
      await _cacheStore.write(SettingsKeys.catalogCache, response.rawJson);
      await _cacheStore.write(
        SettingsKeys.catalogFetchedAt,
        now.toIso8601String(),
      );
      developer.log('Catalog cache updated successfully', name: _logName);
      return response.services;
    } on CatalogApiException catch (error, stackTrace) {
      if (cached != null && cached.services.isNotEmpty) {
        developer.log(
          'Catalog refresh failed; falling back to stale cache: $error',
          name: _logName,
          error: error,
          stackTrace: stackTrace,
          level: 900,
        );
        return cached.services;
      }
      developer.log(
        'Catalog refresh failed and no cache is available: $error',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    } on Object catch (error, stackTrace) {
      developer.log(
        'Catalog refresh failed outside the API: ${error.runtimeType}: $error',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<_CachedCatalog?> _readCache() async {
    final rawJson = await _cacheStore.read(SettingsKeys.catalogCache);
    final timestamp = await _cacheStore.read(SettingsKeys.catalogFetchedAt);
    if (rawJson == null || timestamp == null) {
      developer.log(
        'Catalog cache miss: rawJson=${rawJson != null}, '
        'timestamp=${timestamp != null}',
        name: _logName,
      );
      return null;
    }
    try {
      final fetchedAt = DateTime.parse(timestamp).toUtc();
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map || decoded['data'] is! List) {
        developer.log(
          'Catalog cache ignored because its JSON shape is invalid',
          name: _logName,
          level: 900,
        );
        return null;
      }
      final services = (decoded['data'] as List)
          .whereType<Map>()
          .map(
            (item) => CatalogService.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false);
      developer.log(
        'Catalog cache read successfully: services=${services.length}, '
        'fetchedAt=${fetchedAt.toIso8601String()}',
        name: _logName,
      );
      return _CachedCatalog(fetchedAt: fetchedAt, services: services);
    } on FormatException catch (error, stackTrace) {
      developer.log(
        'Catalog cache ignored because it is not valid JSON/date: $error',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
        level: 900,
      );
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

final catalogServicesProvider =
    FutureProvider.autoDispose<List<CatalogService>>((ref) {
      return ref.watch(catalogRepositoryProvider).getServices();
    });
