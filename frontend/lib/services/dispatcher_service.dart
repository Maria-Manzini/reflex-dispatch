import '../models/delivery.dart';

class DispatcherApiException implements Exception {
  final int statusCode;
  final String message;

  DispatcherApiException(this.statusCode, this.message);

  @override
  String toString() => 'Dispatcher API error $statusCode: $message';
}

abstract class DispatcherService {
  Future<List<Delivery>> getOpenDeliveries();

  Future<Delivery> assignDelivery({
    required String deliveryId,
    required String riderId,
  });
}
