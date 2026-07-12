import 'dart:convert';

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

  @override
  Future<CatalogApiResponse> fetchServices() async {
    try {
      final response = await _client
          .get(Uri.parse('$apiBaseUrl/api/v1/default-subscriptions'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw CatalogApiException(
          'Catalog request failed with HTTP ${response.statusCode}.',
          statusCode: response.statusCode,
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map || decoded['data'] is! List) {
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
      return CatalogApiResponse(rawJson: response.body, services: services);
    } on CatalogApiException {
      rethrow;
    } on Exception catch (error) {
      throw CatalogApiException('Unable to fetch catalog: $error');
    }
  }

  void dispose() => _client.close();
}
