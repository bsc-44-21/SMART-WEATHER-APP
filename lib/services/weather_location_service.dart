import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  // --- Step 2: MET Norway Data Fetch (Compact) ---
  static Future<Map<String, dynamic>?> fetchWeather(
    double latitude,
    double longitude,
  ) async {
    try {
      // Switching to api.met.no (Strictly Free & More Stable)
      final Uri url = Uri.https('api.met.no', '/weatherapi/locationforecast/2.0/compact', {
        'lat': latitude.toStringAsFixed(4),
        'lon': longitude.toStringAsFixed(4),
      });

      debugPrint('[Weather] Fetching from MET Norway: $url');

      final response = await http.get(
        url,
        headers: {
          // MET Norway REQUIRES a descriptive User-Agent
          'User-Agent': 'SmartWeatherApp/1.0 (https://github.com/yourusername/app contact: email@example.com)',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final properties = jsonResponse['properties'];
        final timeseries = properties['timeseries'] as List;
        
        if (timeseries.isNotEmpty) {
          final currentData = timeseries[0]['data']['instant']['details'];
          final String currentSymbol = timeseries[0]['data']['next_1_hours']?['summary']?['symbol_code'] ?? 'unknown';
          
          // 1. Build Hourly (next 24 entries)
          final List<String> hourlyTimes = [];
          final List<double> hourlyTemps = [];
          final List<int> hourlyCodes = [];
          final List<int> hourlyPops = []; // Precipitation probability (dummy if missing)
          
          for (int i = 0; i < timeseries.length && i < 24; i++) {
            final entry = timeseries[i];
            hourlyTimes.add(entry['time']);
            hourlyTemps.add((entry['data']['instant']['details']['air_temperature'] as num).toDouble());
            final String symbol = entry['data']['next_1_hours']?['summary']?['symbol_code'] ?? 'unknown';
            hourlyCodes.add(_getInternalCode(symbol));
            // MET Norway doesn't provide % probability in compact, using 0 for compatibility
            hourlyPops.add(0); 
          }

          // 2. Build Daily (7 days)
          final List<String> dailyTimes = [];
          final List<double> dailyMax = [];
          final List<double> dailyMin = [];
          final List<int> dailyCodes = [];
          final List<double> dailyPrecip = [];
          
          // Simple Daily Mapping: Group entries by date
          final Map<String, List<Map<String, dynamic>>> groupedByDay = {};
          for (var entry in timeseries) {
            final date = (entry['time'] as String).substring(0, 10);
            groupedByDay.putIfAbsent(date, () => []).add(entry);
          }

          final sortedDates = groupedByDay.keys.toList()..sort();
          for (int i = 0; i < sortedDates.length && i < 7; i++) {
            final dayEntries = groupedByDay[sortedDates[i]]!;
            dailyTimes.add(sortedDates[i]);
            
            double max = -100.0;
            double min = 100.0;
            double totalPrecip = 0.0;
            String topSymbol = 'unknown';

            for (var entry in dayEntries) {
              final temp = (entry['data']['instant']['details']['air_temperature'] as num).toDouble();
              if (temp > max) max = temp;
              if (temp < min) min = temp;
              
              // Sum up visible precipitation
              final p = (entry['data']['next_1_hours']?['details']?['precipitation_amount'] as num?)?.toDouble() ?? 0.0;
              totalPrecip += p;

              if (entry['time'].contains('12:00:00Z')) {
                topSymbol = entry['data']['next_6_hours']?['summary']?['symbol_code'] ?? 
                            entry['data']['next_1_hours']?['summary']?['symbol_code'] ?? 'unknown';
              }
            }
            if (topSymbol == 'unknown' && dayEntries.isNotEmpty) {
              topSymbol = dayEntries[0]['data']['next_1_hours']?['summary']?['symbol_code'] ?? 'unknown';
            }

            dailyMax.add(max);
            dailyMin.add(min);
            dailyCodes.add(_getInternalCode(topSymbol));
            dailyPrecip.add(double.parse(totalPrecip.toStringAsFixed(1)));
          }

          return {
            'latitude': latitude,
            'longitude': longitude,
            'current': {
              'temperature_2m': currentData['air_temperature'],
              'relative_humidity_2m': currentData['relative_humidity'],
              'wind_speed_10m': currentData['wind_speed'],
              'precipitation': timeseries[0]['data']['next_1_hours']?['details']?['precipitation_amount'] ?? 0.0,
              'weather_code': _getInternalCode(currentSymbol),
              'weather_code_string': currentSymbol,
            },
            'hourly': {
              'time': hourlyTimes,
              'temperature_2m': hourlyTemps,
              'weather_code': hourlyCodes,
              'precipitation_probability': hourlyPops,
            },
            'daily': {
              'time': dailyTimes,
              'temperature_2m_max': dailyMax,
              'temperature_2m_min': dailyMin,
              'weather_code': dailyCodes,
              'precipitation_sum': dailyPrecip,
            },
          };
        }
        return null;
      } else {
        debugPrint('[Weather] MET Norway Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('[Weather] MET Norway Exception: $e');
      return null;
    }
  }

  // --- Step 3: Compatibility Fix (Map Cloud Symbols to Integer Codes) ---
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