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

      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        return lastPosition;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
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
      final int maxDays = isPremium ? 7 : 1;
      final Uri url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?'
          'latitude=${latitude.toStringAsFixed(4)}&longitude=${longitude.toStringAsFixed(4)}'
          '&current_weather=true'
          '&hourly=temperature_2m,relativehumidity_2m,precipitation_probability,weathercode'
          '&daily=weathercode,temperature_2m_max,temperature_2m_min,precipitation_sum'
          '&forecast_days=$maxDays'
          '&timezone=auto');

      debugPrint('[Weather] Fetching from Open-Meteo: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final currentWeather = jsonResponse['current_weather'] as Map<String, dynamic>?;

        final Map<String, dynamic>? current = currentWeather != null
            ? {
                'temperature_2m': currentWeather['temperature'],
                'weather_code': currentWeather['weathercode'],
                'wind_speed_10m': currentWeather['windspeed'],
                'time': currentWeather['time'],
              }
            : null;

        // Normalize hourly keys (Open-Meteo returns 'weathercode' not 'weather_code')
        final hourlyRaw = (jsonResponse['hourly'] as Map<String, dynamic>?) ?? <String, dynamic>{};
        final Map<String, dynamic> hourly = {};
        for (final entry in hourlyRaw.entries) {
          var key = entry.key;
          var value = entry.value;
          if (key == 'weathercode') key = 'weather_code';
          if (key == 'relativehumidity_2m') key = 'relative_humidity_2m';
          hourly[key] = value;
        }
        // Ensure expected lists exist to avoid null -> List errors in the UI
        hourly.putIfAbsent('temperature_2m', () => <dynamic>[]);
        hourly.putIfAbsent('weather_code', () => <dynamic>[]);

        // Normalize daily keys
        final dailyRaw = (jsonResponse['daily'] as Map<String, dynamic>?) ?? <String, dynamic>{};
        final Map<String, dynamic> daily = {};
        for (final entry in dailyRaw.entries) {
          var key = entry.key;
          var value = entry.value;
          if (key == 'weathercode') key = 'weather_code';
          daily[key] = value;
        }
        daily.putIfAbsent('weather_code', () => <dynamic>[]);

        return {
          'latitude': latitude,
          'longitude': longitude,
          'current': current,
          'hourly': hourly,
          'daily': daily,
        };
      } else {
        debugPrint('[Weather] Open-Meteo Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('[Weather] Open-Meteo Exception: $e');
      return null;
    }
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