import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<String> _categories = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';
  String? _selectedCategory;

  List<Product> get products => _products;
  List<String> get categories => _categories;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  Future<void> fetchProducts({
    String? category,
    String? search,
    int? adminId,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.getProducts(
        category: category,
        search: search,
        adminId: adminId,
      );

      if (response['success'] == true) {
        final productList = (response['data']['products'] as List)
            .map((p) => Product.fromJson(p))
            .toList();
        _products = productList;
        _error = '';
      } else {
        _error = response['message'] ?? 'Failed to fetch products';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await ApiService.getCategories();
      if (response['success'] == true) {
        _categories = List<String>.from(response['data'] ?? []);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error: $e';
    }
  }

  Future<void> fetchProductById(int productId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.getProductById(productId);
      if (response['success'] == true) {
        _selectedProduct = Product.fromJson(response['data']);
        _error = '';
      } else {
        _error = response['message'] ?? 'Failed to fetch product';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
