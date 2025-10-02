import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
void main() => runApp(const WeatherApp());
// Replace with your OpenWeatherMap API key
const String apiKey = 'fa21b33a0b5c7f7128b0d9fd1dfaadaf';
const String apiBase = 'https://api.openweathermap.org/data/2.5/weather';

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
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
        title: const Text('Weather App'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
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
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : _result == null
                ? const Center(child: Text('Search a city to see weather'))
                : _buildWeatherInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo() {
    final w = _result!;
    final updated = DateFormat.yMMMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(w.dt * 1000));

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${w.name}, ${w.country}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Image.network(
            w.iconUrl,
            width: 100,
            height: 100,
            errorBuilder: (_, __, ___) => const Icon(Icons.cloud, size: 80),
          ),
          const SizedBox(height: 12),
          Text('${w.temp.toStringAsFixed(1)}°C', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
          Text(w.description, style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
          const SizedBox(height: 12),
          Text('Feels like: ${w.feelsLike.toStringAsFixed(1)}°C'),
          Text('Humidity: ${w.humidity}%'),
          Text('Wind: ${w.windSpeed} m/s'),
          Text('Updated: $updated'),
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
