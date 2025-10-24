import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather.dart';
class Weather {
  final double temp;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  Weather({
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
  });
}

class DailyForecast {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String description;
  final String icon;

  DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
    required this.icon,
  });
}

class WeatherForecast {
  final String cityName;
  final Weather current;
  final List<DailyForecast> daily;

  WeatherForecast({
    required this.cityName,
    required this.current,
    required this.daily,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json, {required String cityName}) {
    final currentJson = json['current'] as Map<String, dynamic>;
    final currWeather = (currentJson['weather'] as List).first;
    final current = Weather(
      temp: (currentJson['temp'] as num).toDouble(),
      feelsLike: (currentJson['feels_like'] as num).toDouble(),
      humidity: (currentJson['humidity'] as num).toInt(),
      windSpeed: (currentJson['wind_speed'] as num).toDouble(),
      description: currWeather['description'],
      icon: currWeather['icon'],
    );

    final dailyList = (json['daily'] as List).take(7).map((d) {
      final w = (d['weather'] as List).first;
      return DailyForecast(
        date: DateTime.fromMillisecondsSinceEpoch((d['dt'] as int) * 1000),
        minTemp: (d['temp']['min'] as num).toDouble(),
        maxTemp: (d['temp']['max'] as num).toDouble(),
        description: w['description'],
        icon: w['icon'],
      );
    }).toList();

    return WeatherForecast(cityName: cityName, current: current, daily: dailyList);
  }

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'current': {
        'temp': current.temp,
        'feelsLike': current.feelsLike,
        'humidity': current.humidity,
        'windSpeed': current.windSpeed,
        'description': current.description,
        'icon': current.icon,
      },
      'daily': daily.map((d) => {
        'dt': d.date.millisecondsSinceEpoch ~/ 1000,
        'min': d.minTemp,
        'max': d.maxTemp,
        'description': d.description,
        'icon': d.icon,
      }).toList(),
    };
  }

  factory WeatherForecast.fromCache(Map<String, dynamic> json) {
    final current = Weather(
      temp: (json['current']['temp'] as num).toDouble(),
      feelsLike: (json['current']['feelsLike'] as num).toDouble(),
      humidity: (json['current']['humidity'] as num).toInt(),
      windSpeed: (json['current']['windSpeed'] as num).toDouble(),
      description: json['current']['description'],
      icon: json['current']['icon'],
    );
    final daily = (json['daily'] as List).map((d) {
      return DailyForecast(
        date: DateTime.fromMillisecondsSinceEpoch((d['dt'] as int) * 1000),
        minTemp: (d['min'] as num).toDouble(),
        maxTemp: (d['max'] as num).toDouble(),
        description: d['description'],
        icon: d['icon'],
      );
    }).toList();
    return WeatherForecast(cityName: json['cityName'], current: current, daily: daily);
  }
}
