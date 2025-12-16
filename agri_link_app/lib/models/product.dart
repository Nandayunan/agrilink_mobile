class Product {
  final int id;
  final int adminId;
  final String category;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String unit;
  final String imageUrl;
  final String adminName;
  final String companyName;
  final bool isAvailable;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.adminId,
    required this.category,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.unit,
    required this.imageUrl,
    required this.adminName,
    required this.companyName,
    required this.isAvailable,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      adminId: json['admin_id'] ?? 0,
      category: json['category'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      stock: json['stock'] ?? 0,
      unit: json['unit'] ?? '',
      imageUrl: json['image_url'] ?? '',
      adminName: json['admin_name'] ?? '',
      companyName: json['company_name'] ?? '',
      isAvailable: json['is_available'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'admin_id': adminId,
      'category': category,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'unit': unit,
      'image_url': imageUrl,
      'admin_name': adminName,
      'company_name': companyName,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
