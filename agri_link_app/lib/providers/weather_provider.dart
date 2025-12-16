import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WeatherProvider extends ChangeNotifier {
  Map<String, dynamic>? _weatherData;
  List<Map<String, dynamic>> _provinces = [];
  bool _isLoading = false;
  String _error = '';

  Map<String, dynamic>? get weatherData => _weatherData;
  List<Map<String, dynamic>> get provinces => _provinces;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchWeatherByProvince(String province) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.getWeatherByProvince(province);
      if (response['success'] == true) {
        _weatherData = response['data'];
        _error = '';
      } else {
        _error = response['message'] ?? 'Failed to fetch weather';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchWeatherByLocation({
    required double latitude,
    required double longitude,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.getWeatherByLocation(
        latitude: latitude,
        longitude: longitude,
      );
      if (response['success'] == true) {
        _weatherData = response['data'];
        _error = '';
      } else {
        _error = response['message'] ?? 'Failed to fetch weather';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchProvinces() async {
    try {
      final response = await ApiService.getProvinces();
      if (response['success'] == true) {
        _provinces = List<Map<String, dynamic>>.from(
          (response['data'] as List).map(
            (p) => {'id': p['id'], 'name': p['name']},
          ),
        );
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error: $e';
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
