import 'package:hive/hive.dart';

class PendingDelivery {
  final dynamic key;
  final String retailerId;
  final String customerName;
  final String phone;
  final String address;
  final String item;
  final DateTime createdAt;

  const PendingDelivery({
    this.key,
    required this.retailerId,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.item,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'retailerId': retailerId,
      'customerName': customerName,
      'phone': phone,
      'address': address,
      'item': item,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PendingDelivery.fromMap(dynamic key, Map<String, dynamic> map) {
    return PendingDelivery(
      key: key,
      retailerId: map['retailerId'] as String,
      customerName: map['customerName'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String,
      item: map['item'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

abstract class PendingDeliveryStore {
  Future<void> save(PendingDelivery delivery);

  Future<List<PendingDelivery>> all();

  Future<void> remove(dynamic key);
}

class HivePendingDeliveryStore implements PendingDeliveryStore {
  static const boxName = 'pending_delivery_creates';

  final Box<dynamic> _box;

  HivePendingDeliveryStore(this._box);

  static Future<HivePendingDeliveryStore> open() async {
    final box = await Hive.openBox<dynamic>(boxName);

    return HivePendingDeliveryStore(box);
  }

  @override
  Future<void> save(PendingDelivery delivery) async {
    await _box.add(delivery.toMap());
  }

  @override
  Future<List<PendingDelivery>> all() async {
    final deliveries = <PendingDelivery>[];

    for (final key in _box.keys) {
      final raw = _box.get(key);

      if (raw is Map) {
        deliveries.add(
          PendingDelivery.fromMap(key, Map<String, dynamic>.from(raw)),
        );
      }
    }

    deliveries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return deliveries;
  }

  @override
  Future<void> remove(dynamic key) async {
    await _box.delete(key);
  }
}
