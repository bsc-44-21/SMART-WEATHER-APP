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
          'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,weather_code&timezone=auto';

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