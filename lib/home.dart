import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather_forecast.dart';

class WeatherService {
  final String _apiKey = dotenv.env['OWM_API_KEY'] ?? 'YOUR_API_KEY';
  final String _onecallBase = 'https://api.openweathermap.org/data/2.5/onecall';
  final String _reverseGeocode = 'https://api.openweathermap.org/geo/1.0/reverse';

  Future<WeatherForecast> fetchWeatherByCoords({
    required double lat,
    required double lon,
    String units = 'metric',
    String lang = 'en',
  }) async {
    final uri = Uri.parse('$_onecallBase?lat=$lat&lon=$lon&exclude=minutely,alerts&units=$units&lang=$lang&appid=$_apiKey');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      // Get city name by reverse geocode
      final name = await _fetchPlaceName(lat, lon);
      return WeatherForecast.fromJson(json, cityName: name);
    } else {
      throw Exception('Weather API error: ${res.statusCode} ${res.body}');
    }
  }

  Future<String> _fetchPlaceName(double lat, double lon) async {
    try {
      final uri = Uri.parse("$_reverseGeocode?lat=$lat&lon=$lon&limit=1&appid=$_apiKey");
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        if (list.isNotEmpty) {
          final obj = list[0];
          final name = obj['name'] ?? '';
          final state = obj['state'] ?? '';
          final country = obj['country'] ?? '';
          return [name, state, country].where((s) => s != null && s.toString().isNotEmpty).join(', ');
        }
      }
    } catch (_) {}
    return 'Current Location';
  }
}
