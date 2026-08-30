import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/api_rider_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const baseUrl = 'http://localhost:3000';

  Map<String, dynamic> deliveryJson({
    String status = 'assigned',
    String? proofScan,
  }) {
    return {
      '_id': '64f1a2b3c4d5e6f7a8b9c0d1',
      'customerName': 'Grace Akinyi',
      'phone': '+254712345678',
      'address': 'Westlands, Nairobi',
      'item': 'Samsung Galaxy A54',
      'status': status,
      'riderId': '64e0b1c2d3e4f5a6b7c8d9e0',
      'proofScan': proofScan,
      'createdAt': '2026-08-30T08:15:00.000Z',
      'updatedAt': '2026-08-30T08:47:00.000Z',
    };
  }

  test('GET /deliveries/my parses rider deliveries', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');

      expect(request.url.toString(), '$baseUrl/deliveries/my');

      return http.Response(
        jsonEncode([deliveryJson()]),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final service = ApiRiderService(baseUrl: baseUrl, client: client);

    final deliveries = await service.getMyDeliveries();

    expect(deliveries, hasLength(1));

    expect(deliveries.first.customerName, 'Grace Akinyi');

    expect(deliveries.first.status, 'assigned');
  });

  test('pickup sends in_transit status', () async {
    final client = MockClient((request) async {
      expect(request.method, 'PATCH');

      final body = jsonDecode(request.body) as Map<String, dynamic>;

      expect(body['status'], 'in_transit');

      expect(body.containsKey('scanCode'), isFalse);

      return http.Response(
        jsonEncode(deliveryJson(status: 'in_transit')),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final service = ApiRiderService(baseUrl: baseUrl, client: client);

    final delivery = await service.updateStatus(
      deliveryId: '64f1a2b3c4d5e6f7a8b9c0d1',
      status: 'in_transit',
    );

    expect(delivery.status, 'in_transit');
  });

  test('delivery confirmation sends delivered status and scanCode', () async {
    final client = MockClient((request) async {
      final body = jsonDecode(request.body) as Map<String, dynamic>;

      expect(body['status'], 'delivered');

      expect(body['scanCode'], 'QR-REFLEX-001');

      return http.Response(
        jsonEncode(
          deliveryJson(status: 'delivered', proofScan: 'QR-REFLEX-001'),
        ),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final service = ApiRiderService(baseUrl: baseUrl, client: client);

    final delivery = await service.updateStatus(
      deliveryId: '64f1a2b3c4d5e6f7a8b9c0d1',
      status: 'delivered',
      scanCode: 'QR-REFLEX-001',
    );

    expect(delivery.proofScan, 'QR-REFLEX-001');
  });

  test('API errors are surfaced', () async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({'message': 'invalid status transition'}),
        409,
      );
    });

    final service = ApiRiderService(baseUrl: baseUrl, client: client);

    expect(
      () => service.updateStatus(deliveryId: '123', status: 'delivered'),
      throwsException,
    );
  });
}
