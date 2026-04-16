class RiderModel {
  final String id;
  final String name;
  final String phone;
  final bool isAvailable;
  final String? currentOrderId;

  RiderModel({
    required this.id,
    required this.name,
    required this.phone,
    this.isAvailable = true,
    this.currentOrderId,
  });

  factory RiderModel.fromJson(Map<String, dynamic> json) => RiderModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        isAvailable: json['isAvailable'] ?? true,
        currentOrderId: json['currentOrderId'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
      };
}
