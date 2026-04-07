import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/ai_config.dart';

class OpenRouterAiService {
  static final OpenRouterAiService _instance = OpenRouterAiService._internal();

  factory OpenRouterAiService() => _instance;

  OpenRouterAiService._internal();

  /// Generate AI response for a user prompt
  Future<String> generateCustomResponse({required String userPrompt}) async {
    if (!AiConfig.hasApiKey) {
      return 'API key is missing or invalid. Please set OPENROUTER_API_KEY and ensure it has no quotes.';
    }

    final modelsToTry = [AiConfig.primaryModel, ...AiConfig.fallbackModels];

    for (int i = 0; i < modelsToTry.length; i++) {
      final model = modelsToTry[i];
      debugPrint('[AI] Attempt ${i + 1}/${modelsToTry.length} with model: $model');

      final result = await _callOpenRouterChat(model: model, userPrompt: userPrompt);

      if (result != null && _isValidAiResponse(result)) {
        return result;
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    return 'Unable to generate AI response at the moment.';
  }

  Future<String?> _callOpenRouterChat({required String model, required String userPrompt}) async {
    try {
      final requestBody = {
        'model': model,
        'messages': [
          {'role': 'system', 'content': AiConfig.systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
        'temperature': 0.5,
        'max_tokens': 250,
      };

      final response = await http.post(
        Uri.parse(AiConfig.apiUrl),
        headers: {
          'Authorization': 'Bearer ${AiConfig.normalizedApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(Duration(seconds: AiConfig.requestTimeoutSeconds));

      // Safe preview
      final bodyPreview = AiConfig.safeSubstring(response.body, 500);
      debugPrint('[AI] Response body: $bodyPreview');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          return data['choices'][0]['message']?['content']?.toString().trim();
        }
        return 'Empty response from model';
      }

      if (response.statusCode == 401) {
        return 'Unauthorized (401): missing or invalid API key. Ensure OPENROUTER_API_KEY is set and valid.';
      }

      return 'HTTP ${response.statusCode}: ${response.body}';
    } catch (e) {
      debugPrint('[AI] Exception: $e');
      return 'Exception occurred: $e';
    }
  }
  bool _isValidAiResponse(String response) {
    final lower = response.trim().toLowerCase();
    if (lower.isEmpty) return false;

    final errorIndicators = [
      'http ',
      'exception',
      'invalid api key',
      'received html',
      'no choices',
      'empty response',
      'parse error',
      'failed',
    ];

    for (final token in errorIndicators) {
      if (lower.contains(token)) {
        return false;
      }
    }

    return true;
  }
  /// Generate farming advice with retries
  Future<String> generateFarmingAdvice({
    required String activity,
    required String plotName,
    required String cropName,
    required String date,
    required Map<String, dynamic>? weatherData,
    List<String> previousAdvice = const [],
  }) async {
    final modelsToTry = [AiConfig.primaryModel, ...AiConfig.fallbackModels];
    String lastError = 'No response from any model';

    for (var model in modelsToTry) {
      final result = await _callOpenRouterAPI(
        activity: activity,
        plotName: plotName,
        cropName: cropName,
        date: date,
        weatherData: weatherData,
        previousAdvice: previousAdvice,
        model: model,
      );

      if (result != null && _isValidAiResponse(result)) {
        debugPrint('[AI] SUCCESS with $model');
        return result;
      }

      if (result != null) {
        lastError = result;
      }

      debugPrint('[AI] Model $model failed, trying next fallback...');
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return 'AI failed: $lastError';
  }

  Future<String?> _callOpenRouterAPI({
    required String activity,
    required String plotName,
    required String cropName,
    required String date,
    required Map<String, dynamic>? weatherData,
    required List<String> previousAdvice,
    required String model,
  }) async {
    final prompt = _buildPrompt(
      activity: activity,
      plotName: plotName,
      cropName: cropName,
      date: date,
      weatherData: weatherData,
      previousAdvice: previousAdvice,
    );

    debugPrint('[AI] Sending request with model $model');
    debugPrint('[AI] API Key: ${AiConfig.safeSubstring(AiConfig.normalizedApiKey, 20)}...');
    debugPrint('[AI] Prompt length: ${prompt.length} chars');

    try {
      final requestBody = {
        'model': model,
        'messages': [
          {'role': 'system', 'content': AiConfig.systemPrompt},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.5,
        'max_tokens': 250,
      };

      final response = await http.post(
        Uri.parse(AiConfig.apiUrl),
        headers: {
          'Authorization': 'Bearer ${AiConfig.normalizedApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(Duration(seconds: AiConfig.requestTimeoutSeconds));

      final bodyPreview = AiConfig.safeSubstring(response.body, 500);
      debugPrint('[AI] Response body preview: $bodyPreview');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          return data['choices'][0]['message']?['content']?.toString().trim() ?? 'Empty response';
        }
      }

      if (response.statusCode == 401) {
        return 'Unauthorized (401): missing or invalid API key. Ensure OPENROUTER_API_KEY is set and valid.';
      }

      return 'HTTP ${response.statusCode}: ${response.body}';
    } catch (e) {
      return 'Exception: $e';
    }
  }

  String _buildPrompt({
    required String activity,
    required String plotName,
    required String cropName,
    required String date,
    required Map<String, dynamic>? weatherData,
    required List<String> previousAdvice,
  }) {
    final now = DateTime.now();
    final inputDate = DateTime.tryParse(date) ?? now;
    final dayDiff = inputDate.difference(DateTime(now.year, now.month, now.day)).inDays;
    
    final buffer = StringBuffer();
    buffer.writeln('CONTEXT:');
    buffer.writeln('Today is: ${now.toString().substring(0, 10)}');
    buffer.writeln('Farmer Activity Date: $date');
    
    if (dayDiff < 0) {
      buffer.writeln('IMPORTANT: This is a PAST LOG (${dayDiff.abs()} days ago). Acknowledge that the date has passed but explain if the weather then was suitable.');
    } else if (dayDiff == 0) {
      buffer.writeln('IMPORTANT: This is for TODAY. Check the hourly forecast if available.');
    } else {
      buffer.writeln('IMPORTANT: This is for the FUTURE. Act as a predictive planner.');
    }

    buffer.writeln('\nFARMING CASE:');
    buffer.writeln('- Activity: $activity');
    buffer.writeln('- Plot Name: $plotName');
    buffer.writeln('- Crop: $cropName');
    
    if (weatherData != null) {
      buffer.writeln('\nWEATHER FORECAST DATA:');
      // Limit data sent to AI to keep it focused (7 days max)
      if (weatherData['daily'] != null) {
        buffer.writeln('7-Day Highs: ${weatherData['daily']['temperature_2m_max']}');
        buffer.writeln('7-Day Rainfall Sums: ${weatherData['daily']['precipitation_sum']}');
      }
      if (weatherData['current'] != null) {
        buffer.writeln('Current: ${weatherData['current']}');
      }
    }

    buffer.writeln('\nTASK: Provide professional agricultural advice in 1-2 concise sentences based on the Knowledge Base in your system prompt.');
    return buffer.toString();
  }
}