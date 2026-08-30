import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/cache/pending_delivery_store.dart';
import 'package:frontend/models/delivery.dart';
import 'package:frontend/network/connectivity_service.dart';
import 'package:frontend/services/retailer_service.dart';
import 'package:frontend/services/retailer_sync_service.dart';

class FakeConnectivityService implements ConnectivityService {
  bool connected;

  FakeConnectivityService(this.connected);

  @override
  Future<bool> get isConnected async => connected;

  @override
  Stream<bool> get changes => const Stream<bool>.empty();
}

class FakePendingStore implements PendingDeliveryStore {
  final List<PendingDelivery> items = [];

  int _nextKey = 1;

  @override
  Future<void> save(PendingDelivery delivery) async {
    items.add(
      PendingDelivery(
        key: _nextKey++,
        retailerId: delivery.retailerId,
        customerName: delivery.customerName,
        phone: delivery.phone,
        address: delivery.address,
        item: delivery.item,
        createdAt: delivery.createdAt,
      ),
    );
  }

  @override
  Future<List<PendingDelivery>> all() async {
    return List.unmodifiable(items);
  }

  @override
  Future<void> remove(dynamic key) async {
    items.removeWhere((item) => item.key == key);
  }
}

class FakeRetailerService implements RetailerService {
  int creates = 0;

  @override
  Future<Delivery> createDelivery({
    required String retailerId,
    required String customerName,
    required String phone,
    required String address,
    required String item,
  }) async {
    creates++;

    final now = DateTime.utc(2026);

    return Delivery(
      id: 'delivery-$creates',
      customerName: customerName,
      phone: phone,
      address: address,
      item: item,
      status: 'pending',
      riderId: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<List<Delivery>> getMyDeliveries({required String retailerId}) async {
    return [];
  }
}

void main() {
  test('offline delivery queues and later syncs', () async {
    final connectivity = FakeConnectivityService(false);

    final pendingStore = FakePendingStore();

    final retailerService = FakeRetailerService();

    final syncService = RetailerSyncService(
      retailerService: retailerService,
      pendingStore: pendingStore,
      connectivityService: connectivity,
    );

    final result = await syncService.submit(
      retailerId: 'retailer-1',
      customerName: 'Grace Akinyi',
      phone: '+254712345678',
      address: 'Westlands',
      item: 'Samsung Galaxy A54',
    );

    expect(result.state, DeliverySubmitState.queued);

    expect(pendingStore.items, hasLength(1));

    expect(retailerService.creates, 0);

    connectivity.connected = true;

    final synced = await syncService.syncPending();

    expect(synced, 1);

    expect(pendingStore.items, isEmpty);

    expect(retailerService.creates, 1);
  });
}
