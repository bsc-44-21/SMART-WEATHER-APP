import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/ai_config.dart';
import '../models/plot.dart';

class OpenRouterAiService {
  static final OpenRouterAiService _instance = OpenRouterAiService._internal();

  factory OpenRouterAiService() {
    return _instance;
  }

  
  OpenRouterAiService._internal();

  /// Generate farming advice based on activity, plot info, and weather data
  /// Automatically retries with fallback models if primary fails
  Future<String> generateFarmingAdvice({
    required String activity,
    required String plotName,
    required String cropName,
    required String date,
    required Map<String, dynamic>? weatherData,
    List<String> previousAdvice = const [],
  }) async {
    // Try primary model first, then fallbacks
    final modelsToTry = [AiConfig.primaryModel, ...AiConfig.fallbackModels];
    
    for (int i = 0; i < modelsToTry.length; i++) {
      final model = modelsToTry[i];
      print('[AI] Attempt ${i + 1}/${modelsToTry.length} with model: $model');
      
      final result = await _callOpenRouterAPI(
        activity: activity,
        plotName: plotName,
        cropName: cropName,
        date: date,
        weatherData: weatherData,
        previousAdvice: previousAdvice,
        model: model,
      );

      // If successful (doesn't contain error indicator), return it
      if (result != null && !result.contains('Error') && !result.contains('error')) {
        return result;
      }
      
      print('[AI] Model $model failed, trying next fallback...');
      
      // Wait a bit before retry
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // All models failed
    return 'Unable to generate advice at this moment. Please try again later.';
  }

  /// Call OpenRouter API with a specific model
  Future<String?> _callOpenRouterAPI({
    required String activity,
    required String plotName,
    required String cropName,
    required String date,
    required Map<String, dynamic>? weatherData,
    required List<String> previousAdvice,
    required String model,
  }) async {
    try {
      final prompt = _buildPrompt(
        activity: activity,
        plotName: plotName,
        cropName: cropName,
        date: date,
        weatherData: weatherData,
        previousAdvice: previousAdvice,
      );

      print('[AI] Sending request to OpenRouter...');
      print('[AI] Model: $model');

      final requestBody = {
        'model': model,
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'temperature': 0.5,
        'max_tokens': 250,
      };

      final response = await http.post(
        Uri.parse(AiConfig.apiUrl),
        headers: {
          'Authorization': 'Bearer ${AiConfig.apiKey}',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://smart-weather-app.example.com',
          'X-Title': 'Smart Weather Farm App',
        },
        body: jsonEncode(requestBody),
      ).timeout(Duration(seconds: AiConfig.requestTimeoutSeconds));

      print('[AI] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['choices'] != null && data['choices'].isNotEmpty) {
            final advice = data['choices'][0]['message']['content'].toString().trim();
            print('[AI] Successfully generated advice with $model');
            return advice;
          }
        } catch (e) {
          print('[AI] Error parsing response: $e');
        }
        return null;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          final errorMsg = errorData['error']?['message'] ?? response.body;
          print('[AI] Model $model failed - Status ${response.statusCode}: $errorMsg');
        } catch (e) {
          print('[AI] Model $model failed - Status ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      print('[AI] Exception with model $model: $e');
      return null;
    }
  }