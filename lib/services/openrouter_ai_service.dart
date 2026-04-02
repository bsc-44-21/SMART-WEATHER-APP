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