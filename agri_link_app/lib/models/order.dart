class Order {
  final int id;
  final String orderNumber;
  final int clientId;
  final int adminId;
  final double subtotal;
  final double discountPercentage;
  final double discountAmount;
  final double serviceFee;
  final double taxPercentage;
  final double taxAmount;
  final double grandTotal;
  final String status;
  final String paymentStatus;
  final String deliveryAddress;
  final DateTime deliveryDate;
  final String notes;
  final String adminName;
  final String companyName;
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderNumber,
    required this.clientId,
    required this.adminId,
    required this.subtotal,
    required this.discountPercentage,
    required this.discountAmount,
    required this.serviceFee,
    required this.taxPercentage,
    required this.taxAmount,
    required this.grandTotal,
    required this.status,
    required this.paymentStatus,
    required this.deliveryAddress,
    required this.deliveryDate,
    required this.notes,
    required this.adminName,
    required this.companyName,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      clientId: json['client_id'] ?? 0,
      adminId: json['admin_id'] ?? 0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      discountPercentage:
          double.tryParse(json['discount_percentage']?.toString() ?? '0') ?? 0,
      discountAmount:
          double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0,
      serviceFee: double.tryParse(json['service_fee']?.toString() ?? '0') ?? 0,
      taxPercentage:
          double.tryParse(json['tax_percentage']?.toString() ?? '0') ?? 0,
      taxAmount: double.tryParse(json['tax_amount']?.toString() ?? '0') ?? 0,
      grandTotal: double.tryParse(json['grand_total']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status'] ?? 'unpaid',
      deliveryAddress: json['delivery_address'] ?? '',
      deliveryDate: json['delivery_date'] != null
          ? DateTime.parse(json['delivery_date'])
          : DateTime.now(),
      notes: json['notes'] ?? '',
      adminName: json['admin_name'] ?? '',
      companyName: json['company_name'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'client_id': clientId,
      'admin_id': adminId,
      'subtotal': subtotal,
      'discount_percentage': discountPercentage,
      'discount_amount': discountAmount,
      'service_fee': serviceFee,
      'tax_percentage': taxPercentage,
      'tax_amount': taxAmount,
      'grand_total': grandTotal,
      'status': status,
      'payment_status': paymentStatus,
      'delivery_address': deliveryAddress,
      'delivery_date': deliveryDate.toIso8601String(),
      'notes': notes,
      'admin_name': adminName,
      'company_name': companyName,
      'created_at': createdAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double price;
  final double subtotal;
  final String productName;
  final String imageUrl;
  final String unit;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.subtotal,
    required this.productName,
    required this.imageUrl,
    required this.unit,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      productName: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
      'name': productName,
      'image_url': imageUrl,
      'unit': unit,
    };
  }
}
