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

  // ===============================
  // Helper parser (ANTI ERROR)
  // ===============================

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static bool _toBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v == 1;
    final s = v.toString().toLowerCase();
    return s == 'true' || s == '1';
  }

  static DateTime _toDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }

  // ===============================
  // FROM JSON (BACKEND → FLUTTER)
  // ===============================
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _toInt(json['id']),
      adminId: _toInt(json['admin_id']),
      category: (json['category'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: _toDouble(json['price']), // ✅ "15000.00" aman
      stock: _toInt(json['stock']),
      unit: (json['unit'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      adminName: (json['admin_name'] ?? '').toString(),
      companyName: (json['company_name'] ?? '').toString(),
      isAvailable: _toBool(json['is_available']), // ✅ 1 / true
      createdAt: _toDate(json['created_at']),
    );
  }

  // ===============================
  // TO JSON (FLUTTER → BACKEND)
  // ===============================
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
      'is_available': isAvailable ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
