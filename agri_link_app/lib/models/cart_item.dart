class CartItem {
  final int id;
  final int clientId;
  final int productId;
  int quantity;
  final String productName;
  final double price;
  final String unit;
  final String imageUrl;
  final int adminId;
  final String adminName;
  final String companyName;

  CartItem({
    required this.id,
    required this.clientId,
    required this.productId,
    required this.quantity,
    required this.productName,
    required this.price,
    required this.unit,
    required this.imageUrl,
    required this.adminId,
    required this.adminName,
    required this.companyName,
  });

  double get subtotal => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? 0,
      clientId: json['client_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 1,
      productName: json['name'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      unit: json['unit'] ?? '',
      imageUrl: json['image_url'] ?? '',
      adminId: json['admin_id'] ?? 0,
      adminName: json['admin_name'] ?? '',
      companyName: json['company_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'product_id': productId,
      'quantity': quantity,
      'name': productName,
      'price': price,
      'unit': unit,
      'image_url': imageUrl,
      'admin_id': adminId,
      'admin_name': adminName,
      'company_name': companyName,
    };
  }
}
