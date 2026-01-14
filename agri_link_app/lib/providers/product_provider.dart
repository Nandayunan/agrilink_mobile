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

  // ============================================
  // CRUD FOR FARMERS (PETANI)
  // ============================================

  /// Fetch products by admin ID (untuk petani)
  Future<void> fetchProductsByAdmin(int adminId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.getProducts(adminId: adminId);

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

  /// Create new product (CREATE)
  Future<bool> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String unit,
    required String category,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.createProduct(
        name: name,
        description: description,
        price: price,
        stock: stock,
        unit: unit,
        category: category,
      );

      if (response['success'] == true) {
        // Add new product to list
        final newProduct = Product.fromJson(response['data']);
        _products.add(newProduct);
        _error = '';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to create product';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update existing product (UPDATE)
  Future<bool> updateProduct({
    required int productId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String unit,
    required String category,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.updateProduct(
        productId: productId,
        name: name,
        description: description,
        price: price,
        stock: stock,
        unit: unit,
        category: category,
      );

      if (response['success'] == true) {
        // Update product in list
        final updatedProduct = Product.fromJson(response['data']);
        final index = _products.indexWhere((p) => p.id == productId);
        if (index >= 0) {
          _products[index] = updatedProduct;
        }
        _error = '';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to update product';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete product (DELETE)
  Future<bool> deleteProduct(int productId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.deleteProduct(productId);

      if (response['success'] == true) {
        // Remove product from list
        _products.removeWhere((p) => p.id == productId);
        _error = '';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to delete product';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
