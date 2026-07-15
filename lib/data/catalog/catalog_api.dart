import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../../core/env.dart';
import 'catalog_models.dart';

class CatalogApiException implements Exception {
  const CatalogApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'CatalogApiException: $message';
}

abstract interface class CatalogApi {
  Future<CatalogApiResponse> fetchServices();
}

class CatalogApiResponse {
  const CatalogApiResponse({required this.rawJson, required this.services});

  final String rawJson;
  final List<CatalogService> services;
}

class HttpCatalogApi implements CatalogApi {
  HttpCatalogApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _logName = 'CatalogApi';

  @override
  Future<CatalogApiResponse> fetchServices() async {
    final uri = Uri.parse('$apiBaseUrl/api/v1/default-subscriptions');
    final stopwatch = Stopwatch()..start();
    developer.log(
      'Starting catalog request: GET $uri (timeout: 10s)',
      name: _logName,
    );
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 10));
      developer.log(
        'Catalog response received: status=${response.statusCode}, '
        'bodyBytes=${response.bodyBytes.length}, '
        'contentType=${response.headers['content-type'] ?? 'unknown'}, '
        'elapsedMs=${stopwatch.elapsedMilliseconds}',
        name: _logName,
      );
      if (response.statusCode != 200) {
        developer.log(
          'Catalog request failed with HTTP ${response.statusCode}',
          name: _logName,
          level: 900,
        );
        throw CatalogApiException(
          'Catalog request failed with HTTP ${response.statusCode}.',
          statusCode: response.statusCode,
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map || decoded['data'] is! List) {
        developer.log(
          'Catalog response has an invalid shape: '
          'decodedType=${decoded.runtimeType}',
          name: _logName,
          level: 900,
        );
        throw const CatalogApiException(
          'Catalog response has an invalid shape.',
        );
      }
      final services = (decoded['data'] as List)
          .whereType<Map>()
          .map(
            (item) => CatalogService.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false);
      developer.log(
        'Catalog response parsed successfully: services=${services.length}',
        name: _logName,
      );
      return CatalogApiResponse(rawJson: response.body, services: services);
    } on CatalogApiException catch (error, stackTrace) {
      developer.log(
        'Catalog API error after ${stopwatch.elapsedMilliseconds}ms: $error',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
        level: 900,
      );
      rethrow;
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Unexpected catalog request error after '
        '${stopwatch.elapsedMilliseconds}ms: ${error.runtimeType}: $error',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
      throw CatalogApiException('Unable to fetch catalog: $error');
    }
  }

  void dispose() => _client.close();
}
