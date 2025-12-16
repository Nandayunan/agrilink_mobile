class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String address;
  final String city;
  final String province;
  final String postalCode;
  final String status;
  final String companyName;
  final String avatarUrl;
  final double latitude;
  final double longitude;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.address,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.status,
    required this.companyName,
    required this.avatarUrl,
    required this.latitude,
    required this.longitude,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'client',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      province: json['province'] ?? '',
      postalCode: json['postal_code'] ?? '',
      status: json['status'] ?? 'approved',
      companyName: json['company_name'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'address': address,
      'city': city,
      'province': province,
      'postal_code': postalCode,
      'status': status,
      'company_name': companyName,
      'avatar_url': avatarUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
