import '../models/delivery.dart';

abstract class RiderService {
  Future<List<Delivery>> getMyDeliveries();

  Future<Delivery> updateStatus({
    required String deliveryId,
    required String status,
    String? scanCode,
  });
}
