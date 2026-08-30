import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/delivery.dart';
import 'retailer_service.dart';

class ApiRetailerService implements RetailerService {
  final String baseUrl;
  final String? accessToken;
  final http.Client _client;

  ApiRetailerService({
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
  Future<List<Delivery>> getMyDeliveries({required String retailerId}) async {
    final uri = Uri.parse('$baseUrl/deliveries')
        .replace(queryParameters: {'retailerId': retailerId});

    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw RetailerApiException(response.statusCode, response.body);
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw const FormatException(
          'Unexpected retailer deliveries response format',
        );
      }

      return decoded
          .map((json) => Delivery.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } on TimeoutException {
      throw RetailerNetworkException('Request timed out');
    } on http.ClientException catch (error) {
      throw RetailerNetworkException(error.message);
    }
  }

  @override
  Future<Delivery> createDelivery({
    required String retailerId,
    required String customerName,
    required String phone,
    required String address,
    required String item,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/deliveries'),
            headers: _headers,
            body: jsonEncode({
              'retailerId': retailerId,
              'customerName': customerName,
              'phone': phone,
              'address': address,
              'item': item,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw RetailerApiException(response.statusCode, response.body);
      }

      return Delivery.fromJson(
        Map<String, dynamic>.from(jsonDecode(response.body)),
      );
    } on TimeoutException {
      throw RetailerNetworkException('Request timed out');
    } on http.ClientException catch (error) {
      throw RetailerNetworkException(error.message);
    }
  }
}
