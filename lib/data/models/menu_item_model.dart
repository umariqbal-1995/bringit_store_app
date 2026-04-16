class MenuItemModel {
  final String id;
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;
  final bool isAvailable;
  final String? category;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    this.isAvailable = true,
    this.category,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) => MenuItemModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        // API returns pricePkr for store menu
        price: double.tryParse(
                (json['pricePkr'] ?? json['price'])?.toString() ?? '0') ??
            0.0,
        description: json['description'],
        imageUrl: json['imageUrl'],
        // API returns isActive for menu items
        isAvailable: json['isActive'] ?? json['isAvailable'] ?? true,
        category: json['category'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'description': description,
        'imageUrl': imageUrl,
        'isAvailable': isAvailable,
        'category': category,
      };
}
