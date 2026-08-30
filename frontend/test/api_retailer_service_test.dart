import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/api_retailer_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const baseUrl = 'http://localhost:3000';

  Map<String, dynamic> deliveryJson() {
    return {
      '_id': '64f1a2b3c4d5e6f7a8b9c0d1',
      'customerName': 'Grace Akinyi',
      'phone': '+254712345678',
      'address': 'Westlands, Nairobi',
      'item': 'Samsung Galaxy A54',
      'status': 'pending',
      'riderId': null,
      'proofScan': null,
      'createdAt': '2026-08-30T08:15:00.000Z',
      'updatedAt': '2026-08-30T08:15:00.000Z',
    };
  }

  test('POST /deliveries sends required retailer fields', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');

      final body = jsonDecode(request.body) as Map<String, dynamic>;

      expect(body['retailerId'], 'retailer-1');
      expect(body['customerName'], 'Grace Akinyi');
      expect(body['phone'], '+254712345678');
      expect(body['address'], 'Westlands, Nairobi');
      expect(body['item'], 'Samsung Galaxy A54');

      return http.Response(jsonEncode(deliveryJson()), 201);
    });

    final service = ApiRetailerService(baseUrl: baseUrl, client: client);

    final delivery = await service.createDelivery(
      retailerId: 'retailer-1',
      customerName: 'Grace Akinyi',
      phone: '+254712345678',
      address: 'Westlands, Nairobi',
      item: 'Samsung Galaxy A54',
    );

    expect(delivery.customerName, 'Grace Akinyi');

    expect(delivery.riderId, isNull);
  });

  test('GET retailer deliveries includes retailerId query', () async {
    final client = MockClient((request) async {
      expect(request.url.queryParameters['retailerId'], 'retailer-1');

      return http.Response(jsonEncode([deliveryJson()]), 200);
    });

    final service = ApiRetailerService(baseUrl: baseUrl, client: client);

    final deliveries = await service.getMyDeliveries(retailerId: 'retailer-1');

    expect(deliveries, hasLength(1));

    expect(deliveries.first.displayStatus, 'Created');
  });
}
