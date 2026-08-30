class Delivery {
  final String id;
  final String customerName;
  final String phone;
  final String address;
  final String item;
  final String status;
  final String? riderId;
  final String? proofScan;
  final DateTime createdAt;
  final DateTime updatedAt;

  Delivery({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.item,
    required this.status,
    required this.riderId,
    this.proofScan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['_id'] as String,
      customerName: json['customerName'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      item: json['item'] as String,
      status: json['status'] as String,
      riderId: json['riderId'] as String?,
      proofScan: json['proofScan'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Delivery copyWith({String? status, String? proofScan}) {
    return Delivery(
      id: id,
      customerName: customerName,
      phone: phone,
      address: address,
      item: item,
      status: status ?? this.status,
      riderId: riderId,
      proofScan: proofScan ?? this.proofScan,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  String get displayStatus {
    switch (status) {
      case 'pending':
        return 'Created';
      case 'assigned':
        return 'Assigned';
      case 'in_transit':
        return 'Picked Up';
      case 'delivered':
        return 'Delivered';
      default:
        return status;
    }
  }
}
