class RiderOption {
  final String id;
  final String name;
  final String? phone;

  const RiderOption({required this.id, required this.name, this.phone});

  factory RiderOption.fromJson(Map<String, dynamic> json) {
    return RiderOption(
      id: json['_id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
    );
  }
}
