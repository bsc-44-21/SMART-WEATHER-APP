import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherLocationService {
  // --- Step 1: Basic Location Permissions ---

  static Future<Position?> getLocationWithPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint('[Weather] Location error: $e');
      return null;
    }
  }

  // --- Step 2: Open-Meteo Data Fetch ---
  static Future<Map<String, dynamic>?> fetchWeather(
    double latitude,
    double longitude, {
    bool isPremium = false,
  }) async {
    try {
      final Uri url = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': latitude.toStringAsFixed(4),
        'longitude': longitude.toStringAsFixed(4),
        'current_weather': 'true',
        'hourly': 'temperature_2m,relativehumidity_2m,precipitation,precipitation_probability,weathercode,windspeed_10m',
        'daily': 'temperature_2m_max,temperature_2m_min,precipitation_sum,weathercode',
        'timezone': 'auto',
        'forecast_days': '7',
      });

      debugPrint('[Weather] Fetching from Open-Meteo: $url');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final currentWeather = jsonResponse['current_weather'] as Map<String, dynamic>?;
        final hourly = jsonResponse['hourly'] as Map<String, dynamic>?;
        final daily = jsonResponse['daily'] as Map<String, dynamic>?;

        if (currentWeather != null && hourly != null && daily != null) {
          final hourlyTimes = List<String>.from(hourly['time'] as List<dynamic>);
          final currentIndex = hourlyTimes.indexOf(currentWeather['time'] as String).clamp(0, hourlyTimes.length - 1);

          final hourlyTemps = (hourly['temperature_2m'] as List<dynamic>).map((item) => (item as num).toDouble()).toList();
          final hourlyCodes = (hourly['weathercode'] as List<dynamic>).map((item) => (item as num).toInt()).toList();
          final hourlyPops = (hourly['precipitation_probability'] as List<dynamic>).map((item) => (item as num).toInt()).toList();
          final hourlyPrecip = (hourly['precipitation'] as List<dynamic>).map((item) => (item as num).toDouble()).toList();

          final dailyTimes = List<String>.from(daily['time'] as List<dynamic>);
          final dailyMax = (daily['temperature_2m_max'] as List<dynamic>).map((item) => (item as num).toDouble()).toList();
          final dailyMin = (daily['temperature_2m_min'] as List<dynamic>).map((item) => (item as num).toDouble()).toList();
          final dailyCodes = (daily['weathercode'] as List<dynamic>).map((item) => (item as num).toInt()).toList();
          final dailyPrecip = (daily['precipitation_sum'] as List<dynamic>).map((item) => (item as num).toDouble()).toList();

          final int maxDays = isPremium ? 7 : 1;
          return {
            'latitude': latitude,
            'longitude': longitude,
            'current': {
              'temperature_2m': (currentWeather['temperature'] as num).toDouble(),
              'relative_humidity_2m': (hourly['relativehumidity_2m'][currentIndex] as num).toDouble(),
              'wind_speed_10m': (currentWeather['windspeed'] as num).toDouble(),
              'precipitation': hourlyPrecip[currentIndex],
              'weather_code': (currentWeather['weathercode'] as num).toInt(),
              'weather_code_string': 'open-meteo:${currentWeather['weathercode']}',
            },
            'hourly': {
              'time': hourlyTimes.take(24).toList(),
              'temperature_2m': hourlyTemps.take(24).toList(),
              'weather_code': hourlyCodes.take(24).toList(),
              'precipitation_probability': hourlyPops.take(24).toList(),
            },
            'daily': {
              'time': dailyTimes.take(maxDays).toList(),
              'temperature_2m_max': dailyMax.take(maxDays).toList(),
              'temperature_2m_min': dailyMin.take(maxDays).toList(),
              'weather_code': dailyCodes.take(maxDays).toList(),
              'precipitation_sum': dailyPrecip.take(maxDays).toList(),
            },
          };
        }
        return null;
      } else {
        debugPrint('[Weather] Open-Meteo Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('[Weather] Open-Meteo Exception: $e');
      return null;
    }

    return null;
  }

  static int _getInternalCode(String symbol) {
    if (symbol.contains('clearsky')) return 0;
    if (symbol.contains('fair')) return 1;
    if (symbol.contains('partlycloudy')) return 2;
    if (symbol.contains('cloudy')) return 3;
    if (symbol.contains('fog')) return 45;
    if (symbol.contains('lightrain')) return 61;
    if (symbol.contains('rain')) return 63;
    if (symbol.contains('heavyrain')) return 65;
    if (symbol.contains('thunderstorm')) return 95;
    return 3; // Default to cloudy
  }

  static String getWeatherDescription(int weatherCode) {
    const Map<int, String> weatherDescriptions = {

      0: 'Clear sky',
      1: 'Mainly clear',
      2: 'Partly cloudy',
      3: 'Overcast',
      45: 'Foggy',
      48: 'Depositing rime fog',
      51: 'Light drizzle',
      53: 'Moderate drizzle',
      55: 'Dense drizzle',
      61: 'Slight rain',
      63: 'Moderate rain',
      65: 'Heavy rain',
      71: 'Slight snow',
      73: 'Moderate snow',
      75: 'Heavy snow',
      77: 'Snow grains',
      80: 'Slight rain showers',
      81: 'Moderate rain showers',
      82: 'Violent rain showers',
      85: 'Slight snow showers',
      86: 'Heavy snow showers',
      95: 'Thunderstorm',
      96: 'Thunderstorm with slight hail',
      99: 'Thunderstorm with heavy hail',
    };
    return weatherDescriptions[weatherCode] ?? 'Unknown';
  }

  static String getWeatherEmoji(int weatherCode) {
    if (weatherCode == 0) return '☀️';
    if (weatherCode == 1 || weatherCode == 2) return '⛅';
    if (weatherCode == 3) return '☁️';
    if (weatherCode == 45 || weatherCode == 48) return '🌫️';
    if (weatherCode >= 51 && weatherCode <= 65) return '🌧️';
    if (weatherCode >= 71 && weatherCode <= 77) return '❄️';
    if (weatherCode >= 80 && weatherCode <= 82) return '🌧️';
    if (weatherCode >= 85 && weatherCode <= 86) return '🌨️';
    if (weatherCode >= 95) return '⛈️';
    return '🌤️';
  }
}