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
    debugPrint('[WEATHER_PROVIDER] fetchWeatherByProvince() called with: $province');
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.getWeatherByProvince(province);
      debugPrint('[WEATHER_PROVIDER] fetchWeatherByProvince response: $response');
      if (response['success'] == true) {
        _weatherData = response['data'];
        _error = '';
        debugPrint('[WEATHER_PROVIDER] Weather data loaded');
      } else {
        _error = response['message'] ?? 'Failed to fetch weather';
        debugPrint('[WEATHER_PROVIDER] fetchWeatherByProvince error: $_error');
      }
    } catch (e) {
      _error = 'Error: $e';
      debugPrint('[WEATHER_PROVIDER] fetchWeatherByProvince exception: $e');
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
    debugPrint('[WEATHER_PROVIDER] fetchProvinces() called');
    try {
      final response = await ApiService.getProvinces();
      debugPrint('[WEATHER_PROVIDER] fetchProvinces response: $response');
      if (response['success'] == true) {
        _provinces = List<Map<String, dynamic>>.from(
          (response['data'] as List).map(
            (p) => {'id': p['id'], 'name': p['name']},
          ),
        );
        debugPrint('[WEATHER_PROVIDER] Provinces loaded: ${_provinces.length}');
        _error = '';
      } else {
        _error = response['message'] ?? 'Failed to fetch provinces';
        debugPrint('[WEATHER_PROVIDER] fetchProvinces error: $_error');
      }
      notifyListeners();
    } catch (e) {
      _error = 'Error: $e';
      debugPrint('[WEATHER_PROVIDER] fetchProvinces exception: $e');
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
