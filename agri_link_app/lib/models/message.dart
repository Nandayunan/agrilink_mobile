class Message {
  final int id;
  final int senderId;
  final int recipientId;
  final String title;
  final String content;
  final String messageType; // inquiry, offer, update, order_related
  final bool isRead;
  final DateTime createdAt;
  final String senderName;
  final String senderCompany;
  final String senderRole;
  final String? recipientName;
  final String? recipientRole;

  Message({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.title,
    required this.content,
    required this.messageType,
    required this.isRead,
    required this.createdAt,
    required this.senderName,
    required this.senderCompany,
    required this.senderRole,
    this.recipientName,
    this.recipientRole,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      recipientId: json['recipient_id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      messageType: json['message_type'] ?? 'inquiry',
      isRead: (json['is_read'] ?? 0) == 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      senderName: json['sender_name'] ?? '',
      senderCompany: json['sender_company'] ?? '',
      senderRole: json['sender_role'] ?? 'admin',
      recipientName: json['recipient_name'],
      recipientRole: json['recipient_role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'recipient_id': recipientId,
      'title': title,
      'content': content,
      'message_type': messageType,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'sender_name': senderName,
      'sender_company': senderCompany,
      'sender_role': senderRole,
    };
  }
}

class Contact {
  final int id;
  final String name;
  final String? companyName;
  final String? phone;
  final String? city;
  final String? province;
  final String role;
  final String contactType; // supplier, farmer

  Contact({
    required this.id,
    required this.name,
    this.companyName,
    this.phone,
    this.city,
    this.province,
    required this.role,
    required this.contactType,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      companyName: json['company_name'],
      phone: json['phone'],
      city: json['city'],
      province: json['province'],
      role: json['role'] ?? 'admin',
      contactType: json['contact_type'] ?? 'supplier',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company_name': companyName,
      'phone': phone,
      'city': city,
      'province': province,
      'role': role,
      'contact_type': contactType,
    };
  }
}
