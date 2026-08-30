import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/delivery.dart';
import 'dispatcher_service.dart';

class ApiDispatcherService implements DispatcherService {
  final String baseUrl;
  final String? accessToken;
  final http.Client _client;

  ApiDispatcherService({
    required this.baseUrl,
    this.accessToken,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Map<String, String> get _headers {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (accessToken != null && accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    return headers;
  }

  @override
  Future<List<Delivery>> getOpenDeliveries() async {
    final uri = Uri.parse('$baseUrl/deliveries')
        .replace(queryParameters: {'status': 'open'});

    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw DispatcherApiException(response.statusCode, response.body);
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw const FormatException(
          'Unexpected open deliveries response format',
        );
      }

      return decoded
          .map((json) => Delivery.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } on TimeoutException {
      throw DispatcherApiException(408, 'Request timed out');
    } on http.ClientException catch (error) {
      throw DispatcherApiException(0, error.message);
    }
  }

  @override
  Future<Delivery> assignDelivery({
    required String deliveryId,
    required String riderId,
  }) async {
    try {
      final response = await _client
          .patch(
            Uri.parse('$baseUrl/deliveries/$deliveryId/assign'),
            headers: _headers,
            body: jsonEncode({'riderId': riderId}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw DispatcherApiException(response.statusCode, response.body);
      }

      return Delivery.fromJson(
        Map<String, dynamic>.from(jsonDecode(response.body)),
      );
    } on TimeoutException {
      throw DispatcherApiException(408, 'Request timed out');
    } on http.ClientException catch (error) {
      throw DispatcherApiException(0, error.message);
    }
  }
}
