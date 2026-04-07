import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  double latitude = 52.52;
  double longitude = 13.41;
  final String url =
      'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,weather_code,precipitation,wind_speed_10m,rain&hourly=temperature_2m,weather_code,precipitation_probability&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max&timezone=auto';

  print('Fetching weather from: $url');

  try {
    final response = await http
        .get(Uri.parse(url))
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            print('Request timeout after 15 seconds');
            return http.Response('Error', 408);
          },
        );

    print('API Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print('Successfully fetched weather data');
    } else {
      print('API Error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Exception fetching weather: $e');
  }
}
