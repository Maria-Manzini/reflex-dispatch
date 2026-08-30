import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/api_dispatcher_service.dart';
import 'package:frontend/services/dispatcher_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const baseUrl = 'http://localhost:3000';

  Map<String, dynamic> deliveryJson({
    String status = 'pending',
    String? riderId,
  }) {
    return {
      '_id': '64f1a2b3c4d5e6f7a8b9c0d1',
      'customerName': 'Grace Akinyi',
      'phone': '+254712345678',
      'address': 'Westlands, Nairobi',
      'item': 'Samsung Galaxy A54',
      'status': status,
      'riderId': riderId,
      'proofScan': null,
      'createdAt': '2026-08-30T08:15:00.000Z',
      'updatedAt': '2026-08-30T08:15:00.000Z',
    };
  }

  test('GET open deliveries sends status=open', () async {
    final client = MockClient((request) async {
      expect(request.url.queryParameters['status'], 'open');

      return http.Response(jsonEncode([deliveryJson()]), 200);
    });

    final service = ApiDispatcherService(baseUrl: baseUrl, client: client);

    final deliveries = await service.getOpenDeliveries();

    expect(deliveries, hasLength(1));
    expect(deliveries.first.status, 'pending');
  });

  test('assign sends selected riderId', () async {
    const riderId = '64e0b1c2d3e4f5a6b7c8d9e0';

    final client = MockClient((request) async {
      expect(request.method, 'PATCH');

      final body = jsonDecode(request.body) as Map<String, dynamic>;

      expect(body['riderId'], riderId);

      return http.Response(
        jsonEncode(deliveryJson(status: 'assigned', riderId: riderId)),
        200,
      );
    });

    final service = ApiDispatcherService(baseUrl: baseUrl, client: client);

    final delivery = await service.assignDelivery(
      deliveryId: '64f1a2b3c4d5e6f7a8b9c0d1',
      riderId: riderId,
    );

    expect(delivery.status, 'assigned');

    expect(delivery.riderId, riderId);
  });

  test('409 assignment conflict is surfaced', () async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({'message': 'delivery is already assigned'}),
        409,
      );
    });

    final service = ApiDispatcherService(baseUrl: baseUrl, client: client);

    expect(
      () => service.assignDelivery(
        deliveryId: '64f1a2b3c4d5e6f7a8b9c0d1',
        riderId: '64e0b1c2d3e4f5a6b7c8d9e0',
      ),
      throwsA(isA<DispatcherApiException>()),
    );
  });
}
