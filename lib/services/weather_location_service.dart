import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherLocationService {
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
      );
    } catch (e) {
      print('Location error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchWeather(
      double lat, double lon) async {
    const maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,precipitation&timezone=auto',
        );

        print('[Weather Request] Attempt ${retryCount + 1}/$maxRetries - Location: $lat, $lon');
        print('[Weather Request] URL: $url');

        final response = await http
            .get(url)
            .timeout(const Duration(seconds: 10));

        print('[Weather Response] Status Code: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('═══════════════════════════════════════════════════');
          print('✅ OPEN METEO API SUCCESS - Location: $lat, $lon');
          print('═══════════════════════════════════════════════════');
          if (data['current'] != null) {
            print('🌤️  CURRENT WEATHER DATA:');
            print('   Temperature: ${data['current']['temperature_2m']}°');
            print('   Feels Like: ${data['current']['apparent_temperature']}°');
            print('   Humidity: ${data['current']['relative_humidity_2m']}%');
            print('   Wind Speed: ${data['current']['wind_speed_10m']} km/h');
            print('   Precipitation: ${data['current']['precipitation']} mm');
            print('   Weather Code: ${data['current']['weather_code']}');
          }
          print('═══════════════════════════════════════════════════\n');
          return data;
        } else if (response.statusCode == 502 || response.statusCode == 503) {
          // Server error - retry with delay
          retryCount++;
          if (retryCount < maxRetries) {
            final delaySeconds = (retryCount * 2); // Exponential backoff: 2s, 4s
            print('[Weather] Server Error ${response.statusCode}, retrying in ${delaySeconds}s...');
            await Future.delayed(Duration(seconds: delaySeconds));
            continue;
          } else {
            print('[Weather] Server Error ${response.statusCode} - Max retries reached');
            return null;
          }
        } else {
          print('[Weather] API Error: ${response.statusCode}');
          print('[Weather Response Body]: ${response.body}');
          return null;
        }
      } on TimeoutException {
        retryCount++;
        if (retryCount < maxRetries) {
          print('[Weather] Timeout - Retrying (Attempt ${retryCount + 1}/$maxRetries)...');
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        } else {
          print('[Weather] Timeout - Max retries reached');
          return null;
        }
      } catch (e) {
        print('[Weather] Error: $e');
        return null;
      }
    }

    return null;
  }

  static String getWeatherDescription(int weatherCode) {
    const Map<int, String> descriptions = {
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
    return descriptions[weatherCode] ?? 'Unknown';
  }

  static String getWeatherEmoji(int weatherCode) {
    if (weatherCode == 0) return '☀️';
    if (weatherCode == 1 || weatherCode == 2) return '⛅';
    if (weatherCode == 3) return '☁️';
    if (weatherCode == 45 || weatherCode == 48) return '🌫️';
    if (weatherCode >= 51 && weatherCode <= 55) return '🌧️';
    if (weatherCode >= 61 && weatherCode <= 65) return '🌧️';
    if (weatherCode >= 71 && weatherCode <= 77) return '❄️';
    if (weatherCode >= 80 && weatherCode <= 82) return '🌧️';
    if (weatherCode >= 85 && weatherCode <= 86) return '🌨️';
    if (weatherCode >= 95 && weatherCode <= 99) return '⛈️';
    return '🌤️';
  }
}