import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, String>> getHeaders({bool withAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};

    if (withAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Auth Services
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? companyName,
    String? city,
    String? province,
    String? address,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: await getHeaders(withAuth: false),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          'phone': phone,
          'company_name': companyName,
          'city': city,
          'province': province,
          'address': address,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await getHeaders(withAuth: false),
        body: jsonEncode({'email': email, 'password': password}),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: await getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Product Services
  static Future<Map<String, dynamic>> getProducts({
    String? category,
    String? search,
    int? adminId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final params = {'limit': limit.toString(), 'offset': offset.toString()};

      if (category != null) params['category'] = category;
      if (search != null) params['search'] = search;
      if (adminId != null) params['admin_id'] = adminId.toString();

      final uri = Uri.parse(
        '$baseUrl/products',
      ).replace(queryParameters: params);
      final response = await http.get(
        uri,
        headers: await getHeaders(withAuth: false),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getProductById(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId'),
        headers: await getHeaders(withAuth: false),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/categories/list'),
        headers: await getHeaders(withAuth: false),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Cart Services
  static Future<Map<String, dynamic>> getCart() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cart'),
        headers: await getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> addToCart({
    required int productId,
    required int quantity,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart/add'),
        headers: await getHeaders(),
        body: jsonEncode({'product_id': productId, 'quantity': quantity}),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateCartItem({
    required int cartId,
    required int quantity,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/cart/$cartId'),
        headers: await getHeaders(),
        body: jsonEncode({'quantity': quantity}),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> removeFromCart(int cartId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cart/$cartId'),
        headers: await getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Order Services
  static Future<Map<String, dynamic>> createOrder({
    required int adminId,
    required List<Map<String, dynamic>> items,
    double discountPercentage = 0,
    double serviceFee = 0,
    double taxPercentage = 0,
    required String deliveryAddress,
    required DateTime deliveryDate,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: await getHeaders(),
        body: jsonEncode({
          'admin_id': adminId,
          'items': items,
          'discount_percentage': discountPercentage,
          'service_fee': serviceFee,
          'tax_percentage': taxPercentage,
          'delivery_address': deliveryAddress,
          'delivery_date': deliveryDate.toIso8601String(),
          'notes': notes,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getOrders({
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final params = {'limit': limit.toString(), 'offset': offset.toString()};

      if (status != null) params['status'] = status;

      final uri = Uri.parse('$baseUrl/orders').replace(queryParameters: params);
      final response = await http.get(uri, headers: await getHeaders());

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getOrderById(int orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: await getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Weather Services
  static Future<Map<String, dynamic>> getWeatherByProvince(
    String province,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/weather/province/$province'),
        headers: await getHeaders(withAuth: false),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getWeatherByLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/weather/location/$latitude/$longitude'),
        headers: await getHeaders(withAuth: false),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getProvinces() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/weather/provinces/list'),
        headers: await getHeaders(withAuth: false),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Users Services
  static Future<Map<String, dynamic>> getSuppliers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/suppliers/list'),
        headers: await getHeaders(withAuth: false),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Error occurred',
          'data': body['data'],
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to parse response'};
    }
  }
}
