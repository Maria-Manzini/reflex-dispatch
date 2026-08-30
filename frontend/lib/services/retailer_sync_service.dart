import 'dart:async';

import '../cache/pending_delivery_store.dart';
import '../models/delivery.dart';
import '../network/connectivity_service.dart';
import 'retailer_service.dart';

enum DeliverySubmitState { created, queued }

class DeliverySubmitResult {
  final DeliverySubmitState state;
  final Delivery? delivery;

  const DeliverySubmitResult._({required this.state, this.delivery});

  factory DeliverySubmitResult.created(Delivery delivery) {
    return DeliverySubmitResult._(
      state: DeliverySubmitState.created,
      delivery: delivery,
    );
  }

  factory DeliverySubmitResult.queued() {
    return const DeliverySubmitResult._(state: DeliverySubmitState.queued);
  }
}

class RetailerSyncService {
  final RetailerService retailerService;
  final PendingDeliveryStore pendingStore;
  final ConnectivityService connectivityService;

  StreamSubscription<bool>? _subscription;

  RetailerSyncService({
    required this.retailerService,
    required this.pendingStore,
    required this.connectivityService,
  });

  void start({void Function()? onSyncComplete}) {
    _subscription ??= connectivityService.changes.listen((connected) async {
      if (!connected) {
        return;
      }

      final count = await syncPending();

      if (count > 0) {
        onSyncComplete?.call();
      }
    });
  }

  Future<DeliverySubmitResult> submit({
    required String retailerId,
    required String customerName,
    required String phone,
    required String address,
    required String item,
  }) async {
    final pending = PendingDelivery(
      retailerId: retailerId,
      customerName: customerName,
      phone: phone,
      address: address,
      item: item,
      createdAt: DateTime.now().toUtc(),
    );

    if (!await connectivityService.isConnected) {
      await pendingStore.save(pending);

      return DeliverySubmitResult.queued();
    }

    try {
      final delivery = await retailerService.createDelivery(
        retailerId: retailerId,
        customerName: customerName,
        phone: phone,
        address: address,
        item: item,
      );

      return DeliverySubmitResult.created(delivery);
    } on RetailerNetworkException {
      await pendingStore.save(pending);

      return DeliverySubmitResult.queued();
    }
  }

  Future<int> syncPending() async {
    if (!await connectivityService.isConnected) {
      return 0;
    }

    final deliveries = await pendingStore.all();

    var synced = 0;

    for (final pending in deliveries) {
      try {
        await retailerService.createDelivery(
          retailerId: pending.retailerId,
          customerName: pending.customerName,
          phone: pending.phone,
          address: pending.address,
          item: pending.item,
        );

        await pendingStore.remove(pending.key);

        synced++;
      } on RetailerNetworkException {
        break;
      } on RetailerApiException {
        continue;
      }
    }

    return synced;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
