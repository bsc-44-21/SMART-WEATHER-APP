import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../core/secrets.dart';

class PestDetectionService {
  // Using a more reliable and tested model for plant diseases/pests
  static const String _modelId = "deniz/image-classification-plant-diseases";
  static const String _apiUrl = "https://api-inference.huggingface.co/models/$_modelId";

  static Future<String> detectPest(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          "Authorization": "Bearer ${AppSecrets.huggingFaceKey}",
          "Content-Type": "application/octet-stream",
          // CRITICAL: Tells Hugging Face to wait for the model to load if it's cold
           "x-wait-for-model": "true",
        },
        body: bytes,
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final List<dynamic> result = jsonDecode(response.body);
        if (result.isNotEmpty) {
          // Returns the label with highest confidence
          return result[0]['label'];
        }
        throw Exception("AI analysis returned no results.");
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['error'] ?? 'Unknown API error';
        throw Exception("Hugging Face API Error: $errorMessage");
      }
    } on TimeoutException {
      throw Exception("The detection request timed out. Please try again.");
    } on SocketException {
      throw Exception("No internet connection or server unreachable.");
    } on http.ClientException catch (e) {
      throw Exception("Connection failed: ${e.message}. Please check your network and try again.");
    } catch (e) {
      throw Exception("Detection failed: $e");
    }
  }
}