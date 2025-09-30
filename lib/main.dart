import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() => runApp(const WeatherApp());

const String apiKey = 'fa21b33a0b5c7f7128b0d9fd1dfaadaf'; // <-- Put your OpenWeatherMap API key here
const String apiBase = 'https://api.openweathermap.org/data/2.5/weather';

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WeatherHome(),
    );
  }
}

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});
  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  final TextEditingController _cityController = TextEditingController(text: 'London');
  WeatherResult? _result;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWeather(_cityController.text);
  }

  Future<void> _fetchWeather(String city) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final uri = Uri.parse('$apiBase?q=${Uri.encodeComponent(city)}&units=metric&appid=$apiKey');

    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        setState(() {
          _result = WeatherResult.fromJson(data);
          _loading = false;
        });
      } else {
        final body = json.decode(resp.body);
        setState(() {
          _error = body['message']?.toString() ?? 'Failed to load weather (${resp.statusCode})';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _loading = false;
      });
    }
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));

    if (_result == null) {
      return const Center(child: Text('Search a city to see weather'));
    }

    final w = _result!;
    final updated = DateFormat.yMMMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(w.dt * 1000));

    return RefreshIndicator(
      onRefresh: () async => _fetchWeather(_cityController.text),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        children: [
          Center(
            child: Column(
              children: [
                Text(w.name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(w.country, style: const TextStyle(fontSize: 16, color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Image.network(
              w.iconUrl,
              width: 120,
              height: 120,
              errorBuilder: (_, __, ___) => const Icon(Icons.cloud, size: 96),
            ),
          ),
          const SizedBox(height: 10),
          Center(child: Text('${w.temp.toStringAsFixed(1)}°C', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold))),
          const SizedBox(height: 6),
          Center(child: Text('${w.description}', style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic))),
          const SizedBox(height: 18),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.thermostat_outlined),
                      const SizedBox(width: 10),
                      Text('Feels like: ${w.feelsLike.toStringAsFixed(1)}°C'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.water_drop_outlined),
                      const SizedBox(width: 10),
                      Text('Humidity: ${w.humidity}%'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.air),
                      const SizedBox(width: 10),
                      Text('Wind: ${w.windSpeed} m/s'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 10),
                      Text('Updated: $updated'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSearchPressed() {
    final city = _cityController.text.trim();
    if (city.isEmpty) {
      setState(() => _error = 'Please enter a city name.');
      return;
    }
    FocusScope.of(context).unfocus();
    _fetchWeather(city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Demo'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _onSearchPressed(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _onSearchPressed,
                  child: const Text('Go'),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
}

class WeatherResult {
  final String name;
  final String country;
  final double temp;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final int dt;

  WeatherResult({
    required this.name,
    required this.country,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.dt,
  });

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  factory WeatherResult.fromJson(Map<String, dynamic> json) {
    final sys = json['sys'] ?? {};
    final weatherList = json['weather'] as List<dynamic>? ?? [];
    final main = json['main'] ?? {};
    final wind = json['wind'] ?? {};
    final w0 = weatherList.isNotEmpty ? weatherList[0] : {};
    return WeatherResult(
      name: json['name'] ?? 'Unknown',
      country: sys['country'] ?? '',
      temp: (main['temp'] ?? 0).toDouble(),
      feelsLike: (main['feels_like'] ?? 0).toDouble(),
      humidity: (main['humidity'] ?? 0).toInt(),
      windSpeed: (wind['speed'] ?? 0).toDouble(),
      description: (w0['description'] ?? '').toString(),
      icon: (w0['icon'] ?? '01d').toString(),
      dt: (json['dt'] ?? 0).toInt(),
    );
  }
}
