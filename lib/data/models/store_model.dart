class StoreModel {
  final String id;
  final String name;
  final String? description;
  final String? phone;
  final String? address;
  final double? lat;
  final double? lng;
  final bool isOpen;
  final String? logoUrl;
  final String? type; // 'store' or 'restaurant'

  StoreModel({
    required this.id,
    required this.name,
    this.description,
    this.phone,
    this.address,
    this.lat,
    this.lng,
    required this.isOpen,
    this.logoUrl,
    this.type,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) => StoreModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'],
        phone: json['phone'],
        address: json['address'],
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        isOpen: json['isOpen'] ?? false,
        logoUrl: json['logoUrl'],
        type: json['type'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'phone': phone,
        'address': address,
        'lat': lat,
        'lng': lng,
        'isOpen': isOpen,
        'logoUrl': logoUrl,
        'type': type,
      };
}
