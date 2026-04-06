import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherLocationService {

  static Future<Position?> getLocationWithPermission() async {
    try {
      
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

       LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      
      if (permission == LocationPermission.deniedForever) {
        return null;
      }

     
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchWeather(
    double latitude,
    double longitude,
  ) async {
    try {
      final String url =
          'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,weather_code,precipitation,wind_speed_10m,rain&hourly=temperature_2m,weather_code,precipitation_probability&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max&timezone=auto';

      print('[Weather] Fetching weather from: $url');

      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              print('[Weather] Request timeout after 15 seconds');
              return http.Response('Error', 408);
            },
          );

      print('[Weather] API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('[Weather] Successfully fetched weather data');
        return {
          'latitude': jsonResponse['latitude'],
          'longitude': jsonResponse['longitude'],
          'timezone': jsonResponse['timezone'],
          'current': jsonResponse['current'],
          'hourly': jsonResponse['hourly'],
          'daily': jsonResponse['daily'],
        };
      } else {
        print('[Weather] API Error: ${response.statusCode} - ${response.body}');
      }
      return null;
    } catch (e) {
      print('[Weather] Exception fetching weather: $e');
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
    if (weatherCode >= 51 && weatherCode <= 55) return '🌧️';
    if (weatherCode >= 61 && weatherCode <= 65) return '🌧️';
    if (weatherCode >= 71 && weatherCode <= 77) return '❄️';
    if (weatherCode >= 80 && weatherCode <= 82) return '🌧️';
    if (weatherCode >= 85 && weatherCode <= 86) return '🌨️';
    if (weatherCode >= 95 && weatherCode <= 99) return '⛈️';
    return '🌤️';
  }
}
