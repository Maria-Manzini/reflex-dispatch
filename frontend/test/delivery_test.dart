import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/delivery.dart';

void main() {
  group('Delivery', () {
    test('parses backend delivery response', () {
      final delivery = Delivery.fromJson({
        '_id': '64f1a2b3c4d5e6f7a8b9c0d1',
        'customerName': 'Grace Akinyi',
        'phone': '+254712345678',
        'address': 'Westlands, Nairobi',
        'item': 'Samsung Galaxy A54',
        'status': 'in_transit',
        'riderId': '64e0b1c2d3e4f5a6b7c8d9e0',
        'proofScan': null,
        'createdAt': '2026-08-30T08:15:00.000Z',
        'updatedAt': '2026-08-30T08:47:00.000Z',
      });

      expect(delivery.id, '64f1a2b3c4d5e6f7a8b9c0d1');

      expect(delivery.status, 'in_transit');

      expect(delivery.displayStatus, 'Picked Up');
    });

    test('pending delivery allows null riderId', () {
      final delivery = Delivery.fromJson({
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
      });

      expect(delivery.riderId, isNull);
      expect(delivery.displayStatus, 'Created');
    });

    test('maps backend statuses to rider labels', () {
      Delivery makeDelivery(String status) {
        return Delivery(
          id: '1',
          customerName: 'Customer',
          phone: '0700000000',
          address: 'Nairobi',
          item: 'Item',
          status: status,
          riderId: '2',
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        );
      }

      expect(makeDelivery('pending').displayStatus, 'Created');

      expect(makeDelivery('assigned').displayStatus, 'Assigned');

      expect(makeDelivery('in_transit').displayStatus, 'Picked Up');

      expect(makeDelivery('delivered').displayStatus, 'Delivered');
    });
  });
}
