class OrderModel {
  final String id;
  final String status;
  final double total;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  final List<OrderItemModel> items;
  final String? riderName;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.status,
    required this.total,
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    this.items = const [],
    this.riderName,
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final address = json['address'];
    String? deliveryAddr;
    if (address != null) {
      final parts = [address['street'], address['city']].where((e) => e != null).join(', ');
      deliveryAddr = parts.isNotEmpty ? parts : null;
    }
    return OrderModel(
      id: json['id'] ?? '',
      status: json['status'] ?? 'PLACED',
      total: double.tryParse(json['totalPkr']?.toString() ?? '0') ?? 0.0,
      customerName: json['customer']?['name'],
      customerPhone: json['customer']?['phone'],
      deliveryAddress: deliveryAddr,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItemModel.fromJson(e))
              .toList() ??
          [],
      riderName: json['rider']?['name'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}

class OrderItemModel {
  final String name;
  final int quantity;
  final double price;

  OrderItemModel({
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        name: json['menuItem']?['name'] ??
            json['storeProduct']?['product']?['name'] ??
            json['name'] ?? '',
        quantity: json['quantity'] ?? 1,
        price: double.tryParse(json['unitPricePkr']?.toString() ?? '0') ?? 0.0,
      );
}
