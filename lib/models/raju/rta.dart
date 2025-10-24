import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/weather_service.dart';
import '../models/weather_forecast.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _service = WeatherService();

  WeatherForecast? _forecast;
  WeatherForecast? get forecast => _forecast;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Future<void> loadLastCached() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString('last_forecast');
    if (s != null) {
      try {
        final map = jsonDecode(s) as Map<String, dynamic>;
        _forecast = WeatherForecast.fromCache(map);
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<void> fetchByLocation() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final pos = await _determinePosition();
      final wf = await _service.fetchWeatherByCoords(lat: pos.latitude, lon: pos.longitude);
      _forecast = wf;
      await _cacheForecast(wf);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchByCoords(double lat, double lon) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final wf = await _service.fetchWeatherByCoords(lat: lat, lon: lon);
      _forecast = wf;
      await _cacheForecast(wf);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _cacheForecast(WeatherForecast wf) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_forecast', jsonEncode(wf.toJson()));
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable them.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
}
