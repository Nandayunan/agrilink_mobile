import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String _error = '';

  Map<int, List<CartItem>> get groupedBySupplier {
    final Map<int, List<CartItem>> grouped = {};
    for (var item in _cartItems) {
      if (!grouped.containsKey(item.adminId)) {
        grouped[item.adminId] = [];
      }
      grouped[item.adminId]!.add(item);
    }
    return grouped;
  }

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get totalItems => _cartItems.length;

  double get totalAmount {
    return _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  Future<void> fetchCart() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.getCart();
      if (response['success'] == true) {
        final items = (response['data']['items'] as List? ?? []);
        _cartItems = [];

        for (var supplierGroup in items) {
          final supplierItems = (supplierGroup['items'] as List? ?? []);
          for (var item in supplierItems) {
            _cartItems.add(CartItem.fromJson(item));
          }
        }
        _error = '';
      } else {
        _error = response['message'] ?? 'Failed to fetch cart';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addToCart({
    required int productId,
    required int quantity,
  }) async {
    try {
      final response = await ApiService.addToCart(
        productId: productId,
        quantity: quantity,
      );

      if (response['success'] == true) {
        await fetchCart();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to add to cart';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCartItem({
    required int cartId,
    required int quantity,
  }) async {
    try {
      final response = await ApiService.updateCartItem(
        cartId: cartId,
        quantity: quantity,
      );

      if (response['success'] == true) {
        await fetchCart();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to update cart';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFromCart(int cartId) async {
    try {
      final response = await ApiService.removeFromCart(cartId);
      if (response['success'] == true) {
        await fetchCart();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to remove item';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: $e';
      notifyListeners();
      return false;
    }
  }

  void clearCart() {
    _cartItems = [];
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
