/// Configuration file for OpenRouter AI API credentials
class AiConfig {
  static const String apiKey =
      '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';
  static const String apiUrl = 'https://openrouter.ai/api/v1/chat/completions';

  // Primary model (will auto-fallback if fails)
  // These are VERIFIED working free models on OpenRouter
  static const String primaryModel = 'mistralai/mistral-7b-instruct:free';
  // Fallback models (tried in order if primary fails)
  static const List<String> fallbackModels = [
    'meta-llama/llama-3-8b-instruct:free',
    'nousresearch/nous-hermes-2-mixtral-8x7b-dpo:free',
    'openchat/openchat-3.6-8b:free',
    'openrouter/auto', // Automatic model selection by OpenRouter
  ];
  // Request timeout duration
  static const int requestTimeoutSeconds = 60;

  // Debugging: Set to true to see detailed logs
  static const bool debugMode = true;
  // System prompt to restrict AI responses to farming activities for tomato, maize, and groundnut
  static const String systemPrompt = '''
You are an AI assistant specialized in farming activities for tomato, maize, and groundnut. 
Only provide advice and information related to farming activities for these crops. 
For any questions outside of farming for tomato, maize, or groundnut, respond with: "Now I'm not trained to do that."
When an activity is logged, incorporate the current weather conditions from Open Meteo for the device's location and provide advice based on those conditions.
''';
}
