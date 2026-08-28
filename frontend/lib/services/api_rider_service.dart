import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/delivery.dart';
import 'rider_service.dart';

class ApiRiderService implements RiderService {
  final String baseUrl;
  final String? accessToken;

  ApiRiderService({required this.baseUrl, this.accessToken});

  Map<String, String> get _headers {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (accessToken != null && accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    return headers;
  }

  @override
  Future<List<Delivery>> getMyDeliveries() async {
    final response = await http.get(
      Uri.parse('$baseUrl/deliveries/my'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load deliveries: '
        '${response.statusCode} ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception('Unexpected deliveries response format');
    }

    return decoded
        .map((json) => Delivery.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<Delivery> updateStatus({
    required String deliveryId,
    required String status,
    String? scanCode,
  }) async {
    final body = <String, dynamic>{'status': status};

    if (scanCode != null && scanCode.isNotEmpty) {
      body['scanCode'] = scanCode;
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/deliveries/$deliveryId/status'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update delivery: '
        '${response.statusCode} ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    return Delivery.fromJson(Map<String, dynamic>.from(decoded));
  }
}
