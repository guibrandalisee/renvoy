import 'package:flutter_test/flutter_test.dart';
import 'package:renvoy/data/catalog/catalog_api.dart';
import 'package:renvoy/data/catalog/catalog_models.dart';
import 'package:renvoy/data/catalog/catalog_repository.dart';
import 'package:renvoy/data/db/settings_keys.dart';

void main() {
  final now = DateTime.utc(2026, 7, 9, 12);

  test('cache is fresh only before seven full days', () {
    expect(
      isCatalogCacheFresh(
        now.subtract(const Duration(days: 7, seconds: 1)),
        now,
      ),
      isFalse,
    );
    expect(
      isCatalogCacheFresh(now.subtract(const Duration(days: 7)), now),
      isFalse,
    );
    expect(
      isCatalogCacheFresh(
        now.subtract(const Duration(days: 6, hours: 23)),
        now,
      ),
      isTrue,
    );
  });

  test('uses valid cache without making a network request', () async {
    final api = _FakeApi(response: _response('network'));
    final cache = _FakeCache({
      SettingsKeys.catalogCache: _raw('cached'),
      SettingsKeys.catalogFetchedAt:
          now.subtract(const Duration(days: 6)).toIso8601String(),
    });
    final repository = CatalogRepository(
      api: api,
      cacheStore: cache,
      now: () => now,
    );

    final services = await repository.getServices();

    expect(services.single.slug, 'cached');
    expect(api.calls, 0);
  });

  test('uses stale cache when the refreshed request fails', () async {
    final api = _FakeApi(error: const CatalogApiException('offline'));
    final cache = _FakeCache({
      SettingsKeys.catalogCache: _raw('stale'),
      SettingsKeys.catalogFetchedAt:
          now.subtract(const Duration(days: 7)).toIso8601String(),
    });
    final repository = CatalogRepository(
      api: api,
      cacheStore: cache,
      now: () => now,
    );

    final services = await repository.getServices();

    expect(services.single.slug, 'stale');
    expect(api.calls, 1);
  });
}

class _FakeCache implements CatalogCacheStore {
  _FakeCache(this.values);

  final Map<String, String> values;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}

class _FakeApi implements CatalogApi {
  _FakeApi({this.response, this.error});

  final CatalogApiResponse? response;
  final CatalogApiException? error;
  int calls = 0;

  @override
  Future<CatalogApiResponse> fetchServices() async {
    calls++;
    if (error != null) throw error!;
    return response!;
  }
}

CatalogApiResponse _response(String slug) => CatalogApiResponse(
  rawJson: _raw(slug),
  services: [
    CatalogService.fromJson({
      'slug': slug,
      'name': slug,
      'domain': '$slug.com',
    }),
  ],
);

String _raw(String slug) =>
    '{"data":[{"slug":"$slug","name":"$slug","domain":"$slug.com"}]}';
