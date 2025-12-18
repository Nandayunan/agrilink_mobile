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
    // Tunggu provinces selesai dulu, baru load weather
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadProvinces();
      // Set provinsi pertama dari list jika ada, atau tetap pakai default
      final weatherProvider = context.read<WeatherProvider>();
      if (weatherProvider.provinces.isNotEmpty) {
        setState(() {
          _selectedProvince = weatherProvider.provinces.first['name'] ?? 'Jawa Barat';
        });
      }
      await _loadWeather();
    });
  }

  Future<void> _loadProvinces() async {
    if (!mounted) return;
    final weatherProvider = context.read<WeatherProvider>();
    await weatherProvider.fetchProvinces();
  }

  Future<void> _loadWeather() async {
    if (!mounted) return;
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
                  else if (weatherProvider.error.isNotEmpty)
                    Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Error: ${weatherProvider.error}',
                              style: TextStyle(color: Colors.red),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadWeather,
                              child: Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    )
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

    final location = weatherData['location'] as Map<String, dynamic>?;
    final current = weatherData['current'] as Map<String, dynamic>?;
    final forecast = (weatherData['forecast'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    String _fmt(dynamic value, {String suffix = ''}) {
      if (value == null) return '-';
      if (value is num) return '$value$suffix';
      return '$value$suffix';
    }

    String _fmtTemp(dynamic value) {
      if (value == null) return '-';
      if (value is num) return '${value.toStringAsFixed(0)}°C';
      return '$value°C';
    }

    String _fmtTime(dynamic value) {
      if (value == null) return '-';
      return value.toString();
    }

    IconData _iconForWeather(dynamic code, dynamic desc) {
      final d = desc?.toString().toLowerCase() ?? '';
      final c = code is num ? code.toInt() : -1;
      if (d.contains('hujan') || c == 60 || c == 61) return Icons.umbrella;
      if (d.contains('berawan') || c == 3) return Icons.cloud;
      if (d.contains('cerah') || c == 1 || c == 2) return Icons.wb_sunny;
      return Icons.cloud_queue;
    }

    final currentIcon = _iconForWeather(current?['weather_code'], current?['weather_desc']);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Icon(
                    currentIcon,
                    size: 64,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cuaca di ${location?['provinsi'] ?? _selectedProvince}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (location?['kotkab'] != null)
                    Text(
                      '${location?['kotkab']}',
                      style: TextStyle(color: AppTheme.textGray),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildWeatherInfo('Kondisi', current?['weather_desc'] ?? '-'),
            _buildWeatherInfo('Suhu', _fmtTemp(current?['temperature'])),
            _buildWeatherInfo('Kelembapan', _fmt(current?['humidity'], suffix: '%')),
            _buildWeatherInfo('Angin', '${_fmt(current?['wind_speed'], suffix: ' km/j')} ${current?['wind_dir'] ?? ''}'.trim()),
            _buildWeatherInfo('Tutupan Awan', _fmt(current?['cloud_cover'], suffix: '%')),
            _buildWeatherInfo('Jarak Pandang', _fmt(current?['visibility'])),
            _buildWeatherInfo('Diperbarui', _fmtTime(current?['datetime'] ?? current?['analysis_date'])),
            if (forecast.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Perkiraan Singkat',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Column(
                children: forecast.take(5).map((item) {
                  final ic = _iconForWeather(item['weather_code'], item['weather_desc']);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(ic, size: 20, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item['weather_desc'] ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(_fmtTemp(item['temperature'])),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ]
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
