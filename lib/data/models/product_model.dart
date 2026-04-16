class ProductModel {
  final String id;
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;
  final bool isAvailable;
  final String? category;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    this.isAvailable = true,
    this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        price: double.tryParse((json['pricePkr'] ?? json['price'])?.toString() ?? '0') ?? 0.0,
        description: json['description'],
        imageUrl: json['imageUrl'],
        isAvailable: json['isActive'] ?? json['isAvailable'] ?? true,
        category: json['category'],
      );
}
