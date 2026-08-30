import '../models/delivery.dart';

class RetailerApiException implements Exception {
  final int statusCode;
  final String message;

  RetailerApiException(this.statusCode, this.message);

  @override
  String toString() => 'Retailer API error $statusCode: $message';
}

class RetailerNetworkException implements Exception {
  final String message;

  RetailerNetworkException(this.message);

  @override
  String toString() => message;
}

abstract class RetailerService {
  Future<List<Delivery>> getMyDeliveries({required String retailerId});

  Future<Delivery> createDelivery({
    required String retailerId,
    required String customerName,
    required String phone,
    required String address,
    required String item,
  });
}
