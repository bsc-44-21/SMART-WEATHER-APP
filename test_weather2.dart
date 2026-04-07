import 'dart:io';
import 'dart:convert';

void main() async {
  double latitude = 52.52;
  double longitude = 13.41;
  final String url =
      'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,weather_code,precipitation,wind_speed_10m,rain&hourly=temperature_2m,weather_code,precipitation_probability&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max&timezone=GMT';

  print('Fetching weather from: $url');

  try {
    HttpClient client = HttpClient();
    client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    
    HttpClientRequest request = await client.getUrl(Uri.parse(url)).timeout(
      const Duration(seconds: 15),
    );
    HttpClientResponse response = await request.close();

    print('API Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('Successfully fetched weather data');
    } else {
      final responseBody = await response.transform(utf8.decoder).join();
      print('API Error Body: $responseBody');
    }
  } catch (e) {
    print('Exception fetching weather: $e');
  }
}
