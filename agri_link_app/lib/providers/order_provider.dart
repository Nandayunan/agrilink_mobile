import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String _error = '';

  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchOrders({String? status}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.getOrders(status: status);
      if (response['success'] == true) {
        final orderList = (response['data']['orders'] as List)
            .map((o) => Order.fromJson(o))
            .toList();
        _orders = orderList;
        _error = '';
      } else {
        _error = response['message'] ?? 'Failed to fetch orders';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createOrder({
    required int adminId,
    required List<Map<String, dynamic>> items,
    double discountPercentage = 0,
    double serviceFee = 0,
    double taxPercentage = 0,
    required String deliveryAddress,
    required DateTime deliveryDate,
    String? notes,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.createOrder(
        adminId: adminId,
        items: items,
        discountPercentage: discountPercentage,
        serviceFee: serviceFee,
        taxPercentage: taxPercentage,
        deliveryAddress: deliveryAddress,
        deliveryDate: deliveryDate,
        notes: notes,
      );

      if (response['success'] == true) {
        await fetchOrders();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to create order';
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

  Future<void> fetchOrderById(int orderId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.getOrderById(orderId);
      if (response['success'] == true) {
        _selectedOrder = Order.fromJson(response['data']);
        _error = '';
      } else {
        _error = response['message'] ?? 'Failed to fetch order';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchSupplierOrders({String? status}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.getSupplierOrders(status: status);
      if (response['success'] == true) {
        final orderList = (response['data']['orders'] as List)
            .map((o) => Order.fromJson(o))
            .toList();
        _orders = orderList;
        _error = '';
      } else {
        _error = response['message'] ?? 'Failed to fetch orders';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.updateOrderStatus(
        orderId: orderId,
        status: status,
      );

      if (response['success'] == true) {
        await fetchOrders();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to update order';
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

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
