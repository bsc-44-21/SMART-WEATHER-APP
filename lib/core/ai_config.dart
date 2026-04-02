/// Configuration file for OpenRouter AI API credentials
class AiConfig {
  static const String apiKey = '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';
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
