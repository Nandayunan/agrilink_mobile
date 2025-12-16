import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_widgets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _selectedProvince = 'Jawa Barat';

  @override
  void initState() {
    super.initState();
    _loadProvinces();
    _loadWeather();
  }

  Future<void> _loadProvinces() async {
    final weatherProvider = context.read<WeatherProvider>();
    await weatherProvider.fetchProvinces();
  }

  Future<void> _loadWeather() async {
    final weatherProvider = context.read<WeatherProvider>();
    await weatherProvider.fetchWeatherByProvince(_selectedProvince);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Informasi Cuaca', showBackButton: false),
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Province Selector
                  const Text(
                    'Pilih Provinsi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  DropdownButton<String>(
                    value: _selectedProvince,
                    isExpanded: true,
                    items: weatherProvider.provinces.isEmpty
                        ? []
                        : weatherProvider.provinces.map((province) {
                            final name = province['name'] ?? 'Unknown';
                            return DropdownMenuItem<String>(
                              value: name,
                              child: Text(name),
                            );
                          }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedProvince = value);
                        _loadWeather();
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  // Weather Info
                  if (weatherProvider.isLoading)
                    const LoadingWidget(message: 'Memuat data cuaca...')
                  else if (weatherProvider.weatherData == null)
                    EmptyStateWidget(
                      title: 'Data Cuaca Tidak Tersedia',
                      message: 'Silakan coba provinsi lain',
                      onRetry: _loadWeather,
                    )
                  else
                    _buildWeatherCard(weatherProvider.weatherData),
                  const SizedBox(height: 16),
                  // Weather Info Text
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informasi Berguna untuk Petani:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '• Pantau cuaca sebelum panen atau penyemaian\n'
                            '• Siapkan sistem irigasi jika cuaca kering\n'
                            '• Hindari kegiatan outdoor saat hujan deras\n'
                            '• Lindungi tanaman dari cuaca ekstrem\n'
                            '• Periksa suhu dan kelembaban udara',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textGray,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeatherCard(Map<String, dynamic>? weatherData) {
    if (weatherData == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud,
                    size: 64,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cuaca di ${_selectedProvince}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildWeatherInfo('Deskripsi', 'Cuaca Saat Ini'),
            _buildWeatherInfo('Status', 'Normal'),
            _buildWeatherInfo('Rekomendasi', 'Optimal untuk pertanian'),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(color: AppTheme.textGray)),
        ],
      ),
    );
  }
}
